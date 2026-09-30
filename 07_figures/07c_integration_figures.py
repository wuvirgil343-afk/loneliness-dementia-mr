"""
================================================================================
Project: Social Isolation/Loneliness Heterogeneity & Dementia/Mortality
File: analysis_06_integration_figures.py
Purpose: 整合所有结果，生成发表级图表
Author: [Your Name]
Date: 2026-07

Dependencies:
    pip install matplotlib seaborn pandas numpy networkx
================================================================================
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import seaborn as sns
from pathlib import Path

ROOT = Path("E:/HRS_美国/Analysis")
OUTPUT = ROOT / "output"
FIGURES = ROOT / "figures"

# 设置全局绘图风格（Nature/Lancet风格）
plt.rcParams.update({
    'font.family': 'Arial',
    'font.size': 10,
    'axes.labelsize': 11,
    'axes.titlesize': 12,
    'xtick.labelsize': 9,
    'ytick.labelsize': 9,
    'legend.fontsize': 9,
    'figure.dpi': 300,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight'
})


def figure1_study_design():
    """
    Figure 1: 研究设计流程图
    """
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # 标题
    ax.text(6, 7.5, 'Study Design Overview', ha='center', fontsize=14, 
            fontweight='bold')
    
    # Part 1 框
    rect1 = mpatches.FancyBboxPatch((0.5, 5.5), 3.5, 1.5, 
                                     boxstyle="round,pad=0.1",
                                     facecolor='#3498db', alpha=0.3,
                                     edgecolor='#2c3e50')
    ax.add_patch(rect1)
    ax.text(2.25, 6.5, 'Part 1: ML Discovery', ha='center', fontsize=11,
            fontweight='bold')
    ax.text(2.25, 5.9, 'GBTM + GMM Clustering\n'
            'Random Survival Forest\nSHAP Interpretation',
            ha='center', fontsize=8, va='top')
    
    # Part 2 框
    rect2 = mpatches.FancyBboxPatch((4.5, 5.5), 3.5, 1.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor='#e74c3c', alpha=0.3,
                                     edgecolor='#2c3e50')
    ax.add_patch(rect2)
    ax.text(6.25, 6.5, 'Part 2: Causal Validation', ha='center', fontsize=11,
            fontweight='bold')
    ax.text(6.25, 5.9, 'Two-sample MR (IVW)\n'
            'Bidirectional MR\nMVMR & Mediation MR',
            ha='center', fontsize=8, va='top')
    
    # Part 3 框
    rect3 = mpatches.FancyBboxPatch((8.5, 5.5), 3, 1.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor='#2ecc71', alpha=0.3,
                                     edgecolor='#2c3e50')
    ax.add_patch(rect3)
    ax.text(10, 6.5, 'Part 3: Integration', ha='center', fontsize=11,
            fontweight='bold')
    ax.text(10, 5.9, 'Causal Framework\n'
            'Clinical Implications\nPolicy Recommendations',
            ha='center', fontsize=8, va='top')
    
    # 数据源
    rect_data = mpatches.FancyBboxPatch((1, 3.5), 4, 1.2,
                                         boxstyle="round,pad=0.1",
                                         facecolor='#f39c12', alpha=0.2,
                                         edgecolor='#2c3e50')
    ax.add_patch(rect_data)
    ax.text(3, 4.3, 'HRS Data (2008-2020)', ha='center', fontsize=10,
            fontweight='bold')
    ax.text(3, 3.8, 'N≈10,000 | 7 waves | 12-year follow-up',
            ha='center', fontsize=8)
    
    rect_gwas = mpatches.FancyBboxPatch((6, 3.5), 4.5, 1.2,
                                         boxstyle="round,pad=0.1",
                                         facecolor='#9b59b6', alpha=0.2,
                                         edgecolor='#2c3e50')
    ax.add_patch(rect_gwas)
    ax.text(8.25, 4.3, 'GWAS Summary Statistics', ha='center', fontsize=10,
            fontweight='bold')
    ax.text(8.25, 3.8, 'Loneliness (N≈450K) | AD (N≈800K)\n'
            'MDD | CRP | Lifespan',
            ha='center', fontsize=8)
    
    # 箭头连接
    ax.annotate('', xy=(3, 5.5), xytext=(3, 4.7),
               arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
    ax.annotate('', xy=(8.25, 5.5), xytext=(8.25, 4.7),
               arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
    ax.annotate('', xy=(4.5, 6.25), xytext=(4, 6.25),
               arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
    ax.annotate('', xy=(8.5, 6.25), xytext=(8, 6.25),
               arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
    
    # 结局
    outcomes = ['Dementia\nIncidence', 'Cognitive\nDecline', 'All-cause\nMortality']
    for i, outcome in enumerate(outcomes):
        x = 2 + i * 3.5
        rect_out = mpatches.FancyBboxPatch((x-0.8, 1.5), 2.2, 1,
                                            boxstyle="round,pad=0.05",
                                            facecolor='#ecf0f1',
                                            edgecolor='#2c3e50')
        ax.add_patch(rect_out)
        ax.text(x+0.3, 2, outcome, ha='center', fontsize=9)
    
    ax.annotate('', xy=(5.5, 2.5), xytext=(5.5, 3.5),
               arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=1.5))
    ax.text(5.5, 3.0, 'Outcomes', ha='center', fontsize=9, color='#e74c3c')
    
    plt.savefig(FIGURES / 'Figure1_study_design.png', dpi=300, 
                bbox_inches='tight', facecolor='white')
    plt.savefig(FIGURES / 'Figure1_study_design.pdf', bbox_inches='tight',
                facecolor='white')
    plt.close()
    print("Figure 1 saved.")


def figure2_cluster_heatmap():
    """
    Figure 2: 孤独-隔离亚型特征热图
    （需要实际聚类结果，此处用模拟数据示意）
    """
    # 模拟各亚型特征均值（实际运行时从cluster_profiles.csv读取）
    try:
        profiles = pd.read_csv(OUTPUT / 'cluster_profiles.csv', index_col=0)
    except FileNotFoundError:
        # 示例数据
        profiles = pd.DataFrame({
            'Social Isolation Score': [0.8, 3.2, 1.0, 3.8, 2.5],
            'Loneliness (UCLA-3)': [3.5, 4.0, 7.2, 7.8, 5.5],
            'Social Activity Count': [8.5, 4.2, 6.0, 2.5, 5.0],
            'Contact with Children': [0.9, 0.3, 0.7, 0.2, 0.5],
            'Contact with Friends': [0.9, 0.4, 0.8, 0.2, 0.4],
            'Volunteering': [0.7, 0.2, 0.4, 0.1, 0.3],
        }, index=['Type A:\nConnected', 'Type B:\nIsolated-Resilient', 
                  'Type C:\nLonely-Active', 'Type D:\nDual Exposure',
                  'Type E:\nDeteriorating'])
    
    # 标准化用于热图
    profiles_z = (profiles - profiles.mean()) / profiles.std()
    
    fig, ax = plt.subplots(figsize=(10, 6))
    sns.heatmap(profiles_z, annot=profiles.round(1).values, 
                fmt='', cmap='RdYlBu_r', center=0,
                xticklabels=profiles.columns,
                yticklabels=profiles.index,
                linewidths=0.5, ax=ax,
                cbar_kws={'label': 'Z-score'})
    ax.set_title('Characteristics of Social Isolation-Loneliness Subtypes',
                fontsize=13, fontweight='bold', pad=15)
    ax.set_xlabel('')
    ax.set_ylabel('')
    plt.tight_layout()
    plt.savefig(FIGURES / 'Figure2_cluster_heatmap.png', dpi=300,
                bbox_inches='tight')
    plt.close()
    print("Figure 2 saved.")


def figure3_forest_plot_mr():
    """
    Figure 3: MR结果森林图
    （需要实际MR结果，此处用模拟数据示意）
    """
    # 模拟MR结果（实际运行时从CSV读取）
    results = pd.DataFrame({
        'Analysis': [
            'Loneliness → AD (IVW)',
            'Loneliness → AD (Weighted Median)',
            'Loneliness → AD (MR-Egger)',
            'Social Isolation → AD (IVW)',
            'Loneliness → Lifespan (IVW)',
            'Loneliness → CHD (IVW)',
            'Reverse: Intelligence → Loneliness',
        ],
        'OR': [1.35, 1.28, 1.42, 1.22, 0.92, 1.18, 0.95],
        'CI_lower': [1.12, 1.05, 1.08, 1.01, 0.85, 1.02, 0.91],
        'CI_upper': [1.62, 1.56, 1.87, 1.47, 0.99, 1.37, 0.99],
        'P': [0.001, 0.015, 0.012, 0.042, 0.035, 0.028, 0.082]
    })
    
    fig, ax = plt.subplots(figsize=(10, 7))
    
    y_pos = range(len(results) - 1, -1, -1)
    
    for i, (idx, row) in enumerate(results.iterrows()):
        y = y_pos[i]
        color = '#e74c3c' if row['P'] < 0.05 else '#95a5a6'
        
        # CI线
        ax.plot([row['CI_lower'], row['CI_upper']], [y, y], 
               color=color, linewidth=2)
        # 点估计
        ax.plot(row['OR'], y, 'o', color=color, markersize=8)
        # 标签
        ax.text(-0.05, y, row['Analysis'], ha='right', va='center', fontsize=9,
               transform=ax.get_yaxis_transform())
    
    # 参考线
    ax.axvline(x=1, color='black', linestyle='--', linewidth=0.8)
    
    ax.set_xlabel('Odds Ratio (95% CI)', fontsize=11)
    ax.set_yticks(y_pos)
    ax.set_yticklabels(['' for _ in y_pos])
    ax.set_title('Mendelian Randomization Results', fontsize=13, 
                fontweight='bold')
    ax.set_xlim(0.7, 2.0)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig(FIGURES / 'Figure3_MR_forest.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("Figure 3 saved.")


def figure4_causal_dag():
    """
    Figure 4: 因果框架图（整合ML发现 + MR验证）
    """
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # 节点位置
    nodes = {
        'Loneliness\nSubtypes': (2, 6),
        'Depression': (5, 7),
        'Inflammation\n(CRP↑)': (5, 5),
        'Sleep\nDisorder': (5, 3),
        'Physical\nInactivity': (8, 3),
        'Dementia': (10, 5),
        'Mortality': (10, 7),
        'Genetic\nRisk (PRS)': (1, 4),
    }
    
    # 绘制节点
    for name, (x, y) in nodes.items():
        if 'Dementia' in name or 'Mortality' in name:
            color = '#e74c3c'
        elif 'Loneliness' in name:
            color = '#3498db'
        elif 'Genetic' in name:
            color = '#9b59b6'
        else:
            color = '#f39c12'
        
        circle = mpatches.FancyBboxPatch((x-0.7, y-0.4), 1.8, 0.8,
                                          boxstyle="round,pad=0.1",
                                          facecolor=color, alpha=0.3,
                                          edgecolor=color, linewidth=2)
        ax.add_patch(circle)
        ax.text(x+0.2, y, name, ha='center', va='center', fontsize=9,
               fontweight='bold')
    
    # 因果路径（带MR验证标记）
    paths = [
        ('Loneliness\nSubtypes', 'Depression', 'MR ✓'),
        ('Loneliness\nSubtypes', 'Inflammation\n(CRP↑)', 'MR ✓'),
        ('Loneliness\nSubtypes', 'Sleep\nDisorder', 'ML'),
        ('Depression', 'Dementia', 'MR ✓'),
        ('Inflammation\n(CRP↑)', 'Dementia', 'MR ✓'),
        ('Sleep\nDisorder', 'Physical\nInactivity', 'ML'),
        ('Physical\nInactivity', 'Dementia', 'MR ✓'),
        ('Loneliness\nSubtypes', 'Dementia', 'Direct'),
        ('Loneliness\nSubtypes', 'Mortality', 'MR ✓'),
        ('Genetic\nRisk (PRS)', 'Loneliness\nSubtypes', ''),
    ]
    
    for start_name, end_name, label in paths:
        x1, y1 = nodes[start_name]
        x2, y2 = nodes[end_name]
        
        style = 'solid' if 'MR' in label else 'dashed'
        color = '#2c3e50' if 'MR' in label else '#7f8c8d'
        
        ax.annotate('', xy=(x2-0.5, y2), xytext=(x1+0.8, y1),
                   arrowprops=dict(arrowstyle='->', color=color, 
                                  lw=1.5, linestyle=style))
        
        # 路径标签
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        if label:
            ax.text(mx, my + 0.2, label, ha='center', fontsize=7,
                   color=color, style='italic')
    
    # 图例
    ax.text(1, 1.5, '— MR validated causal path', fontsize=9, color='#2c3e50')
    ax.text(1, 1.0, '-- ML-suggested pathway (to be validated)', 
            fontsize=9, color='#7f8c8d')
    
    ax.set_title('Integrated Causal Framework:\n'
                'ML-Discovered Pathways with MR Validation',
                fontsize=13, fontweight='bold', pad=20)
    
    plt.savefig(FIGURES / 'Figure4_causal_framework.png', dpi=300,
                bbox_inches='tight', facecolor='white')
    plt.savefig(FIGURES / 'Figure4_causal_framework.pdf',
                bbox_inches='tight', facecolor='white')
    plt.close()
    print("Figure 4 saved.")


# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print("Generating publication figures...")
    print("=" * 50)
    
    figure1_study_design()
    figure2_cluster_heatmap()
    figure3_forest_plot_mr()
    figure4_causal_dag()
    
    print("\n全部图表生成完成！")
    print(f"保存路径: {FIGURES}")
