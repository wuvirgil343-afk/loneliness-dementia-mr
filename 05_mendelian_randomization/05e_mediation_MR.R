################################################################################
# 中介 MR (用正确的 AD 结局 Kunkle 2019 重跑)  回应 R4#14, R3#11
# 路径: 孤独->抑郁, 抑郁->AD, 孤独->CRP, CRP->AD
# 暴露孤独: ukb-b-8476   AD: ieu-b-2(Kunkle)   抑郁: ieu-b-102   CRP: ieu-b-35
################################################################################
suppressMessages({ library(TwoSampleMR); library(ieugwasr) })

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
OUT  <- file.path(BASE, "output", "MR_revised")
dir.create(OUT, recursive=TRUE, showWarnings=FALSE)
Sys.setenv(OPENGWAS_JWT = trimws(readLines(file.path(BASE,".opengwas_token"),warn=FALSE)[1]))

ID_LONELY <- "ukb-b-8476"
ID_AD     <- "ieu-b-2"        # Kunkle 2019
ID_MDD    <- "ieu-b-102"
ID_CRP    <- "ieu-b-35"

# 通用: 提取暴露IV -> 结局 -> MR
run_path <- function(exp_id, out_id, label, methods=c("mr_ivw","mr_weighted_median",
                                                      "mr_egger_regression","mr_weighted_mode")){
  cat("==================================================\n")
  cat(label, "\n")
  cat("==================================================\n")
  e <- tryCatch(extract_instruments(exp_id, p1=5e-8, clump=TRUE, r2=0.001, kb=10000),
                error=function(err) NULL)
  if(is.null(e) || nrow(e) < 3){
    cat(">>> 工具变量不足 (n=", ifelse(is.null(e),0,nrow(e)), "), 跳过\n\n"); return(NULL)
  }
  o <- extract_outcome_data(e$SNP, out_id)
  dat <- harmonise_data(e, o)
  r <- mr(dat, method_list=methods)
  r$OR <- exp(r$b); r$OR_lci <- exp(r$b-1.96*r$se); r$OR_uci <- exp(r$b+1.96*r$se)
  r$path <- label; r$nIV_raw <- nrow(e)
  cat(sprintf("工具变量:%d  Harmonized:%d\n", nrow(e), sum(dat$mr_keep)))
  print(r[,c("method","nsnp","b","se","pval","OR","OR_lci","OR_uci")])
  cat("\n")
  r
}

# ---- 路径1: 孤独 -> 抑郁 ----
r_l_mdd <- run_path(ID_LONELY, ID_MDD, "孤独/隔离 -> 抑郁")

# ---- 路径2: 抑郁 -> AD(Kunkle) ----
r_mdd_ad <- run_path(ID_MDD, ID_AD, "抑郁 -> AD(Kunkle)")

# ---- 路径3: 孤独 -> CRP ----
r_l_crp <- run_path(ID_LONELY, ID_CRP, "孤独/隔离 -> CRP")

# ---- 路径4: CRP -> AD(Kunkle) ----
r_crp_ad <- run_path(ID_CRP, ID_AD, "CRP -> AD(Kunkle)")

# ---- 汇总 ----
all_list <- Filter(Negate(is.null), list(r_l_mdd, r_mdd_ad, r_l_crp, r_crp_ad))
allm <- do.call(rbind, lapply(all_list, function(x)
  x[,c("path","method","nsnp","b","se","pval","OR","OR_lci","OR_uci")]))
write.csv(allm, file.path(OUT,"mediation_MR_kunkle.csv"), row.names=FALSE)

# ---- 中介效应 (乘积法, 仅用IVW) ----
getivw <- function(r) if(is.null(r)) NA else r$b[r$method=="Inverse variance weighted"]
b_l_mdd  <- getivw(r_l_mdd)
b_mdd_ad <- getivw(r_mdd_ad)
b_l_crp  <- getivw(r_l_crp)
b_crp_ad <- getivw(r_crp_ad)

cat("==================================================\n")
cat("中介效应 (乘积法, IVW beta)\n")
cat("==================================================\n")
if(!is.na(b_l_mdd) && !is.na(b_mdd_ad))
  cat(sprintf("抑郁路径 间接效应 = %.5f x %.5f = %.6f\n",
              b_l_mdd, b_mdd_ad, b_l_mdd*b_mdd_ad))
if(!is.na(b_l_crp) && !is.na(b_crp_ad))
  cat(sprintf("CRP路径  间接效应 = %.5f x %.5f = %.6f\n",
              b_l_crp, b_crp_ad, b_l_crp*b_crp_ad))

cat("\n关键: CRP->AD 需看四方法是否一致(回应R4#14):\n")
if(!is.null(r_crp_ad)){
  for(m in c("Inverse variance weighted","Weighted median","MR Egger","Weighted mode")){
    row <- r_crp_ad[r_crp_ad$method==m,]
    if(nrow(row)) cat(sprintf("  %-26s OR=%.3f p=%.4g\n", m, row$OR, row$pval))
  }
}
cat("\n保存: mediation_MR_kunkle.csv\n")
