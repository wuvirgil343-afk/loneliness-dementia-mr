********************************************************************************
* Project: 社会隔离/孤独感异质性亚型与痴呆/死亡
* File: analysis_01_data_preparation.do
* Purpose: 数据清理与分析样本构建
* Input: $temp_data/HRS.dta （由数据合并.do生成的长面板数据）
* Output: $analysis/HRS_analysis_long.dta, $analysis/HRS_baseline.dta, CSV文件
* Author: [Your Name]
* Date: 2026-07
*
* 重要说明：
* - 运行本文件前，需先运行 wave8~wave15.do 和 数据合并.do 生成 HRS.dta
* - 长面板数据中变量名已去除波次前缀（如 cesd, cog27, lblonely3 等）
* - wave变量取值 5~15 对应 2000~2020年（每2年一波）
********************************************************************************

clear all
set more off
set maxvar 120000

* ============== 路径设置（运行前修改） ==============
global root= "E:/HRS_美国"
global dofiles=      "$root/Dofiles"         
global raw_data=     "$root/Raw_data"
global working_data= "$root/Working_data"
global temp_data=    "$root/Temp_data"
global analysis=     "$root/Analysis"

cap mkdir "$analysis"
cap mkdir "$analysis/output"
cap mkdir "$analysis/figures"

********************************************************************************
* STEP 1: 加载长面板数据
********************************************************************************

use "$temp_data/HRS.dta", clear

di "数据加载完成"
di "观测数: " _N
codebook hhidpn
tab wave, mi

********************************************************************************
* STEP 2: 确认关键变量存在并检查分布
********************************************************************************

* --- 确认变量名（数据合并.do reshape后的名称）---
* 个体ID: hhidpn
* 波次: wave (9=2008, 10=2010, ..., 15=2020)
* 孤独感: lblonely3, lblonely11
* 社会联系: cntc, cntr, cntf
* 社会活动: volunteer, charity, education, club, nonreligious, read, 
*           word_game, play_card, writing, use_computer, gardening, 
*           exercize, walk, hobby, care_adult, with_grand, vol, hour_vol
* 隔离相关: mstath, lvwith, hhres, away_child
* 认知: cog27, dementia, memory_z, orient_z, executive_z, slfmem
* 死亡: iwstat, radyear, radmonth, radtimtdth
* 人口学: ragender, rabyear, raedyrs, raeducl, race, ragey_b
* 健康: cesd, depressive, hibpe, diabe, cancre, lunge, hearte, stroke, 
*        psyche, arthre, bmi, smoken, drink, adl6a, iadl5a
* 活动: vgactx, mdactx, ltactx
* 人格: lbneur, lbext, lbopen, lbagr, lbcon5
* 经济: atotb, iearn, itot
* 其他: relgwk, socrelg_h, socwk, socmn, email, frailty

describe lblonely3 lblonely11 cntc cntr cntf cog27 dementia iwstat

* 检查孤独量表分布
tab wave if lblonely3 != ., mi
summarize lblonely3 if wave==9, detail
summarize lblonely3 if wave==15, detail

********************************************************************************
* STEP 3: 定义分析样本
* 基线：Wave 9 (2008年) - 孤独量表+社会活动变量首次同时可用
* 纳入标准：
*   (1) Wave 9参与调查 (inw==1)
*   (2) 基线认知非痴呆 (dementia!=1)
*   (3) 基线年龄≥50
*   (4) 至少有1次后续随访
********************************************************************************

* 保留 wave 9-15
keep if wave >= 9 & wave <= 15

* 标记基线参与
gen byte is_baseline = (wave == 9 & inw == 1)
bysort hhidpn: egen byte has_baseline = max(is_baseline)
keep if has_baseline == 1
drop is_baseline has_baseline

* 基线年龄
gen bl_age = ragey_b if wave == 9
bysort hhidpn: egen baseline_age = max(bl_age)
drop bl_age
drop if baseline_age < 50 | baseline_age == .

* 基线认知状态（排除已痴呆）
gen bl_dem = dementia if wave == 9
bysort hhidpn: egen baseline_dementia = max(bl_dem)
drop bl_dem
drop if baseline_dementia == 1  // 排除基线已痴呆者

