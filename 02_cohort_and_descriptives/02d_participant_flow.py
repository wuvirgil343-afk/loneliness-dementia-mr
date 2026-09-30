# -*- coding: utf-8 -*-
"""计算 participant-flow 各步排除人数 (为 Figure 1 提供准确数字)"""
import pandas as pd
import numpy as np

df = pd.read_csv("HRS_ML_dataset.csv")
io = open("flow_out.txt","w",encoding="utf-8")
def out(*a): print(*a); print(*a,file=io)

N0 = len(df)
out(f"起始 (HRS 2008 全样本): {N0}")

# 逐步排除 (顺序: 基线已痴呆 -> 暴露缺失)
# 1. 基线已痴呆 (dementia_cat==2 通常为痴呆, 视编码)
if "dementia_cat" in df.columns:
    out(f"\ndementia_cat 分布: {df['dementia_cat'].value_counts(dropna=False).to_dict()}")

# 基线痴呆标识: 需确认编码. 常见 Langa-Weir: 1=normal 2=CIND 3=dementia
# 这里用 ever_dementia + dementia_time 推断基线状态较难, 先看可用列
cand = [c for c in df.columns if "dement" in c.lower()]
out(f"\n痴呆相关列: {cand}")

# 关键: 暴露完整性
step = df.copy()
out(f"\n=== 逐步构建主分析样本 ===")
out(f"步骤0 全样本: {len(step)}")

# 排除暴露缺失 (exposure_4cat 缺失)
n_expo_miss = step["exposure_4cat"].isna().sum()
step1 = step[step["exposure_4cat"].notna()]
out(f"步骤1 排除孤独/隔离暴露缺失: -{n_expo_miss}  => {len(step1)}")

# 在有暴露者中, 结局时间缺失
n_time_miss = (step1["dementia_time"].isna() | (step1["dementia_time"]<=0)).sum()
step2 = step1[step1["dementia_time"].notna() & (step1["dementia_time"]>0)]
out(f"步骤2 排除随访/事件时间缺失: -{n_time_miss}  => {len(step2)} (=Table1 主样本应为6004)")

# 协变量完整 (Cox模型样本)
cov = ["agey_b","ragender","raedyrs","cesd","chronic_count"]
mask = step2[cov].apply(pd.to_numeric, errors="coerce").notna().all(axis=1)
n_cov_miss = (~mask).sum()
step3 = step2[mask]
out(f"步骤3 排除协变量缺失: -{n_cov_miss}  => {len(step3)} (=Cox模型样本应为5849)")

# 各分支样本
out(f"\n=== 各分析分支 ===")
# 2x2亚型 (=step2, 6004)
vc = step2["exposure_4cat"].value_counts().sort_index()
out(f"2x2 分类 (n={len(step2)}): Neither={vc.get(1,0)} Iso={vc.get(2,0)} "
    f"Lonely={vc.get(3,0)} Both={vc.get(4,0)}")

# 聚类样本
try:
    clu = pd.read_csv("output/cluster_assignments.csv")
    out(f"聚类分析样本: {len(clu)}")
except: out("聚类文件未找到")

# 轨迹样本
try:
    traj = pd.read_csv("output/trajectory_assignments.csv")
    out(f"轨迹分析样本: {len(traj)}")
except: out("轨迹文件未找到")

# 事件数
out(f"\n=== 事件数 (主样本 n={len(step2)}) ===")
out(f"痴呆事件: {int((step2['ever_dementia']==1).sum())}")
out(f"死亡: {int((step2['ever_died']==1).sum())}")

io.close()
print("\n完成! 见 flow_out.txt")
