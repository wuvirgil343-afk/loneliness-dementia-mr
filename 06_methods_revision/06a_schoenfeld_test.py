# -*- coding: utf-8 -*-
"""
方法学修订 (回应 R1#1, R1#2, R4#6)
- R1#1: Cox 比例风险假设 -> Schoenfeld 残差检验
- R1#2/R4#6: Fine-Gray 竞争风险 -> 比例假设 + 报告调整后 subdistribution HR
- 主分析基于 6004 完整病例样本 (基线暴露完整)
输出全部写入 output/methods_revision/
"""
import pandas as pd
import numpy as np
import os
import sys

io = open(r"output_methods_revision.txt", "w", encoding="utf-8")
def out(*a):
    print(*a); print(*a, file=io)

from lifelines import CoxPHFitter
from lifelines.statistics import proportional_hazard_test

BASE = "."
OUT = os.path.join("output", "methods_revision")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------
# 1. 载入数据 + 构建 6004 完整病例主分析样本
# ---------------------------------------------------------------
df = pd.read_csv("HRS_ML_dataset.csv")
out(f"原始数据: {len(df)} 行")

# 主分析样本: 基线暴露完整 (exposure_4cat 非缺失) + 结局时间非缺失
# exposure_4cat: 1=Neither 2=Iso-only 3=Lonely-only 4=Both
d = df[df["exposure_4cat"].notna()].copy()
out(f"exposure_4cat 非缺失: {len(d)}")

# 结局: 痴呆
d_dem = d[d["dementia_time"].notna() & (d["dementia_time"] > 0)].copy()
d_dem["event"] = (d_dem["ever_dementia"] == 1).astype(int)
out(f"痴呆分析样本: {len(d_dem)}, 事件数: {int(d_dem['event'].sum())}")

# 协变量
covars = ["agey_b", "ragender", "raedyrs", "cesd", "chronic_count", "cog27"]
for c in covars:
    d_dem[c] = pd.to_numeric(d_dem[c], errors="coerce")

# 暴露哑变量 (以 Neither=1 为参照)
d_dem["iso_only"]    = (d_dem["exposure_4cat"] == 2).astype(int)
d_dem["lonely_only"] = (d_dem["exposure_4cat"] == 3).astype(int)
d_dem["both"]        = (d_dem["exposure_4cat"] == 4).astype(int)

model_cols = ["dementia_time", "event", "iso_only", "lonely_only", "both"] + covars
dm = d_dem[model_cols].dropna()
out(f"完整病例(去协变量缺失后): {len(dm)}, 事件: {int(dm['event'].sum())}")

# ---------------------------------------------------------------
# 2. Cox 模型 + Schoenfeld 残差检验 (R1#1)
# ---------------------------------------------------------------
out("\n" + "="*60)
out("Cox 比例风险模型: 孤独/隔离亚型 -> 痴呆")
out("="*60)

cph = CoxPHFitter()
cph.fit(dm, duration_col="dementia_time", event_col="event")
out("\n--- Cox 回归结果 (HR) ---")
summ = cph.summary[["coef", "exp(coef)", "exp(coef) lower 95%",
                    "exp(coef) upper 95%", "p"]]
out(summ.to_string())
summ.to_csv(os.path.join(OUT, "cox_dementia_HR.csv"))

# Schoenfeld 残差检验 (比例风险假设)
out("\n--- Schoenfeld 残差检验 (比例风险假设, R1#1) ---")
out("H0: 满足比例风险假设 (p>0.05 为通过)")
try:
    ph_test = proportional_hazard_test(cph, dm, time_transform="rank")
    ph_df = ph_test.summary
    out(ph_df.to_string())
    ph_df.to_csv(os.path.join(OUT, "schoenfeld_test_dementia.csv"))
    # 判读
    viol = ph_df[ph_df["p"] < 0.05]
    if len(viol) == 0:
        out(">>> 所有变量满足比例风险假设 (全部 p>0.05)")
    else:
        out(f">>> 以下变量违反比例风险假设: {list(viol.index)}")
        out("    应对: 对违反变量做时间交互项 或 分层Cox 或 报告为时间平均HR")
except Exception as e:
    out("Schoenfeld检验出错:", str(e))

# ---------------------------------------------------------------
# 3. 死亡结局的 Cox + Schoenfeld
# ---------------------------------------------------------------
out("\n" + "="*60)
out("Cox 比例风险模型: 孤独/隔离亚型 -> 全因死亡")
out("="*60)

d_death = d[d["death_time"].notna() & (d["death_time"] > 0)].copy()
d_death["event"] = (d_death["ever_died"] == 1).astype(int)
for c in covars:
    d_death[c] = pd.to_numeric(d_death[c], errors="coerce")
d_death["iso_only"]    = (d_death["exposure_4cat"] == 2).astype(int)
d_death["lonely_only"] = (d_death["exposure_4cat"] == 3).astype(int)
d_death["both"]        = (d_death["exposure_4cat"] == 4).astype(int)

dd = d_death[["death_time","event","iso_only","lonely_only","both"]+covars].dropna()
out(f"死亡分析样本: {len(dd)}, 死亡事件: {int(dd['event'].sum())}")

cph_d = CoxPHFitter()
cph_d.fit(dd, duration_col="death_time", event_col="event")
out("\n--- Cox 死亡结果 (HR) ---")
out(cph_d.summary[["coef","exp(coef)","exp(coef) lower 95%",
                   "exp(coef) upper 95%","p"]].to_string())
cph_d.summary.to_csv(os.path.join(OUT, "cox_death_HR.csv"))

