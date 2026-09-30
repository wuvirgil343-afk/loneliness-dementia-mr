"""
================================================================================
Project: Social Isolation/Loneliness Heterogeneity & Dementia/Mortality
File: analysis_04_machine_learning.py
Purpose: ML分析 - 聚类识别亚型 + 生存预测 + SHAP解释
Input: HRS_ML_dataset.csv (由Stata analysis_01生成)
Author: [Your Name]
Date: 2026-07

运行环境:
    pip install pandas numpy scikit-learn scikit-survival shap xgboost
    pip install matplotlib seaborn lifelines tableone
================================================================================
"""

import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.model_selection import StratifiedKFold
import warnings
warnings.filterwarnings('ignore')

# ============== 路径 ==============
ROOT = Path("E:/HRS_美国/Analysis")
OUTPUT = ROOT / "output"
FIGURES = ROOT / "figures"
OUTPUT.mkdir(exist_ok=True)
FIGURES.mkdir(exist_ok=True)


# ============================================================================
# PART A: 数据加载与特征工程
# ============================================================================

def load_data():
    """加载Stata导出的ML数据集"""
    df = pd.read_csv(ROOT / "HRS_ML_dataset.csv")
    print(f"样本量: {len(df)}")
    print(f"痴呆事件: {df['ever_dementia'].sum()} ({df['ever_dementia'].mean()*100:.1f}%)")
    print(f"死亡事件: {df['ever_died'].sum()} ({df['ever_died'].mean()*100:.1f}%)")
    print(f"变量数: {df.shape[1]}")
    return df


def define_feature_groups():
    """定义变量分组（用于SHAP类别汇总和特征选择）"""
    groups = {
        'social_isolation': [
            'social_isolation_score', 'iso_unmarried', 'iso_livalone',
            'iso_child', 'iso_relative', 'iso_friend', 'isolated'
        ],
        'loneliness': ['lblonely3', 'lblonely11', 'lonely'],
        'social_activity': [
            'social_activity_count', 'intellectual_act', 'social_act',
            'physical_act', 'vol', 'hour_vol', 'hobby',
            'socwk', 'socmn', 'relgwk', 'email'
        ],
        'social_contact': ['cntc', 'cntr', 'cntf', 'away_child'],
        'demographics': ['baseline_age', 'ragender', 'raedyrs', 'race'],
        'cognition_baseline': ['cog27', 'memory_z', 'orient_z', 
                               'executive_z', 'slfmem'],
        'mental_health': ['cesd', 'depressive', 'lbsatwlf', 'cantril'],
        'chronic_disease': [
            'chronic_count', 'hibpe', 'diabe', 'cancre', 'lunge',
            'hearte', 'stroke', 'psyche', 'arthre'
        ],
        'physical_function': [
            'adl6a', 'iadl5a', 'frailty', 'fall', 'painfr'
        ],
        'health_behavior': [
            'bmi', 'smoken', 'drink', 'vgactx', 'mdactx', 
            'ltactx', 'pa_total'
        ],
        'personality': ['lbneur', 'lbext', 'lbopen', 'lbagr', 'lbcon5'],
        'sensory': ['hearing', 'sight'],
        'socioeconomic': ['ln_wealth', 'shlt']
    }
    return groups


def prepare_features(df, groups):
    """准备特征矩阵，返回可用特征列表"""
    all_features = []
    for feats in groups.values():
        all_features.extend(feats)
    
    # 仅保留数据中存在的列
    available = [f for f in all_features if f in df.columns]
    missing_cols = [f for f in all_features if f not in df.columns]
    if missing_cols:
        print(f"注意: {len(missing_cols)}个变量不在数据中: {missing_cols[:10]}...")
    
    print(f"可用特征: {len(available)}")
    return available


# ============================================================================
# PART B: 无监督聚类 - 识别社会隔离-孤独异质性亚型
# ============================================================================

