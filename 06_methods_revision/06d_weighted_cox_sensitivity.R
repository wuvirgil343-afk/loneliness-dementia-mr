################################################################################
# 加权 Cox 敏感性分析 (回应 R4#4)
# 用 HRS 个体权重 wtresp 重跑主暴露->痴呆/死亡 Cox, 检验结论稳健性
# 主分析(未加权) vs 加权 对比
################################################################################
suppressMessages({
  library(survival)
  library(survey)   # svycoxph 做复杂抽样加权Cox
})

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
csv  <- file.path(BASE, "HRS_ML_dataset.csv")
OUT  <- file.path(BASE, "output", "methods_revision")
dir.create(OUT, recursive=TRUE, showWarnings=FALSE)

d <- read.csv(csv, stringsAsFactors=FALSE)
d <- d[!is.na(d$exposure_4cat) & !is.na(d$dementia_time) & d$dementia_time>0, ]

# 检查权重变量
cat("========== 权重变量 wtresp 检查 ==========\n")
cat("wtresp 非缺失:", sum(!is.na(d$wtresp)), "/", nrow(d), "\n")
cat("wtresp 缺失:", sum(is.na(d$wtresp)), "\n")
cat("wtresp >0 的数量:", sum(d$wtresp > 0, na.rm=TRUE), "\n")
cat("wtresp 分布: 均值=", round(mean(d$wtresp, na.rm=TRUE),1),
    " 中位=", round(median(d$wtresp, na.rm=TRUE),1),
    " 范围[", round(min(d$wtresp,na.rm=TRUE),1), ",",
    round(max(d$wtresp,na.rm=TRUE),1), "]\n\n")

# 事件与暴露
d$event <- as.integer(d$ever_dementia==1)
d$death <- as.integer(d$ever_died==1)
d$iso_only    <- as.integer(d$exposure_4cat==2)
d$lonely_only <- as.integer(d$exposure_4cat==3)
d$both        <- as.integer(d$exposure_4cat==4)
for(v in c("agey_b","ragender","raedyrs","cesd","chronic_count","cog27"))
  d[[v]] <- as.numeric(d[[v]])

cov_str <- "iso_only + lonely_only + both + agey_b + ragender + raedyrs + cesd + chronic_count"

fmt_hr <- function(fit, label, vars=c("iso_only","lonely_only","both")){
  s <- summary(fit)
  cat("---", label, "---\n")
  # svycoxph 和 coxph 的 summary 结构略不同, 统一取 coef/conf
  co <- s$coefficients
  ci <- tryCatch(s$conf.int, error=function(e) NULL)
  for(v in vars){
    hr  <- exp(co[v,"coef"])
    lo  <- exp(co[v,"coef"] - 1.96*co[v,ifelse("se(coef)"%in%colnames(co),"se(coef)","robust se")])
    hi  <- exp(co[v,"coef"] + 1.96*co[v,ifelse("se(coef)"%in%colnames(co),"se(coef)","robust se")])
    pcol <- grep("Pr\\(|p$", colnames(co), value=TRUE)[1]
    cat(sprintf("  %-12s HR=%.3f (%.3f-%.3f)  p=%.4g\n", v, hr, lo, hi, co[v,pcol]))
  }
  cat("\n")
}

# ========== 痴呆结局 ==========
dd <- d[!is.na(d$wtresp) & d$wtresp>0, ]
dd <- dd[complete.cases(dd[,c("dementia_time","event","iso_only","lonely_only",
                              "both","agey_b","ragender","raedyrs","cesd","chronic_count")]), ]
cat("加权分析样本(有权重+协变量完整):", nrow(dd), " 痴呆事件:", sum(dd$event), "\n\n")

cat("==================================================\n")
cat("痴呆结局: 未加权 vs 加权 Cox\n")
cat("==================================================\n")

# 未加权
fit_unw <- coxph(as.formula(paste("Surv(dementia_time,event) ~", cov_str)), data=dd)
fmt_hr(fit_unw, "未加权 Cox")

# 加权 (svydesign + svycoxph)
des <- svydesign(ids=~1, weights=~wtresp, data=dd)
fit_w <- svycoxph(as.formula(paste("Surv(dementia_time,event) ~", cov_str)), design=des)
fmt_hr(fit_w, "加权 Cox (svycoxph)")

# ========== 死亡结局 ==========
dm <- d[!is.na(d$wtresp) & d$wtresp>0, ]
dm <- dm[!is.na(dm$death_time) & dm$death_time>0, ]
dm <- dm[complete.cases(dm[,c("death_time","death","iso_only","lonely_only",
                              "both","agey_b","ragender","raedyrs","cesd","chronic_count")]), ]
cat("==================================================\n")
cat("死亡结局: 未加权 vs 加权 Cox\n")
cat("==================================================\n")
cat("样本:", nrow(dm), " 死亡:", sum(dm$death), "\n\n")

fit_unw_d <- coxph(as.formula(paste("Surv(death_time,death) ~", cov_str)), data=dm)
fmt_hr(fit_unw_d, "未加权 Cox (死亡)")

des_d <- svydesign(ids=~1, weights=~wtresp, data=dm)
fit_w_d <- svycoxph(as.formula(paste("Surv(death_time,death) ~", cov_str)), design=des_d)
fmt_hr(fit_w_d, "加权 Cox (死亡)")

# ========== 保存汇总 ==========
extract <- function(fit, model, outcome){
  s <- summary(fit); co <- s$coefficients
  secol <- ifelse("se(coef)"%in%colnames(co),"se(coef)","robust se")
  pcol  <- grep("Pr\\(|p$", colnames(co), value=TRUE)[1]
  data.frame(model=model, outcome=outcome,
             exposure=c("iso_only","lonely_only","both"),
             HR=exp(co[c("iso_only","lonely_only","both"),"coef"]),
             lo=exp(co[c("iso_only","lonely_only","both"),"coef"]-1.96*co[c("iso_only","lonely_only","both"),secol]),
             hi=exp(co[c("iso_only","lonely_only","both"),"coef"]+1.96*co[c("iso_only","lonely_only","both"),secol]),
             p=co[c("iso_only","lonely_only","both"),pcol])
}
res_all <- rbind(
  extract(fit_unw,  "unweighted","dementia"),
  extract(fit_w,    "weighted",  "dementia"),
  extract(fit_unw_d,"unweighted","death"),
  extract(fit_w_d,  "weighted",  "death")
)
write.csv(res_all, file.path(OUT,"weighted_cox_sensitivity.csv"), row.names=FALSE)

cat("==================================================\n")
cat("结论(供回应R4#4):\n")
cat("若加权HR与未加权方向一致且显著性相近 => 结论对复杂抽样稳健,\n")
cat("可保留(适度限定的)可推广性表述。\n")
cat("保存: weighted_cox_sensitivity.csv\n")
