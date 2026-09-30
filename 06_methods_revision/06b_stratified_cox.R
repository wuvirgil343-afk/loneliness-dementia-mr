################################################################################
# 分层 Cox 敏感性分析 (回应 R1#1)
# 背景: Schoenfeld检验显示 年龄(agey_b)、基线认知(cog27) 违反比例风险假设
# 对策: 对这两个变量分层(strata), 检验暴露HR是否稳健
# 主分析样本: 6004 完整病例 (基线暴露完整)
################################################################################
suppressMessages({ library(survival) })

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
csv  <- file.path(BASE, "HRS_ML_dataset.csv")
OUT  <- file.path(BASE, "output", "methods_revision")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

d <- read.csv(csv, stringsAsFactors = FALSE)
d <- d[!is.na(d$exposure_4cat) & !is.na(d$dementia_time) & d$dementia_time > 0, ]
d$event <- as.integer(d$ever_dementia == 1)

# 暴露哑变量 (参照=Neither=1)
d$iso_only    <- as.integer(d$exposure_4cat == 2)
d$lonely_only <- as.integer(d$exposure_4cat == 3)
d$both        <- as.integer(d$exposure_4cat == 4)

for(v in c("agey_b","ragender","raedyrs","cesd","chronic_count","cog27")){
  d[[v]] <- as.numeric(d[[v]])
}

# 分层变量: 年龄组 + 认知组
d$age_grp <- cut(d$agey_b, breaks=c(0,65,75,85,200),
                 labels=c("<65","65-74","75-84","85+"), right=FALSE)
# 基线认知三分位
cog_terts <- quantile(d$cog27, c(1/3,2/3), na.rm=TRUE)
d$cog_grp <- cut(d$cog27, breaks=c(-Inf, cog_terts, Inf),
                 labels=c("low","mid","high"))

vars <- c("dementia_time","event","iso_only","lonely_only","both",
          "agey_b","ragender","raedyrs","cesd","chronic_count","cog27",
          "age_grp","cog_grp")
dd <- na.omit(d[, vars])
cat("分析样本:", nrow(dd), " 事件:", sum(dd$event), "\n\n")

fmt <- function(fit, label){
  s <- summary(fit)
  ci <- s$conf.int
  co <- s$coefficients
  rows <- intersect(c("iso_only","lonely_only","both"), rownames(ci))
  cat("---", label, "---\n")
  for(r in rows){
    cat(sprintf("  %-12s HR=%.3f (%.3f-%.3f), p=%.4g\n",
                r, ci[r,"exp(coef)"], ci[r,"lower .95"], ci[r,"upper .95"],
                co[r,"Pr(>|z|)"]))
  }
  cat("\n")
  data.frame(model=label, variable=rows,
             HR=ci[rows,"exp(coef)"],
             lower=ci[rows,"lower .95"],
             upper=ci[rows,"upper .95"],
             p=co[rows,"Pr(>|z|)"])
}

cat("================================================\n")
cat("暴露 -> 痴呆: 未分层 vs 分层 Cox 对比\n")
cat("================================================\n\n")

# 模型0: 原始未分层 (完整调整)
m0 <- coxph(Surv(dementia_time,event) ~ iso_only+lonely_only+both+
            agey_b+ragender+raedyrs+cesd+chronic_count+cog27, data=dd)
r0 <- fmt(m0, "未分层(原始)")

# 模型1: 对年龄分层
m1 <- coxph(Surv(dementia_time,event) ~ iso_only+lonely_only+both+
            ragender+raedyrs+cesd+chronic_count+cog27+strata(age_grp), data=dd)
r1 <- fmt(m1, "年龄分层")

# 模型2: 对认知分层
m2 <- coxph(Surv(dementia_time,event) ~ iso_only+lonely_only+both+
            agey_b+ragender+raedyrs+cesd+chronic_count+strata(cog_grp), data=dd)
r2 <- fmt(m2, "认知分层")

# 模型3: 年龄+认知双分层 (两个违反变量都分层)
m3 <- coxph(Surv(dementia_time,event) ~ iso_only+lonely_only+both+
            ragender+raedyrs+cesd+chronic_count+
            strata(age_grp)+strata(cog_grp), data=dd)
r3 <- fmt(m3, "年龄+认知双分层")

# 验证分层后是否满足比例假设
cat("================================================\n")
cat("双分层模型的 Schoenfeld 检验 (应改善)\n")
cat("================================================\n")
print(cox.zph(m3))

# 汇总保存
allres <- rbind(r0, r1, r2, r3)
write.csv(allres, file.path(OUT, "stratified_cox_comparison.csv"), row.names=FALSE)

cat("\n================================================\n")
cat("结论 (供回应信补 [ ] 处):\n")
cat("================================================\n")
cat("若各分层模型的暴露HR与未分层接近, 说明结论稳健,\n")
cat("比例风险假设违反(年龄/认知)不影响暴露-痴呆的主结论。\n")
cat("\n保存: output/methods_revision/stratified_cox_comparison.csv\n")