* 至少1次后续随访
bysort hhidpn: egen n_waves = total(inw)
drop if n_waves <= 1

* 样本量报告
di "====== 纳入样本量 ======"
distinct hhidpn
tab wave if inw == 1

********************************************************************************
* STEP 4: 构建社会隔离综合指数 (0-5分)
* 参考 Steptoe et al. (2013) Lancet 定义
********************************************************************************

* 4.1 未婚/无伴侣（1=隔离）
gen byte iso_unmarried = .
replace iso_unmarried = 1 if !inlist(mstath, 1, 2)  // 非已婚/有伴侣
replace iso_unmarried = 0 if inlist(mstath, 1, 2)

* 4.2 独居（1=隔离）
gen byte iso_livalone = .
replace iso_livalone = 1 if lvwith == 1
replace iso_livalone = 0 if lvwith != 1 & lvwith != .

* 4.3 与子女联系<每月（1=隔离）
gen byte iso_child = .
replace iso_child = 1 if cntc == 0
replace iso_child = 0 if cntc == 1

* 4.4 与亲戚联系<每月（1=隔离）
gen byte iso_relative = .
replace iso_relative = 1 if cntr == 0
replace iso_relative = 0 if cntr == 1

* 4.5 与朋友联系<每月（1=隔离）
gen byte iso_friend = .
replace iso_friend = 1 if cntf == 0
replace iso_friend = 0 if cntf == 1

* 社会隔离总分
egen social_isolation_score = rowtotal(iso_unmarried iso_livalone iso_child iso_relative iso_friend), mi
* 要求至少3项非缺失
egen iso_nonmiss = rownonmiss(iso_unmarried iso_livalone iso_child iso_relative iso_friend)
replace social_isolation_score = . if iso_nonmiss < 3

* 社会隔离二分类（≥2分为隔离）
gen byte isolated = (social_isolation_score >= 2) if social_isolation_score != .

label var social_isolation_score "社会隔离指数(0-5)"
label var isolated "社会隔离(≥2分=1)"

********************************************************************************
* STEP 5: 孤独感变量处理
********************************************************************************

* UCLA孤独量表3项（原始范围3-9，越高越孤独）
label var lblonely3 "UCLA孤独感3项(3-9)"

* 孤独二分类（≥6为孤独）
gen byte lonely = (lblonely3 >= 6) if lblonely3 != .
label var lonely "孤独(UCLA-3≥6)"

* 孤独11项（用于敏感性分析）
label var lblonely11 "UCLA孤独感11项"

********************************************************************************
* STEP 6: 社会参与变量
* 原始编码（wave 9+）: 1=每天, 2=每周至少一次, 3=每月, 
*                      4=每年至少一次, 5=不到一年一次, 6=从不
* 重新编码为二分类: 至少每月一次(1-3)=活跃
********************************************************************************

* 活动变量列表
local activities "volunteer charity education club nonreligious read word_game play_card writing use_computer gardening exercize walk"

foreach var of local activities {
    cap gen byte `var'_active = .
    cap replace `var'_active = 1 if inlist(`var', 1, 2, 3)  // ≥每月=活跃
    cap replace `var'_active = 0 if inlist(`var', 4, 5, 6)  // <每月=不活跃
}

* 社会参与活动总数（0-13种至少每月参与一次的活动）
egen social_activity_count = rowtotal(volunteer_active charity_active ///
    education_active club_active nonreligious_active read_active ///
    word_game_active play_card_active writing_active use_computer_active ///
    gardening_active exercize_active walk_active), mi

* 活动类型分组
* 智力型(0-5): 阅读、填字游戏、写作、电脑、继续教育
egen intellectual_act = rowtotal(read_active word_game_active writing_active ///
    use_computer_active education_active), mi

* 社交型(0-5): 志愿、慈善、俱乐部、非宗教组织、打牌
egen social_act = rowtotal(volunteer_active charity_active club_active ///
    nonreligious_active play_card_active), mi

* 身体型(0-3): 运动、散步、园艺
egen physical_act = rowtotal(exercize_active walk_active gardening_active), mi

