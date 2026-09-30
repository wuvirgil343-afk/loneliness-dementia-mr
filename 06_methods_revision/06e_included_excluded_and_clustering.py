# -*- coding: utf-8 -*-
"""
补跑: (A) 纳入vs排除基线对比 (R3#2)
      (B) 亚型聚类 LCA 诊断 (R3#5) —— 用 GaussianMixture 的 BIC/entropy 作近似诊断
输出 output/methods_revision/
"""
import pandas as pd
import numpy as np
import os

io = open("remaining_out.txt","w",encoding="utf-8")
def out(*a):
    print(*a); print(*a,file=io)

OUT = os.path.join("output","methods_revision")
os.makedirs(OUT, exist_ok=True)

df = pd.read_csv("HRS_ML_dataset.csv")
out(f"全样本: {len(df)}")

# ===== (A) 纳入 vs 排除 基线对比 (R3#2) =====
out("\n" + "="*60)
out("(A) 纳入(有exposure_4cat) vs 排除 基线对比")
out("="*60)

df["included"] = df["exposure_4cat"].notna()
n_in = int(df["included"].sum()); n_ex = int((~df["included"]).sum())
out(f"纳入(基线暴露完整): {n_in}   排除: {n_ex}")

# 对比变量
cmp_vars = ["agey_b","raedyrs","cog27","cesd","chronic_count","bmi","ragender"]
rows = []
from scipy import stats
for v in cmp_vars:
    if v not in df.columns: continue
    x = pd.to_numeric(df.loc[df["included"], v], errors="coerce").dropna()
    y = pd.to_numeric(df.loc[~df["included"], v], errors="coerce").dropna()
    if len(x)<5 or len(y)<5: continue
    t,p = stats.ttest_ind(x,y,equal_var=False)
    rows.append({"variable":v,
                 "included_mean":round(x.mean(),2),"included_sd":round(x.std(),2),
                 "excluded_mean":round(y.mean(),2),"excluded_sd":round(y.std(),2),
                 "p":f"{p:.2e}"})
    out(f"  {v:15s} 纳入={x.mean():.2f}({x.std():.2f})  排除={y.mean():.2f}({y.std():.2f})  p={p:.2e}")

# 结局: 排除者的痴呆/死亡
for v in ["ever_dementia","ever_died"]:
    if v in df.columns:
        pin = df.loc[df["included"], v].mean()
        pex = df.loc[~df["included"], v].mean()
        out(f"  {v:15s} 纳入={pin*100:.1f}%  排除={pex*100:.1f}%")

pd.DataFrame(rows).to_csv(os.path.join(OUT,"included_vs_excluded.csv"), index=False)
out("保存: included_vs_excluded.csv")

# ===== (B) 亚型聚类 模型诊断 (R3#5) =====
out("\n" + "="*60)
out("(B) 亚型聚类模型诊断 (BIC/entropy, 2-6类)")
out("="*60)

from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler

# 聚类输入 (与原分析一致的社交变量)
clust_feats = ["social_isolation_score","lblonely3","social_activity_count",
               "cntc","cntr","cntf"]
clust_feats = [c for c in clust_feats if c in df.columns]
out(f"聚类输入变量: {clust_feats}")

cd = df[df["exposure_4cat"].notna()][clust_feats].apply(pd.to_numeric, errors="coerce").dropna()
out(f"聚类样本(完整): {len(cd)}")

X = StandardScaler().fit_transform(cd)

def entropy_of(gmm, X):
    proba = gmm.predict_proba(X)
    n,K = proba.shape
    eps=1e-12
    E = -np.sum(proba*np.log(proba+eps))
    return 1 - E/(n*np.log(K))  # normalized entropy (越接近1分类越清晰)

out(f"\n{'K':>2} {'BIC':>12} {'entropy':>8}")
diag=[]
for K in range(2,7):
    gm = GaussianMixture(n_components=K, covariance_type="full",
                         random_state=42, n_init=5, max_iter=300)
    gm.fit(X)
    bic = gm.bic(X)
    ent = entropy_of(gm, X)
    sizes = np.bincount(gm.predict(X), minlength=K)
    diag.append({"K":K,"BIC":round(bic,1),"entropy":round(ent,3),
                 "min_class":int(sizes.min()),"sizes":sizes.tolist()})
    out(f"{K:>2} {bic:>12.1f} {ent:>8.3f}   sizes={sizes.tolist()}")

pd.DataFrame(diag).to_csv(os.path.join(OUT,"cluster_diagnostics.csv"), index=False)
out("\n保存: cluster_diagnostics.csv")
out(">>> 用于回应R3#5: 报告BIC选类、entropy(分类质量), 并说明亚型分析为探索性")

io.close()
print("完成! 见 remaining_out.txt")
