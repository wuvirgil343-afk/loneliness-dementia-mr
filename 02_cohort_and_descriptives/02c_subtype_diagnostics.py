# -*- coding: utf-8 -*-
"""核查亚型分析 N=5606 vs 完整暴露 N=6004 的~398人差异 (回应R3#6)"""
import pandas as pd
import numpy as np

df = pd.read_csv("HRS_ML_dataset.csv")

# 完整暴露样本
d = df[df["exposure_4cat"].notna()].copy()
n_full = len(d)
print(f"exposure_4cat 非缺失(完整暴露样本): {n_full}")

# 4类亚型各自N
print("\nexposure_4cat 分布:")
vc = d["exposure_4cat"].value_counts().sort_index()
labels = {1:"Neither", 2:"Iso-only", 3:"Lonely-only", 4:"Both"}
total_4 = 0
for k, v in vc.items():
    print(f"  {labels.get(int(k), k)}: {v}")
    total_4 += v
print(f"  合计: {total_4}")

# 检查亚型分析可能额外要求的变量 (isolated / lonely 二分)
print("\n可能导致额外缺失的组分变量:")
for col in ["isolated", "lonely", "social_isolation_score", "lblonely3",
            "cntc", "cntr", "cntf"]:
    if col in d.columns:
        miss = d[col].isna().sum()
        print(f"  {col}: 缺失 {miss}")

# 若亚型定义需要 isolated 且 lonely 都非缺失
if "isolated" in d.columns and "lonely" in d.columns:
    both_avail = d[d["isolated"].notna() & d["lonely"].notna()]
    print(f"\nisolated & lonely 均非缺失: {len(both_avail)}")
    print(f"  与6004差异: {n_full - len(both_avail)}")

# 尝试复现 5606: 各种组合
print("\n尝试定位 5606 的来源:")
for cols in [["isolated","lonely"],
             ["social_isolation_score","lblonely3"],
             ["isolated","lonely","social_activity_count"]]:
    avail = d.dropna(subset=[c for c in cols if c in d.columns])
    print(f"  完整({cols}): {len(avail)}")
