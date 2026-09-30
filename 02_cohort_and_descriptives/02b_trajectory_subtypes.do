********************************************************************************
* Project: 社会隔离/孤独感异质性亚型与痴呆/死亡
* File: analysis_02_trajectory_analysis.do
* Purpose: Part 1 - 潜在类别增长模型(LCGM)识别孤独-隔离纵向轨迹亚型
* Data: HRS 2008-2020 (Wave 9-15)
* Author: [Your Name]
* Date: 2026-07
* Note: 需要安装 traj 包 (net install traj, from(https://www.andrew.cmu.edu/user/bjones/traj))
********************************************************************************

clear all
set more off
set maxvar 120000

global root= "E:/HRS_美国"
global analysis= "$root/Analysis"

use "$analysis/HRS_analysis_long.dta", clear

********************************************************************************
* STEP 1: 准备轨迹分析数据（宽格式）
********************************************************************************

* 保留关键变量
keep hhidpn wave lblonely3 social_isolation isolated lonely ///
    social_activity_count cntc cntr cntf ///
    baseline_age ragender race raeducl raedyrs cesd chronic_count

* 宽格式转换（每个变量一列/波次）
reshape wide lblonely3 social_isolation isolated lonely ///
    social_activity_count cntc cntr cntf cesd chronic_count, ///
    i(hhidpn) j(wave)

* 检查每个波次的观测数
foreach var in lblonely3 social_isolation {
    di "--- `var' 各波次非缺失数 ---"
    foreach w in 9 10 11 12 13 14 15 {
        count if `var'`w' != .
    }
}

********************************************************************************
* STEP 2: 组基轨迹模型(GBTM) - 孤独感轨迹
* 使用 traj 命令
********************************************************************************

* 孤独感轨迹（lblonely3，范围3-9，用正态分布/censored normal）
* 测试2-6组模型，选择最优

* --- 2组模型 ---
traj, var(lblonely39 lblonely310 lblonely311 lblonely312 lblonely313 lblonely314 lblonely315) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(3) max(9) order(2 2)
* 保存BIC
scalar bic_2 = e(BIC_n_subjects)

* --- 3组模型 ---
traj, var(lblonely39 lblonely310 lblonely311 lblonely312 lblonely313 lblonely314 lblonely315) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(3) max(9) order(2 2 2)
scalar bic_3 = e(BIC_n_subjects)

* --- 4组模型 ---
traj, var(lblonely39 lblonely310 lblonely311 lblonely312 lblonely313 lblonely314 lblonely315) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(3) max(9) order(2 2 2 2)
scalar bic_4 = e(BIC_n_subjects)

* --- 5组模型 ---
traj, var(lblonely39 lblonely310 lblonely311 lblonely312 lblonely313 lblonely314 lblonely315) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(3) max(9) order(2 2 2 2 2)
scalar bic_5 = e(BIC_n_subjects)

* 比较BIC
di "BIC comparison:"
di "2-group: " bic_2
di "3-group: " bic_3
di "4-group: " bic_4
di "5-group: " bic_5

* 选择最优模型后，绘图
trajplot, xtitle("Wave") ytitle("UCLA Loneliness Score (3-9)") ///
    ci title("Loneliness Trajectories")
graph export "$analysis/figures/loneliness_trajectories.png", replace

* 保存轨迹分组
gen lonely_traj_group = _traj_Group
label var lonely_traj_group "孤独感轨迹组"

********************************************************************************
* STEP 3: 组基轨迹模型 - 社会隔离轨迹
********************************************************************************

* 社会隔离轨迹（social_isolation，0-5，用正态分布）

* --- 4组模型（通常最优） ---
traj, var(social_isolation9 social_isolation10 social_isolation11 ///
    social_isolation12 social_isolation13 social_isolation14 social_isolation15) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(0) max(5) order(2 2 2 2)

trajplot, xtitle("Wave") ytitle("Social Isolation Score (0-5)") ///
    ci title("Social Isolation Trajectories")
graph export "$analysis/figures/isolation_trajectories.png", replace

gen isolation_traj_group = _traj_Group
label var isolation_traj_group "社会隔离轨迹组"

********************************************************************************
* STEP 4: 联合轨迹分析 - 双轨迹模型
* 同时建模孤独感和社会隔离的联合轨迹
********************************************************************************

* 双轨迹模型（4组）
traj, var(lblonely39 lblonely310 lblonely311 lblonely312 lblonely313 lblonely314 lblonely315) ///
    indep(t9 t10 t11 t12 t13 t14 t15) ///
    model(cnorm) min(3) max(9) order(2 2 2 2) ///
    var2(social_isolation9 social_isolation10 social_isolation11 ///
    social_isolation12 social_isolation13 social_isolation14 social_isolation15) ///
    indep2(t9 t10 t11 t12 t13 t14 t15) ///
    model2(cnorm) min2(0) max2(5) order2(2 2 2 2)

trajplot, xtitle("Wave") ytitle("Score") ///
    title("Joint Trajectory: Loneliness and Social Isolation")
graph export "$analysis/figures/joint_trajectories.png", replace

gen joint_traj_group = _traj_Group
label var joint_traj_group "联合轨迹组"

********************************************************************************
* STEP 5: 轨迹分组的描述性分析
********************************************************************************

* 各组基线特征比较
tabstat baseline_age raedyrs cesd9 chronic_count9 social_activity_count9, ///
    by(joint_traj_group) stat(mean sd) col(stat)

tab joint_traj_group ragender, row chi2
tab joint_traj_group raeducl, row chi2
tab joint_traj_group race, row chi2

* 各组平均后验概率（分组质量指标，应>0.7）
tabstat _traj_ProbG1 _traj_ProbG2 _traj_ProbG3 _traj_ProbG4, ///
    by(joint_traj_group) stat(mean)

********************************************************************************
* STEP 6: 保存轨迹分组结果
********************************************************************************

* 转回长格式用于后续生存分析
keep hhidpn lonely_traj_group isolation_traj_group joint_traj_group ///
    baseline_age ragender race raeducl raedyrs

save "$analysis/trajectory_groups.dta", replace

* 合并回主数据集
use "$analysis/HRS_analysis_long.dta", clear
merge m:1 hhidpn using "$analysis/trajectory_groups.dta", nogen

save "$analysis/HRS_analysis_long_with_traj.dta", replace

di as text "======================================"
di as text "轨迹分析完成！"
di as text "请检查figures文件夹中的轨迹图"
di as text "======================================"
