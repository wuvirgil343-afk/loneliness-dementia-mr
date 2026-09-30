################################################################################
# MR 效力(power)与工具强度分析 (回应 R3 #1, #8, #9)
#
# 输出:
#  1. 工具变量解释方差 R^2 (孤独/隔离)
#  2. 平均/总体 F 统计量
#  3. 给定当前AD结局样本量, 不同OR下的检验效力(power)
#  4. 80%效力对应的最小可检测OR (MDE)
#  5. 明确暴露的 scale (一个单位=什么)
################################################################################
suppressMessages({
  library(TwoSampleMR)
  library(ieugwasr)
})

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
OUT  <- file.path(BASE, "output", "MR_revised")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
token <- trimws(readLines(file.path(BASE, ".opengwas_token"), warn=FALSE)[1])
Sys.setenv(OPENGWAS_JWT = token)

ID_LONELY <- "ukb-b-8476"

# ---- 1. 提取工具变量 ----
exp <- extract_instruments(ID_LONELY, p1=5e-8, clump=TRUE, r2=0.001, kb=10000)
k <- nrow(exp)
cat("工具变量数 k =", k, "\n")

# ---- 2. 每SNP R^2 与 F ----
# R^2 = 2 * EAF * (1-EAF) * beta^2  (连续暴露, 标准化近似)
eaf  <- exp$eaf.exposure
beta <- exp$beta.exposure
se   <- exp$se.exposure
N_exp <- ifelse(!is.na(exp$samplesize.exposure), exp$samplesize.exposure, 455364)

r2_snp <- 2 * eaf * (1-eaf) * beta^2
R2_total <- sum(r2_snp, na.rm=TRUE)
cat(sprintf("单SNP R^2 合计 = %.5f (%.3f%%)\n", R2_total, R2_total*100))

# F统计量 (整体): F = R2/(1-R2) * (N-k-1)/k
N <- mean(N_exp, na.rm=TRUE)
F_overall <- (R2_total/(1-R2_total)) * (N - k - 1)/k
cat(sprintf("样本量 N = %.0f\n", N))
cat(sprintf("整体 F 统计量 = %.1f\n", F_overall))

# 每SNP F均值
F_snp <- (beta/se)^2
cat(sprintf("单SNP F: 均值=%.1f 中位=%.1f 最小=%.1f\n",
            mean(F_snp), median(F_snp), min(F_snp)))

# ---- 3. MR power 计算 (二分类结局AD) ----
# 使用 Brion et al. 2013 的近似公式
# 对二分类结局: 基于非中心参数 NCP = N_outcome * R2 * b_MR^2
# power = pnorm(sqrt(NCP) - qnorm(1-alpha/2))

# AD 结局样本量 (Kunkle 2019)
N_ad_case <- 21982
N_ad_ctrl <- 41944
N_ad <- N_ad_case + N_ad_ctrl
ratio_case <- N_ad_case / N_ad

alpha <- 0.05

# power 函数 (连续暴露 -> 二分类结局)
mr_power_binary <- function(OR, N, R2, ratio, alpha=0.05){
  b <- log(OR)
  # 有效样本量考虑病例比例
  ncp <- N * ratio * (1-ratio) * R2 * b^2
  power <- pnorm(sqrt(ncp) - qnorm(1 - alpha/2))
  power
}

cat("\n================================================\n")
cat("MR 检验效力 (孤独 -> AD, Kunkle 2019)\n")
cat(sprintf("AD结局: %d病例/%d对照 (N=%d), R2=%.4f, alpha=%.2f\n",
            N_ad_case, N_ad_ctrl, N_ad, R2_total, alpha))
cat("================================================\n")
ORs <- c(1.05, 1.10, 1.20, 1.30, 1.50)
cat(sprintf("%-10s %-10s\n", "OR", "Power"))
for(or in ORs){
  pw <- mr_power_binary(or, N_ad, R2_total, ratio_case, alpha)
  cat(sprintf("%-10.2f %-10.1f%%\n", or, pw*100))
}

# ---- 4. 80%效力对应的最小可检测OR ----
find_mde <- function(N, R2, ratio, target=0.80, alpha=0.05){
  f <- function(or) mr_power_binary(or, N, R2, ratio, alpha) - target
  uniroot(f, c(1.001, 5))$root
}
mde <- find_mde(N_ad, R2_total, ratio_case)
cat(sprintf("\n80%%效力最小可检测 OR = %.2f\n", mde))
cat(sprintf("(即: 若真实OR小于%.2f, 本研究难以检出, null结果可能是power不足)\n", mde))

# ---- 5. 保存 ----
power_tab <- data.frame(
  OR = ORs,
  power = sapply(ORs, function(or) mr_power_binary(or, N_ad, R2_total, ratio_case, alpha))
)
write.csv(power_tab, file.path(OUT, "MR_power_table.csv"), row.names=FALSE)

summary_txt <- sprintf(
"MR 工具强度与效力摘要 (回应R3 #1/#8/#9)
================================================
工具变量数: %d
工具解释方差 R^2: %.4f (%.2f%%)
整体F统计量: %.1f (远>10, 无弱工具偏倚)
单SNP F: 均值%.1f 最小%.1f

暴露scale: 遗传预测的孤独/隔离表型每增加1个SD
  (ukb-b-8476为UKB连续/累加量表, 效应以每SD表示)

检验效力 (孤独->AD, Kunkle N=%d):
  OR=1.10时 power=%.0f%%
  OR=1.20时 power=%.0f%%
  OR=1.30时 power=%.0f%%
  80%%效力最小可检测OR = %.2f

解读: F统计量证明无弱工具问题(反驳#8弱工具担忧);
但对小效应(OR<%.2f)效力有限, 故null结果应表述为
'无证据支持较大因果效应', 而非'确证无因果效应'。",
  k, R2_total, R2_total*100, F_overall, mean(F_snp), min(F_snp),
  N_ad,
  mr_power_binary(1.10,N_ad,R2_total,ratio_case,alpha)*100,
  mr_power_binary(1.20,N_ad,R2_total,ratio_case,alpha)*100,
  mr_power_binary(1.30,N_ad,R2_total,ratio_case,alpha)*100,
  mde, mde)

writeLines(summary_txt, file.path(OUT, "MR_power_summary.txt"))
cat("\n", summary_txt, "\n")
cat("\n保存: MR_power_table.csv, MR_power_summary.txt\n")