label var social_activity_count "活跃社会活动总数(0-13)"
label var intellectual_act "智力型活动数(0-5)"
label var social_act "社交型活动数(0-5)"
label var physical_act "身体型活动数(0-3)"

********************************************************************************
* STEP 7: 暴露四分类（2×2: 隔离×孤独）
********************************************************************************

gen byte exposure_4cat = .
replace exposure_4cat = 1 if isolated == 0 & lonely == 0
replace exposure_4cat = 2 if isolated == 1 & lonely == 0
replace exposure_4cat = 3 if isolated == 0 & lonely == 1
replace exposure_4cat = 4 if isolated == 1 & lonely == 1

label define exp4_ 1 "非隔离非孤独" 2 "隔离非孤独" 3 "非隔离但孤独" 4 "隔离且孤独"
label values exposure_4cat exp4_
label var exposure_4cat "隔离-孤独四分类"

********************************************************************************
* STEP 8: 结局变量
********************************************************************************

* 8.1 痴呆发生
* dementia变量: 1=痴呆, 2=CIND, 3=正常
gen byte dementia_event = (dementia == 1) if dementia != .
label var dementia_event "痴呆(dementia==1)"

* 标记首次痴呆发生的波次
gen dem_wave = wave if dementia_event == 1
bysort hhidpn: egen first_dementia_wave = min(dem_wave)
drop dem_wave

* 对基线正常/CIND者，标记是否在随访中转为痴呆
gen byte incident_dementia = (first_dementia_wave > 9 & first_dementia_wave != .) if wave == 9
bysort hhidpn: egen byte ever_dementia = max(incident_dementia)
replace ever_dementia = 0 if ever_dementia == .

* 8.2 认知衰退（连续变量cog27的变化）
label var cog27 "认知总分(0-27)"

* 8.3 全因死亡
label var iwstat "本波死亡状态"

* 标记随访期内是否死亡
gen death_flag = (iwstat == 1)
bysort hhidpn: egen byte ever_died = max(death_flag)
drop death_flag

* 死亡波次
gen dth_wave = wave if iwstat == 1
bysort hhidpn: egen death_wave = min(dth_wave)
drop dth_wave

* 8.4 生存时间构建（以年为单位，每波间隔2年）
* 对于事件发生者：从wave 9到事件波次的时间
* 对于删失者：从wave 9到最后一次有效参与的时间

* 痴呆生存时间
gen dementia_time = .
replace dementia_time = (first_dementia_wave - 9) * 2 if ever_dementia == 1
bysort hhidpn: egen last_obs_wave = max(wave * (inw == 1 | iwstat == 1))
replace dementia_time = (last_obs_wave - 9) * 2 if ever_dementia == 0
* 处理边界：最小0.5年
replace dementia_time = 0.5 if dementia_time <= 0 & dementia_time != .

* 死亡生存时间  
gen death_time = .
replace death_time = (death_wave - 9) * 2 if ever_died == 1
replace death_time = (last_obs_wave - 9) * 2 if ever_died == 0
replace death_time = 0.5 if death_time <= 0 & death_time != .

label var dementia_time "痴呆生存时间(年)"
label var death_time "死亡生存时间(年)"
label var ever_dementia "随访中发生痴呆"
label var ever_died "随访中死亡"

********************************************************************************
* STEP 9: 协变量标准化
********************************************************************************

* 慢性病数量
egen chronic_count = rowtotal(hibpe diabe cancre lunge hearte stroke arthre), mi
label var chronic_count "慢性病数(0-7)"

* 身体活动频率（已编码为0-4，越高越活跃）
label var vgactx "强度身体活动(0-4)"
label var mdactx "中度身体活动(0-4)"
label var ltactx "轻度身体活动(0-4)"

* 综合身体活动（三个维度相加）
egen pa_total = rowtotal(vgactx mdactx ltactx), mi
label var pa_total "身体活动总分(0-12)"

* 人格特质
label var lbneur "神经质"
label var lbext "外倾性"
label var lbopen "开放性"
label var lbagr "宜人性"
label var lbcon5 "尽责性"

