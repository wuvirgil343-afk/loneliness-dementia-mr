"""
生成Table 1: 基线特征表 (按暴露四分类分组)
输出: Table1.csv + Table1.md
"""
import pandas as pd
import numpy as np
from pathlib import Path
from scipy import stats

OUT = Path(r"d:\kiroproject\原始数据\3. HRS  美国\HRS_美国\Analysis")
df = pd.read_csv(OUT / "HRS_ML_dataset.csv")

# 暴露分组标签
grp_labels = {1: 'Neither', 2: 'Isolated only', 3: 'Lonely only', 4: 'Both'}
df = df[df['exposure_4cat'].notna()].copy()
df['grp'] = df['exposure_4cat'].map(grp_labels)

# 连续变量: 均值(SD) + ANOVA;  分类变量: n(%) + chi2
cont_vars = {
    'agey_b': 'Age, years',
    'raedyrs': 'Education, years',
    'cesd': 'CES-D depression (0-8)',
    'cog27': 'Cognition score (0-27)',
    'chronic_count': 'Chronic conditions (0-7)',
    'bmi': 'BMI, kg/m2',
    'social_isolation_score': 'Social isolation index (0-5)',
    'lblonely3': 'Loneliness (UCLA-3, 1-3)',
    'social_activity_count': 'Social activities (count)',
    'adl6': 'ADL limitations (0-6)',
    'iadl5': 'IADL limitations (0-5)',
}
cat_vars = {
    'ragender': ('Male', 1),
    'smoken': ('Current smoker', 1),
    'drink': ('Current drinker', 1),
    'ever_dementia': ('Incident dementia', 1),
    'ever_died': ('Died during follow-up', 1),
}

groups = ['Neither', 'Isolated only', 'Lonely only', 'Both']
rows = []

# N per group
n_row = {'Variable': 'N'}
for g in groups:
    n_row[g] = f"{(df['grp']==g).sum()}"
n_row['Overall'] = f"{len(df)}"
n_row['P'] = ''
rows.append(n_row)

# 连续变量
for v, label in cont_vars.items():
    if v not in df.columns:
        continue
    row = {'Variable': label}
    group_data = []
    for g in groups:
        vals = df.loc[df['grp']==g, v].dropna()
        group_data.append(vals)
        row[g] = f"{vals.mean():.1f} ({vals.std():.1f})"
    allvals = df[v].dropna()
    row['Overall'] = f"{allvals.mean():.1f} ({allvals.std():.1f})"
    # ANOVA
    try:
        _, p = stats.f_oneway(*group_data)
        row['P'] = f"{p:.3f}" if p >= 0.001 else "<0.001"
    except Exception:
        row['P'] = ''
    rows.append(row)

# 分类变量
for v, (label, pos) in cat_vars.items():
    if v not in df.columns:
        continue
    row = {'Variable': label}
    ct_data = []
    for g in groups:
        sub = df.loc[df['grp']==g, v].dropna()
        n_pos = (sub==pos).sum()
        pct = n_pos/len(sub)*100 if len(sub)>0 else 0
        row[g] = f"{n_pos} ({pct:.1f}%)"
        ct_data.append([n_pos, len(sub)-n_pos])
    allsub = df[v].dropna()
    n_all = (allsub==pos).sum()
    row['Overall'] = f"{n_all} ({n_all/len(allsub)*100:.1f}%)"
    try:
        _, p, _, _ = stats.chi2_contingency(np.array(ct_data).T)
        row['P'] = f"{p:.3f}" if p >= 0.001 else "<0.001"
    except Exception:
        row['P'] = ''
    rows.append(row)

table1 = pd.DataFrame(rows)[['Variable'] + groups + ['Overall', 'P']]
table1.to_csv(OUT / "output" / "Table1.csv", index=False)

# Markdown
with open(OUT / "output" / "Table1.md", 'w', encoding='utf-8') as f:
    f.write("# Table 1. Baseline characteristics by isolation-loneliness status (HRS 2008)\n\n")
    f.write("| " + " | ".join(table1.columns) + " |\n")
    f.write("|" + "|".join(["---"]*len(table1.columns)) + "|\n")
    for _, r in table1.iterrows():
        f.write("| " + " | ".join(str(x) for x in r.values) + " |\n")
    f.write("\n*Continuous: mean (SD), ANOVA; Categorical: n (%), chi-square.*\n")

print("Table 1 生成完成:")
print(table1.to_string(index=False))