def run_clustering(df):
    """
    使用GMM识别孤独-隔离的异质性亚型
    输入: 社会隔离指标 + 孤独感 + 社会参与 + 社会联系
    """
    from sklearn.mixture import GaussianMixture
    from sklearn.metrics import silhouette_score
    import matplotlib.pyplot as plt
    import seaborn as sns
    
    # 聚类特征（核心社会维度）
    cluster_vars = [
        'social_isolation_score',  # 结构性隔离(0-5)
        'lblonely3',               # 功能性孤独(3-9)
        'social_activity_count',   # 社会参与活跃度(0-13)
        'cntc', 'cntr', 'cntf',   # 三种社会联系
        'vol',                     # 志愿服务
    ]
    
    available_vars = [v for v in cluster_vars if v in df.columns]
    df_clust = df[available_vars].dropna().copy()
    print(f"\n聚类分析样本量: {len(df_clust)} (完整数据)")
    
    # 标准化
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(df_clust)
    
    # === 测试2-6组GMM ===
    results = []
    for k in range(2, 7):
        gmm = GaussianMixture(n_components=k, covariance_type='full',
                              random_state=42, n_init=20, max_iter=500)
        gmm.fit(X_scaled)
        labels = gmm.predict(X_scaled)
        sil = silhouette_score(X_scaled, labels)
        results.append({
            'k': k, 'BIC': gmm.bic(X_scaled), 
            'AIC': gmm.aic(X_scaled), 'Silhouette': sil,
            'min_group_pct': min(np.bincount(labels)) / len(labels) * 100
        })
        print(f"  k={k}: BIC={gmm.bic(X_scaled):.0f}, "
              f"Silhouette={sil:.3f}, 最小组比例={results[-1]['min_group_pct']:.1f}%")
    
    results_df = pd.DataFrame(results)
    
    # 绘制模型选择图
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))
    axes[0].plot(results_df['k'], results_df['BIC'], 'bo-', linewidth=2)
    axes[0].set_xlabel('Number of Clusters'); axes[0].set_ylabel('BIC')
    axes[0].set_title('(A) BIC')
    
    axes[1].plot(results_df['k'], results_df['AIC'], 'ro-', linewidth=2)
    axes[1].set_xlabel('Number of Clusters'); axes[1].set_ylabel('AIC')
    axes[1].set_title('(B) AIC')
    
    axes[2].plot(results_df['k'], results_df['Silhouette'], 'go-', linewidth=2)
    axes[2].set_xlabel('Number of Clusters'); axes[2].set_ylabel('Silhouette')
    axes[2].set_title('(C) Silhouette Score')
    
    plt.tight_layout()
    plt.savefig(FIGURES / 'S1_cluster_selection.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 选择最优k（综合BIC最低+组≥5%+轮廓系数）
    # 通常选4组
    optimal_k = results_df.loc[results_df['BIC'].idxmin(), 'k']
    # 如果最小组<5%，退回少一组
    if results_df.loc[results_df['k'] == optimal_k, 'min_group_pct'].values[0] < 5:
        optimal_k = optimal_k - 1
    optimal_k = int(optimal_k)
    print(f"\n选定组数: {optimal_k}")
    
    # 最终模型
    gmm_final = GaussianMixture(n_components=optimal_k, covariance_type='full',
                                random_state=42, n_init=20, max_iter=500)
    gmm_final.fit(X_scaled)
    labels = gmm_final.predict(X_scaled)
    probs = gmm_final.predict_proba(X_scaled)
    
    # 各组特征描述
    df_clust['cluster'] = labels
    profile = df_clust.groupby('cluster').agg(['mean', 'std', 'count'])
    print("\n各亚型特征均值:")
    print(df_clust.groupby('cluster').mean().round(2))
    
    # 保存聚类结果
    df_clust.groupby('cluster').mean().to_csv(OUTPUT / 'cluster_profiles.csv')
    results_df.to_csv(OUTPUT / 'cluster_model_selection.csv', index=False)
    
    # 热图
    cluster_means = df_clust.groupby('cluster').mean()
    cluster_means_z = (cluster_means - cluster_means.mean()) / cluster_means.std()
    
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.heatmap(cluster_means_z.T, annot=cluster_means.T.round(2).values,
                fmt='', cmap='RdYlBu_r', center=0, linewidths=0.5,
                ax=ax, cbar_kws={'label': 'Z-score'})
    ax.set_xlabel('Subtype')
    ax.set_title('Social Isolation-Loneliness Subtype Profiles', fontweight='bold')
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig2_cluster_heatmap.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 将标签映射回原始df
    cluster_series = pd.Series(labels, index=df_clust.index, name='cluster')
    df = df.join(cluster_series, how='left')
    
    return df, optimal_k


# ============================================================================
# PART C: Random Survival Forest - 痴呆风险预测
# ============================================================================

def run_rsf(df, feature_list):
    """
    Random Survival Forest预测12年内痴呆发生
    返回: 模型, C-index, 特征重要性
    """
    from sksurv.ensemble import RandomSurvivalForest
    from sksurv.metrics import concordance_index_censored
    import matplotlib.pyplot as plt
    
    # 构建生存数据
    surv_cols = ['ever_dementia', 'dementia_time'] + feature_list
    df_surv = df[[c for c in surv_cols if c in df.columns]].copy()
    df_surv = df_surv.dropna(subset=['ever_dementia', 'dementia_time'])
    df_surv = df_surv[df_surv['dementia_time'] > 0]
    
    avail_features = [f for f in feature_list if f in df_surv.columns]
    X = df_surv[avail_features]
    
    print(f"\nRSF样本量: {len(df_surv)}")
    print(f"痴呆事件: {df_surv['ever_dementia'].sum()}")
    print(f"特征数: {len(avail_features)}")
    
    # 缺失值中位数填充
    imputer = SimpleImputer(strategy='median')
    X_imp = pd.DataFrame(imputer.fit_transform(X), columns=X.columns, index=X.index)
    
    # 结构化生存数组
    y = np.array([(bool(e), t) for e, t in 
                  zip(df_surv['ever_dementia'], df_surv['dementia_time'])],
                 dtype=[('event', bool), ('time', float)])
    
    # === 5折交叉验证 ===
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    c_indices = []
    
    for fold, (tr_idx, te_idx) in enumerate(cv.split(X_imp, df_surv['ever_dementia'])):
        X_tr, X_te = X_imp.iloc[tr_idx], X_imp.iloc[te_idx]
        y_tr, y_te = y[tr_idx], y[te_idx]
        
        rsf = RandomSurvivalForest(
            n_estimators=500, min_samples_split=10, min_samples_leaf=6,
            max_features='sqrt', random_state=42, n_jobs=-1
        )
        rsf.fit(X_tr, y_tr)
        
        pred = rsf.predict(X_te)
        ci = concordance_index_censored(y_te['event'], y_te['time'], pred)[0]
        c_indices.append(ci)
        print(f"  Fold {fold+1}: C-index = {ci:.4f}")
    
    mean_ci = np.mean(c_indices)
    std_ci = np.std(c_indices)
    print(f"\n平均C-index: {mean_ci:.4f} ± {std_ci:.4f}")
    
    # === 全样本最终模型 ===
    rsf_final = RandomSurvivalForest(
        n_estimators=1000, min_samples_split=10, min_samples_leaf=6,
        max_features='sqrt', random_state=42, n_jobs=-1
    )
    rsf_final.fit(X_imp, y)
    
    # 特征重要性(permutation)
    importances = pd.Series(rsf_final.feature_importances_, index=avail_features)
    importances = importances.sort_values(ascending=False)
    importances.to_csv(OUTPUT / 'rsf_feature_importance.csv')
    
    # Top 20特征图
    fig, ax = plt.subplots(figsize=(8, 8))
    top20 = importances.head(20)
    colors = ['#e74c3c' if 'iso' in f or 'lonely' in f or 'isolated' in f or 'cntc' in f 
              or 'cntr' in f or 'cntf' in f or 'social' in f
              else '#3498db' for f in top20.index]
    top20.plot(kind='barh', ax=ax, color=colors)
    ax.set_xlabel('Permutation Importance')
    ax.set_title('Top 20 Predictors of Dementia (Random Survival Forest)',
                fontweight='bold')
    ax.invert_yaxis()
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig3_rsf_importance.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 保存性能指标
    perf = pd.DataFrame({'fold': range(1, 6), 'c_index': c_indices})
    perf.loc[5] = ['Mean±SD', f"{mean_ci:.4f}±{std_ci:.4f}"]
    perf.to_csv(OUTPUT / 'rsf_performance.csv', index=False)
    
    return rsf_final, X_imp, y, importances


# ============================================================================
# PART D: SHAP解释 - 可修改因素贡献量化
# ============================================================================

def run_shap(rsf_model, X_imp, feature_groups):
    """
    SHAP分析揭示各社会因素对痴呆风险的贡献方向和大小
    """
    import shap
    import matplotlib.pyplot as plt
    
    # 随机采样1000人（SHAP计算密集）
    n_sample = min(1000, len(X_imp))
    X_sample = X_imp.sample(n=n_sample, random_state=42)
    
    print(f"\nSHAP分析样本: {n_sample}")
    
    # 使用permutation explainer（适用于生存模型）
    explainer = shap.Explainer(rsf_model.predict, X_sample)
    shap_values = explainer(X_sample)
    
    # === SHAP Summary Plot ===
    plt.figure(figsize=(10, 10))
    shap.summary_plot(shap_values, X_sample, show=False, max_display=25,
                     plot_size=None)
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig4_shap_summary.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # === SHAP Bar Plot (全局重要性) ===
    plt.figure(figsize=(8, 8))
    shap.plots.bar(shap_values, show=False, max_display=20)
    plt.tight_layout()
    plt.savefig(FIGURES / 'S2_shap_bar.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # === 按变量类别汇总SHAP ===
    category_shap = {}
    for cat_name, cat_vars in feature_groups.items():
        avail = [v for v in cat_vars if v in X_imp.columns]
        if avail:
            col_idx = [list(X_imp.columns).index(v) for v in avail]
            mean_abs_shap = np.abs(shap_values.values[:, col_idx]).mean()
            category_shap[cat_name] = mean_abs_shap
    
    cat_imp = pd.Series(category_shap).sort_values(ascending=False)
    cat_imp.to_csv(OUTPUT / 'shap_category_importance.csv')
    
    print("\n变量类别SHAP重要性排序:")
    for name, val in cat_imp.items():
        print(f"  {name}: {val:.4f}")
    
    # 类别柱状图
    fig, ax = plt.subplots(figsize=(8, 5))
    colors_cat = {'social_isolation': '#e74c3c', 'loneliness': '#c0392b',
                  'social_activity': '#e67e22', 'social_contact': '#f39c12',
                  'demographics': '#95a5a6', 'cognition_baseline': '#3498db',
                  'mental_health': '#9b59b6', 'chronic_disease': '#2ecc71',
                  'health_behavior': '#1abc9c', 'personality': '#34495e',
                  'physical_function': '#16a085', 'sensory': '#7f8c8d',
                  'socioeconomic': '#bdc3c7'}
    bar_colors = [colors_cat.get(n, '#95a5a6') for n in cat_imp.index]
    cat_imp.plot(kind='bar', ax=ax, color=bar_colors)
    ax.set_ylabel('Mean |SHAP value|')
    ax.set_title('Variable Category Importance for Dementia Prediction',
                fontweight='bold')
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig5_shap_categories.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # === 关键变量依赖图 ===
    key_vars = ['lblonely3', 'social_isolation_score', 'social_activity_count', 'cog27']
    for var in key_vars:
        if var in X_sample.columns:
            plt.figure(figsize=(7, 5))
            shap.dependence_plot(var, shap_values.values, X_sample, show=False)
            plt.title(f'SHAP Dependence: {var}')
            plt.tight_layout()
            plt.savefig(FIGURES / f'S3_shap_dep_{var}.png', dpi=300, 
                       bbox_inches='tight')
            plt.close()
    
    return shap_values, cat_imp


# ============================================================================
# PART E: 亚型特异性生存分析 (KM + Cox)
# ============================================================================

def subtype_survival(df):
    """
    各聚类亚型的KM生存曲线和Cox回归
    """
    from lifelines import KaplanMeierFitter, CoxPHFitter
    import matplotlib.pyplot as plt
    
    df_surv = df.dropna(subset=['cluster', 'ever_dementia', 'dementia_time'])
    df_surv = df_surv[df_surv['dementia_time'] > 0].copy()
    
    n_clusters = int(df_surv['cluster'].nunique())
    print(f"\n亚型数: {n_clusters}")
    print(f"各组样本量:")
    print(df_surv['cluster'].value_counts().sort_index())
    
    # === KM曲线 (痴呆) ===
    fig, ax = plt.subplots(figsize=(9, 6))
    kmf = KaplanMeierFitter()
    colors = ['#2ecc71', '#3498db', '#f39c12', '#e74c3c', '#9b59b6']
    
    for grp in sorted(df_surv['cluster'].unique()):
        mask = df_surv['cluster'] == grp
        grp_int = int(grp)
        kmf.fit(df_surv.loc[mask, 'dementia_time'],
               event_observed=df_surv.loc[mask, 'ever_dementia'],
               label=f'Subtype {grp_int + 1} (n={mask.sum()})')
        kmf.plot_survival_function(ax=ax, color=colors[grp_int % len(colors)],
                                   ci_show=True, linewidth=2)
    
    ax.set_xlabel('Years from Baseline (2008)', fontsize=11)
    ax.set_ylabel('Dementia-Free Probability', fontsize=11)
    ax.set_title('Dementia-Free Survival by Isolation-Loneliness Subtype',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='lower left')
    ax.set_ylim(0.5, 1.02)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig6_km_dementia_subtype.png', dpi=300, 
                bbox_inches='tight')
    plt.close()
    
    # === KM曲线 (死亡) ===
    df_death = df.dropna(subset=['cluster', 'ever_died', 'death_time'])
    df_death = df_death[df_death['death_time'] > 0].copy()
    
    fig, ax = plt.subplots(figsize=(9, 6))
    for grp in sorted(df_death['cluster'].unique()):
        mask = df_death['cluster'] == grp
        grp_int = int(grp)
        kmf.fit(df_death.loc[mask, 'death_time'],
               event_observed=df_death.loc[mask, 'ever_died'],
               label=f'Subtype {grp_int + 1} (n={mask.sum()})')
        kmf.plot_survival_function(ax=ax, color=colors[grp_int % len(colors)],
                                   ci_show=True, linewidth=2)
    
    ax.set_xlabel('Years from Baseline (2008)', fontsize=11)
    ax.set_ylabel('Survival Probability', fontsize=11)
    ax.set_title('All-Cause Mortality by Isolation-Loneliness Subtype',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='lower left')
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig7_km_death_subtype.png', dpi=300, 
                bbox_inches='tight')
    plt.close()
    
    # === Cox回归 (调整协变量) ===
    cox_vars = ['dementia_time', 'ever_dementia', 'cluster',
                'baseline_age', 'ragender', 'raedyrs', 'cesd', 
                'chronic_count', 'cog27']
    cox_df = df_surv[[v for v in cox_vars if v in df_surv.columns]].dropna()
    
    # 哑变量编码
    cluster_dummies = pd.get_dummies(cox_df['cluster'].astype(int), 
                                    prefix='subtype', drop_first=True)
    cox_df = pd.concat([cox_df.drop('cluster', axis=1), cluster_dummies], axis=1)
    
    cph = CoxPHFitter()
    cph.fit(cox_df, duration_col='dementia_time', event_col='ever_dementia')
    
    print("\nCox回归 (各亚型 vs 参照组, 调整协变量):")
    print(cph.summary[['coef', 'exp(coef)', 'p', 
                       'exp(coef) lower 95%', 'exp(coef) upper 95%']])
    cph.summary.to_csv(OUTPUT / 'cox_subtype_dementia.csv')
    
    # Cox森林图
    fig, ax = plt.subplots(figsize=(8, 4))
    cph.plot(ax=ax, hazard_ratios=True)
    ax.set_title('Adjusted Hazard Ratios for Dementia', fontweight='bold')
    ax.axvline(x=1, color='black', linestyle='--', linewidth=0.8)
    plt.tight_layout()
    plt.savefig(FIGURES / 'Fig8_cox_forest.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    return cph


# ============================================================================
# PART F: XGBoost验证 + 模型比较
# ============================================================================

def run_xgboost(df, feature_list):
    """
    XGBoost分类模型作为RSF的验证/比较
    """
    from xgboost import XGBClassifier
    from sklearn.metrics import roc_auc_score, roc_curve
    import matplotlib.pyplot as plt
    
    avail = [f for f in feature_list if f in df.columns]
    df_cls = df[['ever_dementia'] + avail].dropna(subset=['ever_dementia'])
    
    X = df_cls[avail]
    y = df_cls['ever_dementia'].astype(int)
    
    imputer = SimpleImputer(strategy='median')
    X_imp = pd.DataFrame(imputer.fit_transform(X), columns=X.columns, index=X.index)
    
    print(f"\nXGBoost样本: {len(df_cls)}, 正例: {y.sum()} ({y.mean()*100:.1f}%)")
    
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    aucs = []
    all_fpr, all_tpr = [], []
    
    for fold, (tr, te) in enumerate(cv.split(X_imp, y)):
        Xtr, Xte = X_imp.iloc[tr], X_imp.iloc[te]
        ytr, yte = y.iloc[tr], y.iloc[te]
        
        xgb = XGBClassifier(
            n_estimators=500, max_depth=5, learning_rate=0.05,
            subsample=0.8, colsample_bytree=0.8,
            scale_pos_weight=(ytr==0).sum()/(ytr==1).sum(),
            random_state=42, eval_metric='auc',
            early_stopping_rounds=50, use_label_encoder=False
        )
        xgb.fit(Xtr, ytr, eval_set=[(Xte, yte)], verbose=False)
        
        prob = xgb.predict_proba(Xte)[:, 1]
        auc = roc_auc_score(yte, prob)
        aucs.append(auc)
        
        fpr, tpr, _ = roc_curve(yte, prob)
        all_fpr.append(fpr); all_tpr.append(tpr)
        print(f"  Fold {fold+1}: AUC = {auc:.4f}")
    
    print(f"\n平均AUC: {np.mean(aucs):.4f} ± {np.std(aucs):.4f}")
    
    # ROC曲线
    fig, ax = plt.subplots(figsize=(7, 6))
    for i in range(5):
        ax.plot(all_fpr[i], all_tpr[i], alpha=0.3, color='#3498db')
    ax.plot([0,1], [0,1], 'k--', lw=1)
    ax.set_xlabel('False Positive Rate')
    ax.set_ylabel('True Positive Rate')
    ax.set_title(f'XGBoost ROC (Mean AUC={np.mean(aucs):.3f}±{np.std(aucs):.3f})',
                fontweight='bold')
    ax.legend([f'Mean AUC = {np.mean(aucs):.3f}'], loc='lower right')
    plt.tight_layout()
    plt.savefig(FIGURES / 'S4_xgboost_roc.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    return aucs


# ============================================================================
# MAIN: 按顺序执行全部分析
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  ML Analysis: Social Isolation-Loneliness & Dementia")
    print("  Input: HRS_ML_dataset.csv (from Stata Step 01)")
    print("=" * 70)
    
    # A. 数据加载
    print("\n[A] Loading data...")
    df = load_data()
    groups = define_feature_groups()
    feature_list = prepare_features(df, groups)
    
    # B. 聚类
    print("\n[B] Clustering analysis...")
    df, n_clusters = run_clustering(df)
    
    # C. Random Survival Forest
    print("\n[C] Random Survival Forest...")
    rsf_model, X_imp, y_surv, importances = run_rsf(df, feature_list)
    
    # D. SHAP
    print("\n[D] SHAP analysis...")
    shap_values, cat_imp = run_shap(rsf_model, X_imp, groups)
    
    # E. 亚型生存分析
    print("\n[E] Subtype survival analysis...")
    if 'cluster' in df.columns and df['cluster'].notna().sum() > 100:
        cph = subtype_survival(df)
    else:
        print("  跳过: 聚类标签缺失过多")
    
    # F. XGBoost验证
    print("\n[F] XGBoost validation...")
    aucs = run_xgboost(df, feature_list)
    
    # 保存聚类结果到CSV（供Stata后续使用）
    if 'cluster' in df.columns:
        df[['hhidpn', 'cluster']].dropna().to_csv(
            OUTPUT / 'cluster_assignments.csv', index=False)
    
    # ===== 汇总报告 =====
    print("\n" + "=" * 70)
    print("  分析完成！结果汇总:")
    print(f"  - 识别亚型数: {n_clusters}")
    print(f"  - RSF C-index: {np.mean([concordance_index_censored]) if 'c_indices' in dir() else 'see output'}")
    print(f"  - XGBoost AUC: {np.mean(aucs):.4f}")
    print(f"  - SHAP最重要类别: {cat_imp.index[0]}")
    print(f"  - 输出路径: {OUTPUT}")
    print(f"  - 图表路径: {FIGURES}")
    print("=" * 70)
    print("\n下一步: 运行 analysis_05_mendelian_randomization.R")
