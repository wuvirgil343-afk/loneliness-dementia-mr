# Loneliness, social isolation and incident dementia — analysis code

Analysis code for an integrated cohort, machine-learning and Mendelian randomization (MR) study of loneliness / social isolation and incident dementia in the Health and Retirement Study (HRS).

Scripts are numbered in the order in which analyses are run. Sections mix **Stata** (`.do`, data preparation and primary survival models), **Python** (`.py`, descriptives, machine learning, figures) and **R** (`.R`, Mendelian randomization and revision methods).

> **Data note.** This repository contains **code only**. No individual-level HRS data are included. HRS data are available under data-use agreement from https://hrs.isr.umich.edu. GWAS summary statistics are public (IEU OpenGWAS https://gwas.mrcieu.ac.uk; GWAS Catalog https://www.ebi.ac.uk/gwas). An OpenGWAS API token is required for the MR scripts (see below).

---

## Pipeline / folder structure

```
GitHub_code/
├── 01_data_preparation_stata/
│   ├── 01a_data_merge.do            合并各波 HRS 与 RAND 文件
│   └── 01b_data_preparation.do      变量派生、暴露/结局构建、导出分析数据集
├── 02_cohort_and_descriptives/
│   ├── 02a_table1_baseline.py       Table 1 基线特征
│   ├── 02b_trajectory_subtypes.do   亚型 (GMM) 与纵向轨迹 (探索性)
│   ├── 02c_subtype_diagnostics.py   聚类样本量/输入变量核查
│   └── 02d_participant_flow.py      参与者流程各步计数 (Figure 1)
├── 03_survival_analysis/
│   └── 03a_cox_finegray_stata.do    Cox 回归、KM、Fine–Gray 竞争风险
├── 04_machine_learning/
│   └── 04a_machine_learning.py      随机生存森林 + SHAP + 时依判别/校准
├── 05_mendelian_randomization/
│   ├── 05a_verify_gwas_ids.R        核实 OpenGWAS 数据集身份 (表型/样本量/PMID)
│   ├── 05b_find_correct_AD_gwas.R   定位正确的 Alzheimer's GWAS (Kunkle/Bellenguez)
│   ├── 05c_forward_MR.R             正向 MR: 孤独/隔离 → AD (主 Kunkle, 敏 Bellenguez)
│   ├── 05d_reverse_MR.R             反向 MR: AD 遗传易感性 → 孤独/隔离
│   ├── 05e_mediation_MR.R           中介 MR: 抑郁 / CRP 通路 (四估计量)
│   └── 05f_MR_power.R               工具强度 (F, R²) 与统计效力
├── 06_methods_revision/            返修阶段新增的方法学分析
│   ├── 06a_schoenfeld_test.py       比例风险假设 (Schoenfeld 残差)
│   ├── 06b_stratified_cox.R         年龄/认知分层 Cox 敏感性
│   ├── 06c_finegray_adjusted.R      调整后 Fine–Gray 子分布 HR + cox.zph
│   ├── 06d_weighted_cox_sensitivity.R  调查加权 Cox 敏感性 (svycoxph)
│   └── 06e_included_excluded_and_clustering.py  纳入vs排除比较 + 聚类诊断
└── 07_figures/
    ├── 07a_main_figures.py          正文主图
    ├── 07b_composite_figures.py     复合图
    └── 07c_integration_figures.py   整合图
```

---

## Recommended run order

1. **01** — 在 Stata 中运行数据准备，导出分析数据集（`HRS_analysis_long.csv`、`HRS_ML_dataset.csv`）。
2. **02** — 基线表、亚型/轨迹（探索性）、流程计数。
3. **03** — 主生存分析（Cox / Fine–Gray）。
4. **04** — 机器学习预测。
5. **05** — Mendelian randomization（先 05a/05b 确认数据源，再 05c–05f）。
6. **06** — 返修方法学（比例假设、分层、加权、纳入排除、聚类诊断）。
7. **07** — 生成图。

---

## Software environment

- **Stata** 17+（步骤 01, 02b, 03；需 `traj` 包用于轨迹分析）
- **Python** 3.12 — 见 `requirements.txt`
- **R** 4.3+ — 包：`TwoSampleMR`, `ieugwasr`, `MendelianRandomization`, `MRPRESSO`, `survival`, `survey`

### OpenGWAS token（MR 脚本必需）
MR 脚本通过 IEU OpenGWAS API 拉取数据，需 JWT token（2024-05 起强制）。在 https://api.opengwas.io 注册获取，然后：

```r
Sys.setenv(OPENGWAS_JWT = "your_token_here")
```

脚本默认从 `.opengwas_token` 文件读取；该文件**不应提交到 GitHub**（见 `.gitignore`）。

---

## Key GWAS datasets used

| 角色 | 表型 | 来源 | OpenGWAS/Catalog ID |
|---|---|---|---|
| Exposure | Loneliness / social isolation | Elsworth (UKB, 2018) | ukb-b-8476 |
| Outcome (primary) | Alzheimer's disease | Kunkle 2019 | ieu-b-2 |
| Outcome (sensitivity) | Alzheimer's disease | Bellenguez 2022 | ebi-a-GCST90027158 |
| Mediator | Major depression | Howard 2019 | ieu-b-102 |
| Mediator | C-reactive protein | Ligthart 2018 | ieu-b-35 |
| Exploratory | Intelligence | Savage 2018 | ebi-a-GCST006250 |

---

## Citation

If you use this code, please cite the associated manuscript (details to be added upon publication).

## License

Released under the MIT License (see `LICENSE`).