out("\n--- Schoenfeld 残差检验 (死亡) ---")
try:
    ph_test_d = proportional_hazard_test(cph_d, dd, time_transform="rank")
    out(ph_test_d.summary.to_string())
    ph_test_d.summary.to_csv(os.path.join(OUT, "schoenfeld_test_death.csv"))
    viol_d = ph_test_d.summary[ph_test_d.summary["p"] < 0.05]
    out(f">>> 违反比例风险的变量: {list(viol_d.index) if len(viol_d) else '无'}")
except Exception as e:
    out("Schoenfeld检验(死亡)出错:", str(e))

# ---------------------------------------------------------------
# 4. 竞争风险: Fine-Gray (痴呆, 死亡为竞争事件) + 时间交互检验 (R1#2/R4#6)
# ---------------------------------------------------------------
out("\n" + "="*60)
out("Fine-Gray 竞争风险模型 (痴呆; 竞争事件=死亡)  R1#2/R4#6")
out("="*60)

# 竞争风险状态: 0=删失, 1=痴呆, 2=死亡(未痴呆)
d_cr = d[d["dementia_time"].notna() & (d["dementia_time"]>0)].copy()
for c in covars:
    d_cr[c] = pd.to_numeric(d_cr[c], errors="coerce")
d_cr["iso_only"]    = (d_cr["exposure_4cat"]==2).astype(int)
d_cr["lonely_only"] = (d_cr["exposure_4cat"]==3).astype(int)
d_cr["both"]        = (d_cr["exposure_4cat"]==4).astype(int)

status = np.zeros(len(d_cr), dtype=int)
status[(d_cr["ever_dementia"]==1).values] = 1
status[((d_cr["ever_died"]==1) & (d_cr["ever_dementia"]!=1)).values] = 2
d_cr["cr_status"] = status
out(f"竞争风险样本: {len(d_cr)}")
out(f"  痴呆事件(1): {int((status==1).sum())}")
out(f"  竞争死亡(2): {int((status==2).sum())}")
out(f"  删失(0): {int((status==0).sum())}")

try:
    # lifelines 提供 Fine-Gray (subdistribution) via crc
    from lifelines import CRCSplineFitter  # 不一定可用
except Exception:
    pass

# 用 lifelines 的 Fine-Gray: 通过 sklearn/lifelines competing risks
# lifelines 没有直接FG, 用 Aalen-Johansen做CIF + 用 statsmodels做子分布
# 稳妥方案: 报告调整后FG需要R的cmprsk或Python的 'lifelines'扩展
# 这里用 CumulativeIncidence + 提示需在R中补FG的调整模型

from lifelines import AalenJohansenFitter
out("\n--- Aalen-Johansen 累积发生率 (各暴露组痴呆CIF) ---")
for grp, name in [(1,"Neither"),(2,"Iso-only"),(3,"Lonely-only"),(4,"Both")]:
    sub = d_cr[d_cr["exposure_4cat"]==grp]
    if len(sub) < 10: 
        continue
    ajf = AalenJohansenFitter()
    try:
        ajf.fit(sub["dementia_time"], sub["cr_status"], event_of_interest=1)
        cif_final = ajf.cumulative_density_.iloc[-1, 0]
        out(f"  {name:12s} (n={len(sub)}): 随访末痴呆CIF = {cif_final:.3f}")
    except Exception as e:
        out(f"  {name}: CIF计算出错 {e}")

out("\n>>> 注意: lifelines不直接提供调整后Fine-Gray子分布HR。")
out(">>> 建议在R中用 cmprsk::crr() 或 survival::finegray()+coxph() 补充,")
out(">>> 并对每个协变量建立 与log(time)的交互项检验FG比例假设 (R1#2)。")
out(">>> 代码骨架见 finegray_R_skeleton.R")

io.close()

# 生成R骨架用于Fine-Gray调整模型+比例假设
r_skel = r'''# Fine-Gray 调整模型 + 比例假设检验 (R1#2, R4#6)
library(survival); library(cmprsk)
d <- read.csv("HRS_ML_dataset.csv")
d <- d[!is.na(d$exposure_4cat) & !is.na(d$dementia_time) & d$dementia_time>0, ]
# 竞争状态: 0删失 1痴呆 2死亡
d$cr <- 0
d$cr[d$ever_dementia==1] <- 1
d$cr[d$ever_died==1 & d$ever_dementia!=1] <- 2
d$iso_only <- as.integer(d$exposure_4cat==2)
d$lonely_only <- as.integer(d$exposure_4cat==3)
d$both <- as.integer(d$exposure_4cat==4)
cov <- c("iso_only","lonely_only","both","agey_b","ragender","raedyrs","cesd","chronic_count")
d2 <- na.omit(d[,c("dementia_time","cr",cov)])
# survival::finegray 构建加权数据
fg <- finegray(Surv(dementia_time, factor(cr)) ~ ., data=d2, etype=1)
fgfit <- coxph(Surv(fgstart, fgstop, fgstatus) ~ iso_only+lonely_only+both+
               agey_b+ragender+raedyrs+cesd+chronic_count,
               weights=fgwt, data=fg)
summary(fgfit)              # 调整后 subdistribution HR (R4#6)
cox.zph(fgfit)              # FG比例假设检验 (R1#2, 相当于时间交互)
'''
with open(os.path.join("finegray_R_skeleton.R"), "w", encoding="utf-8") as f:
    f.write(r_skel)

print("\n完成! 详见 output_methods_revision.txt 和 finegray_R_skeleton.R")
