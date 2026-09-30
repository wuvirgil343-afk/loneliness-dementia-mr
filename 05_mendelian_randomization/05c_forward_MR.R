################################################################################
# 正向 MR 主分析: 孤独/社会隔离 -> AD (用正确的AD GWAS)
# 主: Kunkle 2019 (ieu-b-2, 不含UKB)   敏感性: Bellenguez 2022
# 输出 Table 2 数据 + 敏感性 + F统计量
################################################################################
suppressMessages({ library(TwoSampleMR); library(ieugwasr) })

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
OUT  <- file.path(BASE, "output", "MR_revised")
dir.create(OUT, recursive=TRUE, showWarnings=FALSE)
Sys.setenv(OPENGWAS_JWT = trimws(readLines(file.path(BASE,".opengwas_token"),warn=FALSE)[1]))

ID_LONELY    <- "ukb-b-8476"
ID_AD_MAIN   <- "ieu-b-2"              # Kunkle 2019
ID_AD_SENS   <- "ebi-a-GCST90027158"   # Bellenguez 2022

# ---- 提取暴露工具变量 + F统计量 ----
exp <- extract_instruments(ID_LONELY, p1=5e-8, clump=TRUE, r2=0.001, kb=10000)
exp$F_stat <- (exp$beta.exposure / exp$se.exposure)^2
cat("孤独/隔离 工具变量:", nrow(exp), " F均值:", round(mean(exp$F_stat),1),
    " 最小:", round(min(exp$F_stat),1), "\n\n")

run_forward <- function(ad_name, ad_id){
  cat("==================================================\n")
  cat(sprintf("正向MR: 孤独/隔离 -> AD (%s)\n", ad_name))
  cat("==================================================\n")

  out <- extract_outcome_data(exp$SNP, ad_id)
  dat <- harmonise_data(exp, out)
  nkeep <- sum(dat$mr_keep)
  cat("Harmonized SNP:", nkeep, "\n")

  res <- mr(dat, method_list=c("mr_ivw","mr_weighted_median",
                               "mr_egger_regression","mr_weighted_mode"))
  res$OR     <- exp(res$b)
  res$OR_lci <- exp(res$b - 1.96*res$se)
  res$OR_uci <- exp(res$b + 1.96*res$se)
  cat("\n--- MR结果 (OR per SD遗传预测孤独/隔离) ---\n")
  print(res[,c("method","nsnp","b","se","pval","OR","OR_lci","OR_uci")])

  # 敏感性
  het <- mr_heterogeneity(dat)
  pl  <- mr_pleiotropy_test(dat)
  cat(sprintf("\n异质性 Cochran Q (IVW): Q=%.1f, p=%.3f\n",
              het$Q[het$method=="Inverse variance weighted"],
              het$Q_pval[het$method=="Inverse variance weighted"]))
  cat(sprintf("MR-Egger 截距: %.5f, p=%.3f\n", pl$egger_intercept, pl$pval))

  res$ad_source <- ad_name
  write.csv(res, file.path(OUT, sprintf("forward_MR_loneliness_%s.csv", ad_name)),
            row.names=FALSE)

  # 图 (仅主分析)
  if(ad_name=="Kunkle2019"){
    tryCatch({
      p1 <- mr_scatter_plot(res, dat)
      ggplot2::ggsave(file.path(OUT,"forward_scatter_Kunkle.pdf"), p1[[1]], width=7, height=6)
      p2 <- mr_forest_plot(mr_singlesnp(dat))
      ggplot2::ggsave(file.path(OUT,"forward_forest_Kunkle.pdf"), p2[[1]], width=7, height=8)
      cat("图已保存 (scatter, forest)\n")
    }, error=function(e) cat("图生成出错:", conditionMessage(e), "\n"))
  }
  cat("\n")
  res
}

res_main <- run_forward("Kunkle2019", ID_AD_MAIN)
res_sens <- run_forward("Bellenguez2022", ID_AD_SENS)

# ---- Table 2 汇总 (主分析 IVW 为核心) ----
cat("==================================================\n")
cat("Table 2 核心数字 (正向 孤独->AD)\n")
cat("==================================================\n")
for(nm in list(list("Kunkle2019(主)",res_main), list("Bellenguez2022(敏)",res_sens))){
  ivw <- nm[[2]][nm[[2]]$method=="Inverse variance weighted",]
  cat(sprintf("  %s: IVW OR=%.3f (%.3f-%.3f), p=%.3f, nSNP=%d\n",
              nm[[1]], ivw$OR, ivw$OR_lci, ivw$OR_uci, ivw$pval, ivw$nsnp))
}

# 保存合并表
allf <- rbind(res_main, res_sens)
write.csv(allf, file.path(OUT,"Table2_forward_MR_all.csv"), row.names=FALSE)
cat("\n保存: Table2_forward_MR_all.csv\n")
cat("\n注意: 结合power分析(OR1.5仅9.9%效力), null结果应表述为\n")
cat("      '在弱工具下无因果证据', 而非'无因果效应'。\n")
