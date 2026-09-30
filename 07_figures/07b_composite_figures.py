"""
生成期刊格式的多panel组合图
Composite Figure A: 观察性结果 (亚型热图 + KM + 竞争风险 + 轨迹)
Composite Figure B: 预测+因果 (特征重要性 + 时间AUC + 校准 + MR森林)
将已生成的单图拼合为组合图
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from pathlib import Path

FIG = Path(r"d:\kiroproject\原始数据\3. HRS  美国\HRS_美国\Analysis\figures")
plt.rcParams.update({'savefig.dpi': 300})

def panel(ax, imgpath, letter):
    if not imgpath.exists():
        ax.text(0.5, 0.5, f'{imgpath.name}\n(missing)', ha='center')
        ax.axis('off'); return
    img = mpimg.imread(imgpath)
    ax.imshow(img)
    ax.axis('off')
    ax.text(-0.02, 1.02, letter, transform=ax.transAxes, fontsize=18,
            fontweight='bold', va='top', ha='right')

# ===== Composite A: 观察性证据 =====
fig, axes = plt.subplots(2, 2, figsize=(16, 12))
panel(axes[0,0], FIG/'Fig2_cluster_heatmap.png', 'A')
panel(axes[0,1], FIG/'Fig5_km_dementia.png', 'B')
panel(axes[1,0], FIG/'Fig8_competing_risk_CIF.png', 'C')
panel(axes[1,1], FIG/'Fig6_trajectories.png', 'D')
fig.suptitle('Composite Figure 1. Observational evidence: '
             'subtypes, survival, competing risk, and trajectories',
             fontsize=15, fontweight='bold', y=0.99)
plt.tight_layout(rect=[0, 0, 1, 0.97])
plt.savefig(FIG/'Composite_Fig1_observational.png', dpi=200, bbox_inches='tight')
plt.close()
print("Composite_Fig1_observational.png saved")

# ===== Composite B: 预测 + 因果 =====
fig, axes = plt.subplots(2, 2, figsize=(16, 12))
panel(axes[0,0], FIG/'Fig3_rsf_importance.png', 'A')
panel(axes[0,1], FIG/'Fig9_time_auc.png', 'B')
panel(axes[1,0], FIG/'Fig10_calibration_10yr.png', 'C')
panel(axes[1,1], FIG/'Figure2_MR_forest_summary.png', 'D')
fig.suptitle('Composite Figure 2. Prediction and causation: '
             'feature importance, time-dependent AUC, calibration, and MR',
             fontsize=15, fontweight='bold', y=0.99)
plt.tight_layout(rect=[0, 0, 1, 0.97])
plt.savefig(FIG/'Composite_Fig2_prediction_MR.png', dpi=200, bbox_inches='tight')
plt.close()
print("Composite_Fig2_prediction_MR.png saved")

# ===== Composite C: MR诊断图 =====
mrdir = FIG.parent / "output" / "MR"
fig, axes = plt.subplots(2, 2, figsize=(15, 13))
panel(axes[0,0], mrdir/'MR_scatter.png', 'A')
panel(axes[0,1], mrdir/'MR_forest.png', 'B')
panel(axes[1,0], mrdir/'MR_funnel.png', 'C')
panel(axes[1,1], mrdir/'MR_leaveoneout.png', 'D')
fig.suptitle('Composite Figure 3. MR diagnostics for loneliness -> Alzheimer\'s: '
             'scatter, per-SNP forest, funnel, leave-one-out',
             fontsize=14, fontweight='bold', y=0.99)
plt.tight_layout(rect=[0, 0, 1, 0.97])
plt.savefig(FIG/'Composite_Fig3_MR_diagnostics.png', dpi=200, bbox_inches='tight')
plt.close()
print("Composite_Fig3_MR_diagnostics.png saved")

print("\n组合图全部生成完成!")