* 经济（对数转换处理偏态）
gen ln_wealth = ln(atotb + 1) if atotb >= 0
replace ln_wealth = 0 if atotb < 0  // 负财富设为0
label var ln_wealth "总财富(对数)"

********************************************************************************
* STEP 10: 基线描述性统计
********************************************************************************

preserve
keep if wave == 9

di ""
di "====== 基线样本描述 ======"
di ""

* 暴露分布
tab exposure_4cat, mi
tab isolated, mi
tab lonely, mi
summarize social_isolation_score lblonely3, detail

* 按四分类描述
tabstat baseline_age ragender raedyrs cesd chronic_count cog27 bmi ///
    social_activity_count lblonely3 social_isolation_score, ///
    by(exposure_4cat) stat(mean sd n) col(stat) format(%9.2f)

* 结局事件率
di ""
di "--- 结局事件 ---"
tab ever_dementia
tab ever_died

* 缺失情况
di ""
di "--- 关键变量缺失率 ---"
misstable summarize lblonely3 social_isolation_score cog27 dementia ///
    cesd chronic_count bmi raedyrs lbneur lbext social_activity_count

restore

********************************************************************************
* STEP 11: 保存分析数据集
********************************************************************************

* 排序和标签
sort hhidpn wave
label data "HRS分析数据(长面板) - 社会隔离孤独与痴呆/死亡 [Wave 9-15, 2008-2020]"

* 保存Stata格式
save "$analysis/HRS_analysis_long.dta", replace

* 保存基线截面（供ML使用）
preserve
keep if wave == 9
save "$analysis/HRS_baseline.dta", replace

* 导出CSV（供Python使用）
export delimited using "$analysis/HRS_baseline.csv", replace
restore

* 导出长格式CSV
export delimited using "$analysis/HRS_analysis_long.csv", replace

********************************************************************************
* STEP 12: 构建ML专用宽格式数据（基线特征 + 结局）
* Python读取此文件做预测建模
********************************************************************************

use "$analysis/HRS_baseline.dta", clear

* 确保结局变量存在
assert ever_dementia != .
assert ever_died != .

* 保留ML所需变量
keep hhidpn baseline_age ragender race raeducl raedyrs ///
    social_isolation_score iso_unmarried iso_livalone iso_child iso_relative iso_friend ///
    isolated lblonely3 lblonely11 lonely exposure_4cat ///
    cntc cntr cntf away_child ///
    social_activity_count intellectual_act social_act physical_act ///
    vol hour_vol hobby ///
    volunteer charity education club nonreligious read ///
    word_game play_card writing use_computer gardening exercize walk ///
    socwk socmn relgwk socrelg_h email ///
    mstath lvwith hhres ///
    cog27 memory_z orient_z executive_z slfmem dementia ///
    cesd depressive chronic_count ///
    hibpe diabe cancre lunge hearte stroke psyche arthre ///
    adl6a iadl5a bmi smoken drink vgactx mdactx ltactx pa_total ///
    lbneur lbext lbopen lbagr lbcon5 ///
    lbsatwlf satlife_h cantril ///
    atotb ln_wealth shlt ///
    fall painfr hearing sight frailty ///
    ever_dementia dementia_time first_dementia_wave ///
    ever_died death_time death_wave ///
    wtresp lbwgtr

order hhidpn baseline_age ragender race raedyrs

export delimited using "$analysis/HRS_ML_dataset.csv", replace
label data "HRS ML建模数据(基线+结局)"
save "$analysis/HRS_ML_dataset.dta", replace

di ""
di "======================================"
di "数据准备完成！输出文件:"
di "  1. $analysis/HRS_analysis_long.dta  (长面板, Stata)"
di "  2. $analysis/HRS_analysis_long.csv  (长面板, CSV)"
di "  3. $analysis/HRS_baseline.dta       (基线截面)"
di "  4. $analysis/HRS_baseline.csv       (基线截面, CSV)"
di "  5. $analysis/HRS_ML_dataset.dta     (ML建模专用)"
di "  6. $analysis/HRS_ML_dataset.csv     (ML建模专用, CSV)"
di "======================================"
di ""
di "下一步: 在Python中运行 analysis_04_machine_learning.py"
