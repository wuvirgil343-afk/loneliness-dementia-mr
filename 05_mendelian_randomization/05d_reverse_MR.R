################################################################################
# 真正的反向 MR: AD 遗传易感性 -> 孤独/社会隔离 (回应 R3#3, R4#13)
# 暴露: AD (工具变量), 结局: 孤独/隔离 (ukb-b-8476)
# 用两个AD GWAS各试: Kunkle(ieu-b-2) 和 Bellenguez(ebi-a-GCST90027158)
################################################################################
suppressMessages({ library(TwoSampleMR); library(ieugwasr) })

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
OUT  <- file.path(BASE, "output", "MR_revised")
dir.create(OUT, recursive=TRUE, showWarnings=FALSE)
Sys.setenv(OPENGWAS_JWT = trimws(readLines(file.path(BASE,".opengwas_token"),warn=FALSE)[1]))

ID_LONELY <- "ukb-b-8476"
ad_sources <- list(
  "Kunkle2019"   = "ieu-b-2",
  "Bellenguez2022" = "ebi-a-GCST90027158"
)

run_reverse <- function(ad_name, ad_id){
  cat("\n================================================\n")
  cat(sprintf("反向MR: %s (AD) -> Loneliness\n", ad_name))
  cat("================================================\n")

  # 提取AD工具变量
  exp_ad <- tryCatch(
    extract_instruments(ad_id, p1=5e-8, clump=TRUE, r2=0.001, kb=10000),
    error=function(e){ cat("提取失败:", conditionMessage(e), "\n"); NULL })

  if(is.null(exp_ad) || nrow(exp_ad) < 3){
    cat(sprintf(">>> %s 全基因组显著独立SNP不足(n=%s), 无法做稳健反向MR\n",
                ad_name, ifelse(is.null(exp_ad),0,nrow(exp_ad))))
    cat(">>> 应在回应中如实说明: 反向MR受限于AD工具变量数量\n")
    return(NULL)
  }
  cat("AD工具变量数:", nrow(exp_ad), "\n")

  # 结局: 孤独
  out_lon <- extract_outcome_data(exp_ad$SNP, ID_LONELY)
  dat <- harmonise_data(exp_ad, out_lon)
  cat("Harmonized SNP:", sum(dat$mr_keep), "\n")

  res <- mr(dat, method_list=c("mr_ivw","mr_weighted_median",
                               "mr_egger_regression","mr_weighted_mode"))
  cat("\n结果:\n")
  print(res[,c("method","nsnp","b","se","pval")])

  # 敏感性
  pl <- tryCatch(mr_pleiotropy_test(dat), error=function(e) NULL)
  if(!is.null(pl)) cat(sprintf("MR-Egger截距 p=%.3f\n", pl$pval))

  res$ad_source <- ad_name
  write.csv(res, file.path(OUT, sprintf("reverse_MR_%s_to_loneliness.csv", ad_name)),
            row.names=FALSE)
  res
}

all_res <- list()
for(nm in names(ad_sources)){
  r <- run_reverse(nm, ad_sources[[nm]])
  if(!is.null(r)) all_res[[nm]] <- r
}

cat("\n\n================================================\n")
cat("反向MR汇总 (回应R3#3/R4#13)\n")
cat("================================================\n")
if(length(all_res)==0){
  cat(">>> 两个AD GWAS的工具变量都不足以做反向MR。\n")
  cat(">>> 回应写法: '我们尝试用AD遗传工具做反向MR(AD->孤独),\n")
  cat("    但在p<5e-8下独立工具变量不足, 无法得到稳健估计,\n")
  cat("    这一局限已在Limitations中说明。'\n")
} else {
  for(nm in names(all_res)){
    ivw <- all_res[[nm]][all_res[[nm]]$method=="Inverse variance weighted",]
    cat(sprintf("  %s: IVW b=%.4f, p=%.3f (nSNP=%d)\n",
                nm, ivw$b, ivw$pval, ivw$nsnp))
  }
  cat("\n若IVW不显著 => 无反向因果证据 (AD遗传易感性不影响孤独)\n")
}
