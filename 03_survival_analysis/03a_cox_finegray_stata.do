********************************************************************************
* Project: 社会隔离/孤独感异质性亚型与痴呆/死亡
* File: analysis_03_survival_analysis.do
* Purpose: Part 1补充 - Cox回归与竞争风险模型（传统流行病学验证）
* Data: HRS 2008-2020 (Wave 9-15)
* Author: [Your Name]
* Date: 2026-07
********************************************************************************

clear all
set more off
set maxvar 120000

global root= "E:/HRS_美国"
global analysis= "$root/Analysis"

use "$analysis/HRS_analysis_long_with_traj.dta", clear

********************************************************************************
* STEP 1: 设定生存分析数据
********************************************************************************

* 使用基线数据
keep if wave == 9 | (wave > 9 & (dementia_onset == 1 | iwstat == 1))

* 去重保留每人最早的事件
bysort hhidpn (wave): keep if _n == 1 | (dementia_onset == 1 & wave == wave[_n]) | (iwstat == 1)

* 重新加载基线+结局数据
use "$analysis/HRS_analysis_long_with_traj.dta", clear

* 构建首次痴呆发生时间
bysort hhidpn (wave): gen first_dementia_wave = wave if dementia_onset == 1 & dementia_onset[_n-1] != 1
bysort hhidpn: egen dementia_event_wave = min(first_dementia_wave)

* 构建分析数据（每人一行）
keep if wave == 9
gen dementia_event = (dementia_event_wave != .)
gen dementia_time = (dementia_event_wave - 9) * 2 if dementia_event == 1
replace dementia_time = surv_time if dementia_event == 0
replace dementia_time = 0.5 if dementia_time <= 0 & dementia_time != .

* 删除时间缺失
drop if dementia_time == . | dementia_time <= 0

********************************************************************************
* STEP 2: 痴呆发生的Cox回归
********************************************************************************

* 设定生存数据
stset dementia_time, failure(dementia_event == 1)

* --- Model 1: 仅调整人口学 ---
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs, hr
estimates store model1

* --- Model 2: 额外调整健康行为和慢性病 ---
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi, hr
estimates store model2

* --- Model 3: 额外调整社会参与 ---
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi ///
    social_activity_count i.relgwk, hr
estimates store model3

* 结果汇总表
esttab model1 model2 model3 using "$analysis/output/cox_dementia.csv", ///
    eform ci replace cells(b(fmt(2)) ci_l(fmt(2)) ci_u(fmt(2)) p(fmt(3))) ///
    title("Cox Regression: Social Isolation-Loneliness and Dementia Incidence")

* KM生存曲线
sts graph, by(exposure_4cat) ///
    title("Dementia-Free Survival by Isolation-Loneliness Status") ///
    xtitle("Years from Baseline") ytitle("Dementia-Free Probability") ///
    legend(order(1 "Non-isolated, Non-lonely" 2 "Isolated, Non-lonely" ///
    3 "Non-isolated, Lonely" 4 "Isolated and Lonely"))
graph export "$analysis/figures/km_dementia_4cat.png", replace

********************************************************************************
* STEP 3: 全因死亡的Cox回归
********************************************************************************

stset surv_time, failure(ever_died == 1)

* 完整模型
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi ///
    social_activity_count cog27, hr
estimates store death_model

esttab death_model using "$analysis/output/cox_death.csv", ///
    eform ci replace cells(b(fmt(2)) ci_l(fmt(2)) ci_u(fmt(2)) p(fmt(3))) ///
    title("Cox Regression: Social Isolation-Loneliness and All-Cause Mortality")

* KM曲线
sts graph, by(exposure_4cat) ///
    title("Survival by Isolation-Loneliness Status") ///
    xtitle("Years from Baseline") ytitle("Survival Probability")
graph export "$analysis/figures/km_death_4cat.png", replace

********************************************************************************
* STEP 4: 使用轨迹分组的Cox回归
********************************************************************************

stset dementia_time, failure(dementia_event == 1)

* 使用联合轨迹分组（来自GBTM）
stcox i.joint_traj_group baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi, hr
estimates store traj_dementia

stset surv_time, failure(ever_died == 1)
stcox i.joint_traj_group baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi cog27, hr
estimates store traj_death

esttab traj_dementia traj_death using "$analysis/output/cox_trajectory.csv", ///
    eform ci replace cells(b(fmt(2)) ci_l(fmt(2)) ci_u(fmt(2)) p(fmt(3))) ///
    title("Cox Regression: Trajectory Groups and Health Outcomes")

********************************************************************************
* STEP 5: 竞争风险模型（Fine-Gray）
* 痴呆发生 vs 死亡作为竞争事件
********************************************************************************

* 构建竞争风险状态变量
gen compete_status = 0          // 删失
replace compete_status = 1 if dementia_event == 1  // 痴呆
replace compete_status = 2 if ever_died == 1 & dementia_event == 0  // 死亡（未痴呆）

stset dementia_time, failure(compete_status == 1)

* Fine-Gray竞争风险模型
stcrreg i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi, compete(compete_status == 2)
estimates store finegray

esttab finegray using "$analysis/output/competing_risk.csv", ///
    eform ci replace cells(b(fmt(2)) ci_l(fmt(2)) ci_u(fmt(2)) p(fmt(3))) ///
    title("Fine-Gray Competing Risk Model: Dementia (competing: death)")

********************************************************************************
* STEP 6: 亚组分析与交互检验
********************************************************************************

stset dementia_time, failure(dementia_event == 1)

* 性别交互
stcox i.exposure_4cat##i.ragender baseline_age i.race raedyrs ///
    cesd chronic_count, hr
testparm i.exposure_4cat#i.ragender

* 年龄交互（<75 vs ≥75）
gen age75 = (baseline_age >= 75)
stcox i.exposure_4cat##i.age75 i.ragender i.race raedyrs ///
    cesd chronic_count, hr
testparm i.exposure_4cat#i.age75

* 种族交互
stcox i.exposure_4cat##i.race baseline_age i.ragender raedyrs ///
    cesd chronic_count, hr
testparm i.exposure_4cat#i.race

********************************************************************************
* STEP 7: 敏感性分析
********************************************************************************

* --- 7.1 排除基线CIND ---
preserve
drop if dementia == 2  // 仅保留基线认知正常者
stset dementia_time, failure(dementia_event == 1)
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count i.smoken i.drink bmi, hr
estimates store sens_normal_only
restore

* --- 7.2 使用连续暴露 ---
stset dementia_time, failure(dementia_event == 1)
stcox c.social_isolation c.lblonely3 c.social_isolation#c.lblonely3 ///
    baseline_age i.ragender i.race raedyrs cesd chronic_count, hr

* --- 7.3 考虑样本权重 ---
stset dementia_time [pw=wtresp], failure(dementia_event == 1)
stcox i.exposure_4cat baseline_age i.ragender i.race raedyrs ///
    cesd chronic_count, hr

di as text "======================================"
di as text "生存分析完成！"
di as text "结果输出至: $analysis/output/"
di as text "======================================"
