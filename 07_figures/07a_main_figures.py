"""
================================================================================
生成论文主图 (整合观察性 + 预测 + MR因果结果)
Figure 1: 研究设计与因果框架
Figure 2: MR森林图 (关联-因果分歧的核心图)
================================================================================
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from pathlib import Path

FIG = Path(r"d:\kiroproject\原始数据\3. HRS  美国\HRS_美国\Analysis\figures")
FIG.mkdir(exist_ok=True)

plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10,
                     'savefig.dpi': 300, 'savefig.bbox': 'tight'})

# ============================================================
# Figure 1: 因果框架图 (整合三部分证据)
# ============================================================
fig, ax = plt.subplots(figsize=(13, 8))
ax.set_xlim(0, 13); ax.set_ylim(0, 9); ax.axis('off')
ax.text(6.5, 8.5, 'Loneliness/Social Isolation and Dementia:\n'
        'Observational Association vs Genetic Causation',
        ha='center', fontsize=14, fontweight='bold')

def box(x, y, w, h, text, fc, ec='#2c3e50', fs=9, bold=True):
    r = mpatches.FancyBboxPatch((x-w/2, y-h/2), w, h,
                                boxstyle="round,pad=0.08", facecolor=fc,
                                alpha=0.85, edgecolor=ec, linewidth=1.5)
    ax.add_patch(r)
    ax.text(x, y, text, ha='center', va='center', fontsize=fs,
            fontweight='bold' if bold else 'normal')

# 暴露
box(2, 6, 2.6, 1.0, 'Loneliness /\nSocial Isolation', '#e74c3c', fs=10)
# 结局
box(11, 6, 2.4, 1.0, "Dementia /\nAlzheimer's", '#3498db', fs=10)
# 中介
box(6.5, 7.3, 2.2, 0.8, 'Depression', '#f39c12', fs=9)
box(6.5, 4.7, 2.2, 0.8, 'Inflammation\n(CRP)', '#f39c12', fs=9)
# 认知(反向)
box(6.5, 2.5, 2.4, 0.9, 'Cognitive Ability /\nIntelligence', '#9b59b6', fs=9)

# 观察性关联 (粗红箭头)
ax.annotate('', xy=(9.8, 6), xytext=(3.3, 6),
            arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=3))
ax.text(6.5, 6.2, 'Observational: HR=1.52 (P<0.001)', ha='center',
        fontsize=9, color='#c0392b', fontweight='bold')
ax.text(6.5, 5.75, 'MR (direct): OR=1.00 (P=0.75)  \u2717 NO causal',
        ha='center', fontsize=9, color='#7f8c8d', style='italic')

# 中介路径1: 孤独->抑郁 (显著) ->AD (不显著)
ax.annotate('', xy=(5.5, 7.2), xytext=(2.6, 6.4),
            arrowprops=dict(arrowstyle='->', color='#27ae60', lw=2))
ax.text(3.8, 7.15, 'OR=10.97**', ha='center', fontsize=7.5, color='#27ae60')
ax.annotate('', xy=(10.0, 6.4), xytext=(7.6, 7.2),
            arrowprops=dict(arrowstyle='->', color='#bdc3c7', lw=1.5,
                            linestyle='dashed'))
ax.text(9.0, 7.15, 'OR=1.00 (ns)', ha='center', fontsize=7.5, color='#95a5a6')

# 中介路径2: 孤独->CRP (ns) ->AD
ax.annotate('', xy=(5.5, 4.8), xytext=(2.6, 5.6),
            arrowprops=dict(arrowstyle='->', color='#bdc3c7', lw=1.5,
                            linestyle='dashed'))
ax.text(3.8, 5.0, 'ns', ha='center', fontsize=7.5, color='#95a5a6')
ax.annotate('', xy=(10.0, 5.6), xytext=(7.6, 4.8),
            arrowprops=dict(arrowstyle='->', color='#bdc3c7', lw=1.5,
                            linestyle='dashed'))

# 反向因果: 认知->孤独 (显著, 蓝箭头向上)
ax.annotate('', xy=(1.8, 5.5), xytext=(5.4, 2.6),
            arrowprops=dict(arrowstyle='->', color='#8e44ad', lw=2.5))
ax.text(3.2, 3.6, 'Intelligence\u2192Loneliness\nOR=0.98 (P=0.004)**',
        ha='center', fontsize=8, color='#8e44ad', fontweight='bold')
# 认知->痴呆(临床已知)
ax.annotate('', xy=(10.3, 5.5), xytext=(7.7, 2.6),
            arrowprops=dict(arrowstyle='->', color='#8e44ad', lw=1.5,
                            linestyle='dotted'))

# 图例
ax.text(0.5, 1.0, 'Solid green = significant causal | Dashed grey = non-significant | '
        'Purple = reverse causation', fontsize=8, color='#555')
ax.text(0.5, 0.5, '** P<0.01; ns = not significant. '
        'Interpretation: observed loneliness-dementia link likely reflects '
        'reverse causation (cognitive decline \u2192 social withdrawal).',
        fontsize=8, color='#555', style='italic')

plt.savefig(FIG / 'Figure1_causal_framework.png', dpi=300, bbox_inches='tight',
            facecolor='white')
plt.close()
print("Figure1_causal_framework.png saved")

# ============================================================
# Figure 2: MR汇总森林图 (所有因果路径)
# ============================================================
fig, ax = plt.subplots(figsize=(10, 6))

# 真实MR结果 (IVW, from output/MR)
rows = [
    ('Loneliness \u2192 Dementia (direct)',        1.00, 0.99, 1.01, 0.75, False),
    ('Intelligence \u2192 Loneliness (reverse)',   0.98, 0.97, 0.99, 0.004, True),
    ('Loneliness \u2192 Depression',              10.97, 3.59, 33.55, 2.7e-5, True),
    ('Loneliness \u2192 CRP',                      1.41, 0.75, 2.64, 0.29, False),
    ('Depression \u2192 Dementia',                 1.00, 0.999, 1.001, 0.56, False),
    ('CRP \u2192 Dementia',                        0.997, 0.996, 0.999, 0.0004, True),
]

y = np.arange(len(rows))[::-1]
for i, (lab, orr, lo, hi, p, sig) in enumerate(rows):
    yy = y[i]
    color = '#e74c3c' if sig else '#95a5a6'
    # log scale for wide CIs
    ax.plot([lo, hi], [yy, yy], color=color, lw=2)
    ax.plot(orr, yy, 'o', color=color, markersize=9)
    ax.text(0.02, yy, lab, transform=ax.get_yaxis_transform(),
            ha='right', va='center', fontsize=9)
    ptxt = f'P={p:.0e}' if p < 0.01 else f'P={p:.2f}'
    ax.text(1.02, yy, f'OR={orr:.2f}, {ptxt}',
            transform=ax.get_yaxis_transform(), ha='left', va='center',
            fontsize=8, color=color)

ax.axvline(1, color='black', linestyle='--', lw=0.8)
ax.set_xscale('log')
ax.set_xlim(0.9, 40)
ax.set_xlabel('Odds Ratio (log scale, 95% CI)')
ax.set_yticks([])
ax.set_title('Mendelian Randomization: Causal Pathways (IVW)',
             fontweight='bold', fontsize=13)
for s in ['top', 'right', 'left']:
    ax.spines[s].set_visible(False)
plt.tight_layout()
plt.savefig(FIG / 'Figure2_MR_forest_summary.png', dpi=300, bbox_inches='tight',
            facecolor='white')
plt.close()
print("Figure2_MR_forest_summary.png saved")
print("\n主图生成完成!")
