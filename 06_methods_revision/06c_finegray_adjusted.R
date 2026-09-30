################################################################################
# Fine-Gray 调整模型 + 比例假设检验 (回应 R1#2, R4#6)
# 调整后 subdistribution HR + FG比例假设(cox.zph)
################################################################################
suppressMessages({ library(survival) })

# 绝对路径, 避免工作目录问题
BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
csv  <- file.path(BASE, "HRS_ML_dataset.csv")
OUT  <- file.path(BASE, "output", "methods_revision")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

d <- read.csv(csv, stringsAsFactors = FALSE)
cat("读入行数:", nrow(d), "\n")

# 筛选: 有暴露 + 有痴呆时间
d <- d[!is.na(d$exposure_4cat) & !is.na(d$dementia_time) & d$dementia_time > 0, ]
cat("筛选后:", nrow(d), "\n")

# 竞争风险状态: 0=删失, 1=痴呆, 2=死亡(未痴呆)
d$cr <- 0
d$cr[d$ever_dementia == 1] <- 1
d$cr[d$ever_died == 1 & d$ever_dementia != 1] <- 2
cat("状态分布: 删失=", sum(d$cr==0), " 痴呆=", sum(d$cr==1), " 死亡=", sum(d$cr==2), "\n")

# 暴露哑变量 (参照=Neither)
d$iso_only    <- as.integer(d$exposure_4cat == 2)
d$lonely_only <- as.integer(d$exposure_4cat == 3)
d$both        <- as.integer(d$exposure_4cat == 4)

# 数值化协变量
for(v in c("agey_b","ragender","raedyrs","cesd","chronic_count")){
  d[[v]] <- as.numeric(d[[v]])
}

cov <- c("iso_only","lonely_only","both","agey_b","ragender","raedyrs","cesd","chronic_count")
d2 <- na.omit(d[, c("dementia_time","cr",cov)])
cat("完整病例:", nrow(d2), " 痴呆事件:", sum(d2$cr==1), "\n\n")

# ---- Fine-Gray via survival::finegray ----
# 构建加权数据集 (关注事件=痴呆, code 1)
d2$cr_f <- factor(d2$cr, 0:2, labels=c("censor","dementia","death"))
fg <- finegray(Surv(dementia_time, cr_f) ~ ., data=d2, etype="dementia")

fgfit <- coxph(Surv(fgstart, fgstop, fgstatus) ~
                 iso_only + lonely_only + both +
                 agey_b + ragender + raedyrs + cesd + chronic_count,
               weights = fgwt, data = fg)

cat("================================================\n")
cat("Fine-Gray 调整后子分布HR (R4#6)\n")
cat("================================================\n")
s <- summary(fgfit)
print(s$conf.int[, c("exp(coef)","lower .95","upper .95")])
cat("\nP值:\n")
print(s$coefficients[, "Pr(>|z|)"])

# 保存
res <- data.frame(
  variable = rownames(s$conf.int),
  sHR = s$conf.int[,"exp(coef)"],
  lower95 = s$conf.int[,"lower .95"],
  upper95 = s$conf.int[,"upper .95"],
  p = s$coefficients[,"Pr(>|z|)"]
)
write.csv(res, file.path(OUT, "finegray_adjusted_sHR.csv"), row.names=FALSE)

# ---- FG 比例假设检验 (R1#2: 相当于对时间的交互) ----
cat("\n================================================\n")
cat("Fine-Gray 比例假设检验 cox.zph (R1#2)\n")
cat("H0: 满足比例假设 (p>0.05通过)\n")
cat("================================================\n")
zph <- cox.zph(fgfit)
print(zph)
capture.output(print(zph), file=file.path(OUT, "finegray_zph.txt"))

cat("\n完成! 结果保存至 output/methods_revision/\n")
cat("  - finegray_adjusted_sHR.csv  (调整后子分布HR, 回应#6)\n")
cat("  - finegray_zph.txt           (比例假设检验, 回应#2)\n")
