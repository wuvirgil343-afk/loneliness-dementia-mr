
clear all
set more off
set maxvar 120000
global root= "E:/HRS_美国"

***************************** 注：运行前更改上述路径 ***************************

global dofiles=      "$root/Dofiles"         
global raw_data=     "$root/Raw_data"
global working_data= "$root/Working_data"
global temp_data=    "$root/Temp_data"

cap mkdir "$raw_data"      // 自动创建文件夹
cap mkdir "$temp_data"     // `cap` 命令可让错误的代码继续运行
cap mkdir "$working_data"    
cap mkdir "$dofiles"       // 如果已经创建了这些文件夹，也可以运行


********************************************************************************
/*
use "$raw_data/RAND HRS Longitudinal File 2020/randhrs1992_2020v2.dta",clear 
merge 1:1 hhidpn using "$raw_data/Gateway Harmonized HRS/H_HRS_d.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave8_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave9_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave10_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave11_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave12_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave13_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave14_temp.dta",nogen nolabel
merge 1:1 hhid pn using "$temp_data/hrs_wave15_temp.dta",nogen nolabel
save "$temp_data/HRS.dta",replace 

*****抽样
sample 1
save "$temp_data/HRS_sample1.dta",replace 
*/

use "$temp_data/HRS.dta",clear
*****个体编码
*hhidpn

*****家庭编码
*h5hhid h6hhid h7hhid h8hhid h9hhid h10hhid h11hhid h12hhid h13hhid h14hhid h15hhid

*****是否参与本次调查
*inw5 inw6 inw7 inw8 inw9 inw10 inw11 inw12 inw13 inw14 inw15
label define yesno_ 0 "否" 1 "是"
label values inw5 inw6 inw7 inw8 inw9 inw10 inw11 inw12 inw13 inw14 inw15 yesno_

*****是否死亡
*r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat r10iwstat r11iwstat r12iwstat r13iwstat r14iwstat r15iwstat
forvalues i=5/15 {
 recode r`i'iwstat (0 1 4=0) (5 6=1) (7 9=.)
}
label values r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat r10iwstat r11iwstat r12iwstat r13iwstat r14iwstat r15iwstat yesno_

*****家庭最初被抽样的队列
*hacohort
label define hacohort_ 0 "HRS/AHEAD重叠" 1 "AHEAD(1924前)" 2 "CODA(1924~1930)" 3 "HRS(1931~1941)" ///
  4 "WB(1942~1947)" 5 "EBB(1948~1953)" 6 "MBB(1954~1959)" 7 "LBB(1960~1965)"
label values hacohort hacohort_
  
*****根据被调查者的出生年份确定其所属队列
*racohbyr
label define racohbyr_ 0 "其他" 1 "AHEAD(1924前)" 2 "CODA(1924~1930)" 3 "HRS(1931~1941)" ///
  4 "WB(1942~1947)" 5 "EBB(1948~1953)" 6 "MBB(1954~1959)" 7 "LBB(1960~1965)"
label values hacohort racohbyr_

*****家庭权重
*r5wthh r6wthh r7wthh r8wthh r9wthh r10wthh r11wthh r12wthh r13wthh r14wthh r15wthh

*****个体权重
*r5wtresp r6wtresp r7wtresp r8wtresp r9wtresp r10wtresp r11wtresp r12wtresp r13wtresp r14wtresp r15wtresp 
*r5wtr_nh r6wtr_nh r7wtr_nh r8wtr_nh r9wtr_nh r10wtr_nh r11wtr_nh r12wtr_nh r13wtr_nh r14wtr_nh r15wtr_nh 
*r5wtcrnh r6wtcrnh r7wtcrnh r8wtcrnh r9wtcrnh r10wtcrnh r11wtcrnh r12wtcrnh r13wtcrnh r14wtcrnh r15wtcrnh

*****是否由其他人代理回答
*r5proxy r6proxy r7proxy r8proxy r9proxy r10proxy r11proxy r12proxy r13proxy r14proxy r15proxy
label values r5proxy r6proxy r7proxy r8proxy r9proxy r10proxy r11proxy r12proxy r13proxy r14proxy r15proxy yesno_

*****受访月份
*r5iwendm r6iwendm r7iwendm r8iwendm r9iwendm r10iwendm r11iwendm r12iwendm r13iwendm r14iwendm r15iwendm

*****受访年份
*r5iwendy r6iwendy r7iwendy r8iwendy r9iwendy r10iwendy r11iwendy r12iwendy r13iwendy r14iwendy r15iwendy

*****出生年份
*rabyear

*****出生月份
*rabmonth

*****死亡年份
*radyear

*****死亡月份
*radmonth

*****最后一次受访和死亡之间的时间跨度
*radtimtdth

*****年龄
*r5agey_b r6agey_b r7agey_b r8agey_b r9agey_b r10agey_b r11agey_b r12agey_b r13agey_b r14agey_b r15agey_b 
*r1agey_e r2agey_e r3agey_e r4agey_e r5agey_e r6agey_e r7agey_e r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e r15agey_e 
*r1agey_m r2agey_m r3agey_m r4agey_m r5agey_m r6agey_m r7agey_m r8agey_m r9agey_m r10agey_m r11agey_m r12agey_m r13agey_m r14agey_m r15agey_m

*****性别
*ragender
recode ragender (1=1) (2=0) 
label define ragender_ 1 "男性" 0 "女性"
label values ragender ragender_

*****种族
*raracem
label define raracem_ 1 "白人" 2 "黑人" 3 "其他"
label values raracem raracem_

*****是否西班牙裔
*rahispan
label define rahispan_ 0 "非西班牙裔" 1 "西班牙裔"
label values rahispan rahispan_

*****种族四等划分
*race
gen race=.
replace race=1 if raracem==1 & rahispan==0  
replace race=2 if raracem==2 & rahispan==0  
replace race=3 if rahispan==1 & (raracem==1 | raracem==2 | raracem==3)
replace race=4 if raracem==3 & rahispan==0
label define race_ 1 "非西班牙裔白人" 2 "非西班牙裔黑人" 3 "西班牙裔" 4 "其他"
label values race race_

*****人口普查区域
*r5cenreg r6cenreg r7cenreg r8cenreg r9cenreg r10cenreg r11cenreg r12cenreg r13cenreg r14cenreg r15cenreg
label define cenreg_ 1 "东北部" 2 "中西部" 3 "南部" 4 "西部" 5 "其他"
label values r5cenreg r6cenreg r7cenreg r8cenreg r9cenreg r10cenreg r11cenreg r12cenreg r13cenreg r14cenreg r15cenreg cenreg_

*****城市化
*r5urbrur r6urbrur r7urbrur r8urbrur r9urbrur r10urbrur r11urbrur r12urbrur r13urbrur r14urbrur r15urbrur
label define urbrur_ 1 "城市" 2 "城郊" 3 "城市外"
label values r5urbrur r6urbrur r7urbrur r8urbrur r9urbrur r10urbrur r11urbrur r12urbrur r13urbrur r14urbrur r15urbrur urbrur_

*****受教育年限
*raedyrs

*****婚姻状况
*r5mstath r6mstath r7mstath r8mstath r9mstath r10mstath r11mstath r12mstath r13mstath r14mstath r15mstath
label define mstath_ 1 "已婚" 2 "已婚但配偶缺席" 4 "分居" 5 "离婚" 6 "分居/离婚" 7 "丧偶" 8 "从未结婚" 9 "未知"
label values r5mstath r6mstath r7mstath r8mstath r9mstath r10mstath r11mstath r12mstath r13mstath r14mstath r15mstath mstath_

*****宗教
*rarelig
label define rarelig_ 1 "新教" 2 "天主教" 3 "犹太教" 4 "没有"  5 "其他"
label values rarelig rarelig_

*****母亲是否健在
*r5momliv r6momliv r7momliv r8momliv r9momliv r10momliv r11momliv r12momliv r13momliv r14momliv r15momliv
label values r5momliv r6momliv r7momliv r8momliv r9momliv r10momliv r11momliv r12momliv r13momliv r14momliv r15momliv yesno_

*****父亲是否健在
*r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv r10dadliv r11dadliv r12dadliv r13dadliv r14dadliv r15dadliv
label values r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv r10dadliv r11dadliv r12dadliv r13dadliv r14dadliv r15dadliv yesno_

*****自评健康
*r5shlt r6shlt r7shlt r8shlt r9shlt r10shlt r11shlt r12shlt r13shlt r14shlt r15shlt
forvalues i=5/15 {
  recode r`i'shlt (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define shlt_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r5shlt r6shlt r7shlt r8shlt r9shlt r10shlt r11shlt r12shlt r13shlt r14shlt r15shlt shlt_

*****最近2年是否住院
*r5hosp r6hosp r7hosp r8hosp r9hosp r10hosp r11hosp r12hosp r13hosp r14hosp r15hosp
label values r5hosp r6hosp r7hosp r8hosp r9hosp r10hosp r11hosp r12hosp r13hosp r14hosp r15hosp yesno_

*****最近2年住院次数
*r5hsptim r6hsptim r7hsptim r8hsptim r9hsptim r10hsptim r11hsptim r12hsptim r13hsptim r14hsptim r15hsptim

*****最近2年住院天数
*r5hspnit r6hspnit r7hspnit r8hspnit r9hspnit r10hspnit r11hspnit r12hspnit r13hspnit r14hspnit r15hspnit

*****过去2年是否曾在养老院过夜
*r5nrshom r6nrshom r7nrshom r8nrshom r9nrshom r10nrshom r11nrshom r12nrshom r13nrshom r14nrshom r15nrshom
label values r5nrshom r6nrshom r7nrshom r8nrshom r9nrshom r10nrshom r11nrshom r12nrshom r13nrshom r14nrshom r15nrshom yesno_

*****过去2年养老院住宿次数
*r5nrstim r6nrstim r7nrstim r8nrstim r9nrstim r10nrstim r11nrstim r12nrstim r13nrstim r14nrstim r15nrstim

*****过去2年养老院住宿天数
*r5nrsnit r6nrsnit r7nrsnit r8nrsnit r9nrsnit r10nrsnit r11nrsnit r12nrsnit r13nrsnit r14nrsnit r15nrsnit

*****过去2年是否门诊
*r5doctor r6doctor r7doctor r8doctor r9doctor r10doctor r11doctor r12doctor r13doctor r14doctor r15doctor
label values r5doctor r6doctor r7doctor r8doctor r9doctor r10doctor r11doctor r12doctor r13doctor r14doctor r15doctor yesno_

*****过去2年门诊次数
*r5doctim r6doctim r7doctim r8doctim r9doctim r10doctim r11doctim r12doctim r13doctim r14doctim r15doctim

*****过去两年是否有任何家庭护理
*r5homcar r6homcar r7homcar r8homcar r9homcar r10homcar r11homcar r12homcar r13homcar r14homcar r15homcar
label values r5homcar r6homcar r7homcar r8homcar r9homcar r10homcar r11homcar r12homcar r13homcar r14homcar r15homcar yesno_

*****过去2年自付医疗费用
*r5oopmd r6oopmd r7oopmd r8oopmd r9oopmd r10oopmd r11oopmd r12oopmd r13oopmd r14oopmd r15oopmd

*****CESD心理健康8分(得分越高越差)
*r5cesd r6cesd r7cesd r8cesd r9cesd r10cesd r11cesd r12cesd r13cesd r14cesd r15cesd

*****是否抑郁
*r5depressive r6depressive r7depressive r8depressive r9depressive r10depressive 
*r11depressive r12depressive r13depressive r14depressive r15depressive
forvalues i=5/15 {
  recode r`i'cesd (0/2=0) (3/8=1),gen(r`i'depressive)
  label values r`i'depressive yesno_
}

*****医生曾诊断高血压
*r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe r10hibpe r11hibpe r12hibpe r13hibpe r14hibpe r15hibpe
label values r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe r10hibpe r11hibpe r12hibpe r13hibpe r14hibpe r15hibpe yesno_

*****医生曾诊断糖尿病或高血糖
*r5diabe r6diabe r7diabe r8diabe r9diabe r10diabe r11diabe r12diabe r13diabe r14diabe r15diabe
label values r5diabe r6diabe r7diabe r8diabe r9diabe r10diabe r11diabe r12diabe r13diabe r14diabe r15diabe yesno_

*****医生曾诊断癌症或者恶性肿瘤
*r5cancre r6cancre r7cancre r8cancre r9cancre r10cancre r11cancre r12cancre r13cancre r14cancre r15cancre
label values r5cancre r6cancre r7cancre r8cancre r9cancre r10cancre r11cancre r12cancre r13cancre r14cancre r15cancre yesno_

*****医生曾诊断慢性肺部疾病
*r5lunge r6lunge r7lunge r8lunge r9lunge r10lunge r11lunge r12lunge r13lunge r14lunge r15lunge
label values r5lunge r6lunge r7lunge r8lunge r9lunge r10lunge r11lunge r12lunge r13lunge r14lunge r15lunge yesno_

*****医生曾诊断心脏病
*r5hearte r6hearte r7hearte r8hearte r9hearte r10hearte r11hearte r12hearte r13hearte r14hearte r15hearte
label values r5hearte r6hearte r7hearte r8hearte r9hearte r10hearte r11hearte r12hearte r13hearte r14hearte r15hearte yesno_

*****医生曾诊断中风或短暂性脑缺血发作
*r5stroke r6stroke r7stroke r8stroke r9stroke r10stroke r11stroke r12stroke r13stroke r14stroke r15stroke
label values r5stroke r6stroke r7stroke r8stroke r9stroke r10stroke r11stroke r12stroke r13stroke r14stroke r15stroke yesno_

*****医生曾诊断情绪、神经或精神问题
*r5psyche r6psyche r7psyche r8psyche r9psyche r10psyche r11psyche r12psyche r13psyche r14psyche r15psyche
label values r5psyche r6psyche r7psyche r8psyche r9psyche r10psyche r11psyche r12psyche r13psyche r14psyche r15psyche yesno_

*****医生曾诊断关节炎或风湿病
*r5arthre r6arthre r7arthre r8arthre r9arthre r10arthre r11arthre r12arthre r13arthre r14arthre r15arthre
label values r5arthre r6arthre r7arthre r8arthre r9arthre r10arthre r11arthre r12arthre r13arthre r14arthre r15arthre yesno_

*****医生曾诊断睡眠障碍
*r13sleepe r14sleepe r15sleepe
label values r13sleepe r14sleepe r15sleepe yesno_

*****医生诊断记忆相关的疾病
*r5memrye r6memrye r7memrye r8memrye r9memrye
label values r5memrye r6memrye r7memrye r8memrye r9memrye yesno_

*****本期诊断为阿尔茨海默病
*r10alzhe r11alzhe r12alzhe r13alzhe r14alzhe r15alzhe
label values r10alzhe r11alzhe r12alzhe r13alzhe r14alzhe r15alzhe yesno_

*****医生曾诊断阿尔茨海默病
*r10alzhee r11alzhee r12alzhee r13alzhee r14alzhee r15alzhee
label values r10alzhee r11alzhee r12alzhee r13alzhee r14alzhee r15alzhee yesno_

*****本期诊断为痴呆症
*r10demen r11demen r12demen r13demen r14demen r15demen
label values r10demen r11demen r12demen r13demen r14demen r15demen yesno_

*****医生曾诊断痴呆症
*r10demene r11demene r12demene r13demene r14demene r15demene
label values r10demene r11demene r12demene r13demene r14demene r15demene yesno_

*****自报BMI
*r5bmi r6bmi r7bmi r8bmi r9bmi r10bmi r11bmi r12bmi r13bmi r14bmi r15bmi

*****自报身高m
*r5height r6height r7height r8height r9height r10height r11height r12height r13height r14height r15height

*****自报体重kg
*r5weight r6weight r7weight r8weight r9weight r10weight r11weight r12weight r13weight r14weight r15weight

*****背部疼痛或问题
*r5back r6back r7back r8back r9back r10back r11back r12back r13back r14back r15back
label values r5back r6back r7back r8back r9back r10back r11back r12back r13back r14back r15back yesno_

*****强度身体活动频率
*r7vgactx r8vgactx r9vgactx r10vgactx r11vgactx r12vgactx r13vgactx r14vgactx r15vgactx
forvalues i=7/15 {
 recode r`i'vgactx (1=4) (2=3) (3=2) (4=1) (5=0)
}
label define vgactx_ 4 "每天" 3 "至少每周一次" 2 "每周一次" 1 "每月1~3次" 0 "从不"
label values r7vgactx r8vgactx r9vgactx r10vgactx r11vgactx r12vgactx r13vgactx r14vgactx r15vgactx vgactx_

*****中度身体活动频率
*r7mdactx r8mdactx r9mdactx r10mdactx r11mdactx r12mdactx r13mdactx r14mdactx r15mdactx
forvalues i=7/15 {
 recode r`i'mdactx (1=4) (2=3) (3=2) (4=1) (5=0)
}
label define mdactx_ 4 "每天" 3 "至少每周一次" 2 "每周一次" 1 "每月1~3次" 0 "从不"
label values r7mdactx r8mdactx r9mdactx r10mdactx r11mdactx r12mdactx r13mdactx r14mdactx r15mdactx mdactx_

*****轻度身体活动频率
*r7ltactx r8ltactx r9ltactx r10ltactx r11ltactx r12ltactx r13ltactx r14ltactx r15ltactx
forvalues i=7/15 {
 recode r`i'ltactx (1=4) (2=3) (3=2) (4=1) (5=0)
}
label define ltactx_ 4 "每天" 3 "至少每周一次" 2 "每周一次" 1 "每月1~3次" 0 "从不"
label values r7ltactx r8ltactx r9ltactx  r10ltactx r11ltactx r12ltactx r13ltactx r14ltactx r15ltactx ltactx_

*****是否饮酒
*r5drink r6drink r7drink r8drink r9drink r10drink r11drink r12drink r13drink r14drink r15drink
label values r5drink r6drink r7drink r8drink r9drink r10drink r11drink r12drink r13drink r14drink r15drink yesno_ 

*****饮酒频率
*r5drinkd r6drinkd r7drinkd r8drinkd r9drinkd r10drinkd r11drinkd r12drinkd r13drinkd r14drinkd r15drinkd

*****是否血液胆固醇检查
*r5cholst r6cholst r7cholst r8cholst r9cholst r10cholst r11cholst r12cholst r13cholst r14cholst r15cholst
label values r5cholst r6cholst r7cholst r8cholst r9cholst r10cholst r11cholst r12cholst r13cholst r14cholst r15cholst yesno_

*****是否流感疫苗
*r5flusht r6flusht r7flusht r8flusht r9flusht r10flusht r11flusht r12flusht r13flusht r14flusht r15flusht
label values r5flusht r6flusht r7flusht r8flusht r9flusht r10flusht r11flusht r12flusht r13flusht r14flusht r15flusht yesno_

*****是否乳房x光检查
*r5mammog r6mammog r7mammog r9mammog r10mammog r11mammog r12mammog r13mammog r14mammog r15mammog
label values r5mammog r6mammog r7mammog r9mammog r10mammog r11mammog r12mammog r13mammog r14mammog r15mammog yesno_

*****是否巴氏涂片检查
*r5papsm r6papsm r8papsm r9papsm r10papsm r11papsm r12papsm r13papsm r14papsm r15papsm
label values r5papsm r6papsm r8papsm r9papsm r10papsm r11papsm r12papsm r13papsm r14papsm r15papsm yesno_

*****是否前列腺癌检查
*r5prost r6prost r7prost r8prost r9prost r10prost r11prost r12prost r13prost r14prost r15prost
label values r5prost r6prost r7prost r8prost r9prost r10prost r11prost r12prost r13prost r14prost r15prost yesno_

*****曾经是否吸过烟
*r5smokev r6smokev r7smokev r8smokev r9smokev r10smokev r11smokev r12smokev r13smokev r14smokev r15smokev
label values r5smokev r6smokev r7smokev r8smokev r9smokev r10smokev r11smokev r12smokev r13smokev r14smokev r15smokev yesno_

*****现在是否吸烟
*r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken r9smoken r10smoken r11smoken r12smoken r13smoken r14smoken r15smoken
label values r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken ///
r8smoken r9smoken r10smoken r11smoken r12smoken r13smoken r14smoken r15smoken yesno_

*****自评记忆
*r5slfmem r6slfmem r7slfmem r8slfmem r9slfmem r10slfmem r11slfmem r12slfmem r13slfmem r14slfmem r15slfmem
forvalues i=5/15 {
 recode r`i'slfmem (1=5) (2=4) (3=3) (4=2) (5=1)	
}

label define slfmem_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r5slfmem r6slfmem r7slfmem r8slfmem r9slfmem r10slfmem r11slfmem r12slfmem r13slfmem r14slfmem r15slfmem slfmem_

*****认知/即时单词回忆10分
*r5imrc r6imrc r7imrc r8imrc r9imrc r10imrc r11imrc r12imrc r13imrc 
*r14imrcp r14imrcw 
*r15imrcp r15imrcw

*****认知/延迟单词回忆10分
*r5dlrc r6dlrc r7dlrc r8dlrc r9dlrc r10dlrc r11dlrc r12dlrc r13dlrc 
*r14dlrcp r15dlrcp
*r14dlrcw r15dlrcw

*****认知/减法(5分)
*r5ser7 r6ser7 r7ser7 r8ser7 r9ser7 r10ser7 r11ser7 r12ser7 r13ser7
*r14ser7p r15ser7p 
*r14ser7w r15ser7w

*****认知/倒数
*r5bwc20 r6bwc20 r7bwc20 r8bwc20 r9bwc20 r10bwc20 r11bwc20 r12bwc20 r13bwc20
*r14bwc20p r15bwc20p 
*r14bwc20w r15bwc20w

*****认知/月
*r5mo r6mo r7mo r8mo r9mo r10mo r11mo r12mo r13mo
*r14mop r15mop

*****认知/日
*r5dy r6dy r7dy r8dy r9dy r10dy r11dy r12dy r13dy
*r14dyp r15dyp

*****认知/年
*r5yr r6yr r7yr r8yr r9yr r10yr r11yr r12yr r13yr
*r14yrp r15yrp

*****认知/星期
*r5dw r6dw r7dw r8dw r9dw r10dw r11dw r12dw r13dw
*r14dwp r15dwp

*****认知/正确地命名剪刀
*r5scis r6scis r7scis r8scis r9scis r10scis r11scis r12scis r13scis
*r14scisp r15scisp

*****认知/正确地命名仙人掌
*r5cact r6cact r7cact r8cact r9cact r10cact r11cact r12cact r13cact
*r14cactp r15cactp

*****认知/正确说出美国现任总统
*r5pres r6pres r7pres r8pres r9pres r10pres r11pres r12pres r13pres 
*r14presp r15presp

*****认知/正确说出美国现任副总统
*r5vp r6vp r7vp r8vp r9vp r10vp r11vp r12vp r13vp 
*r14vpp r15vpp

*****认知/词汇
*r5vocab r6vocab r7vocab r8vocab r9vocab r10vocab r11vocab r12vocab r13vocab 
*r14vocabp r15vocabp

*****单词回忆20分
*r5tr20 r6tr20 r7tr20 r8tr20 r9tr20 r10tr20 r11tr20 r12tr20 r13tr20
*r14tr20p r15tr20p
*r14tr20w r15tr20w

*****心理状态15分
*SER7(5分) + BWC20(2分) + CACT + SCIS(2分) + DY + MO + YR + DW(4分) + PRES + VP (2分)
*r5mstot r6mstot r7mstot r8mstot r9mstot r10mstot r11mstot r12mstot r13mstot 
*r14mstotp r15mstotp

*****认知能力35分
*r5cogtot r6cogtot r7cogtot r8cogtot r9cogtot r10cogtot r11cogtot r12cogtot r13cogtot 
*r14cogtotp r15cogtotp

*****认知能力27分
*r5cog27 r6cog27 r7cog27 r8cog27 r9cog27 r10cog27 r11cog27 r12cog27 r13cog27 r14cog27 r15cog27

*****痴呆症/认知分类
*r5dementia r6dementia r7dementia r8dementia r9dementia r10dementia r11dementia 
*r12dementia r13dementia r14dementia r15dementia
forvalues i=5/15 {
  recode r`i'cog27 (0/6=1) (7/11=2) (12/27=3),gen(r`i'dementia)	
}
label define dementia_ 1 "痴呆症" 2 "非痴呆的认知障碍" 3 "认知正常"
label values r5dementia r6dementia r7dementia r8dementia r9dementia r10dementia r11dementia ///
r12dementia r13dementia r14dementia r15dementia dementia_

*****收缩压
*r8bpsys r9bpsys r10bpsys r11bpsys r12bpsys r13bpsys r14bpsys

*****舒张压
*r8bpdia r9bpdia r10bpdia r11bpdia r12bpdia r13bpdia r14bpdia

*****脉搏测量值
*r8bppuls r9bppuls r10bppuls r11bppuls r12bppuls r13bppuls r14bppuls

*****双手的总合测量
*r8grp r9grp r10grp r11grp r12grp r13grp r14grp

*****左手握力最大值
*r8grpl r9grpl r10grpl r11grpl r12grpl r13grpl r14grpl

*****右手握力最大值
*r8grpr r9grpr r10grpr r11grpr r12grpr r13grpr r14grpr

*****双脚半前后站立秒数
*r8balsemi r9balsemi r10balsemi r11balsemi r12balsemi r13balsemi r14balsemi

*****双脚半前后站立站立测量过程中是否做了任何补偿动作来稳定自己
*r8balsemic r9balsemic r10balsemic r11balsemic r12balsemic r13balsemic r14balsemic

*****双脚并拢站立秒数
*r8balsbs r9balsbs r10balsbs r11balsbs r12balsbs r13balsbs r14balsbs

*****双脚并拢站立测量过程中是否做了任何补偿动作来稳定自己
*r8balsbsc r9balsbsc r10balsbsc r11balsbsc r12balsbsc r13balsbsc r14balsbsc
label values r8balsbsc r9balsbsc r10balsbsc r11balsbsc r12balsbsc r13balsbsc r14balsbsc yesno_

*****双脚前后成一直线站立秒数
*r8balful r9balful r10balful r11balful r12balful r13balful r14balful

*****双脚前后成一直线站立测量过程中是否做了任何补偿动作来稳定自己
*r8balfulc r9balfulc r10balfulc r11balfulc r12balfulc r13balfulc r14balfulc
label values r8balfulc r9balfulc r10balfulc r11balfulc r12balfulc r13balfulc r14balfulc yesno_

*****是否完成双脚前后成一直线站立测量要求的时间
*r8balfult r9balfult r10balfult r11balfult r12balfult r13balfult r14balfult
label values r8balfult r9balfult r10balfult r11balfult r12balfult r13balfult r14balfult yesno_

*****正常速度行走98.5英寸所需的最短秒数
*r8timwlk r9timwlk r10timwlk r11timwlk r12timwlk r13timwlk r14timwlk

*****测量的身体质量指数
*r8pmbmi r9pmbmi r10pmbmi r11pmbmi r12pmbmi r13pmbmi r14pmbmi

*****测量的身高m
*r8pmhght r9pmhght r10pmhght r11pmhght r12pmhght r13pmhght r14pmhght

*****测量的体重kg
*r8pmwght r9pmwght r10pmwght r11pmwght r12pmwght r13pmwght r14pmwght

*****测量的腰围(英寸)
*r8pmwaist r9pmwaist r10pmwaist r11pmwaist r12pmwaist r13pmwaist r14pmwaist

*****ADL/房间里行走是否困难
*r5walkra r6walkra r7walkra r8walkra r9walkra r10walkra r11walkra r12walkra r13walkra r14walkra r15walkra 
label values r5walkra r6walkra r7walkra r8walkra r9walkra r10walkra r11walkra r12walkra r13walkra r14walkra r15walkra yesno_

*****ADL/穿衣是否困难
*r5dressa r6dressa r7dressa r8dressa r9dressa r10dressa r11dressa r12dressa r13dressa r14dressa r15dressa 
label values r5dressa r6dressa r7dressa r8dressa r9dressa r10dressa r11dressa r12dressa r13dressa r14dressa r15dressa  yesno_

*****ADL/洗澡是否困难
*r5batha r6batha r7batha r8batha r9batha r10batha r11batha r12batha r13batha r14batha r15batha 
label values r5batha r6batha r7batha r8batha r9batha r10batha r11batha r12batha r13batha r14batha r15batha yesno_

*****ADL/吃饭是否困难
*r5eata r6eata r7eata r8eata r9eata r10eata r11eata r12eata r13eata r14eata r15eata
label values r5eata r6eata r7eata r8eata r9eata r10eata r11eata r12eata r13eata r14eata r15eata  yesno_

*****ADL/上下床是否困难
*r5beda r6beda r7beda r8beda r9beda r10beda r11beda r12beda r13beda r14beda r15beda 
label values r5beda r6beda r7beda r8beda r9beda r10beda r11beda r12beda r13beda r14beda r15beda yesno_

*****ADL/上厕所是否困难
*r5toilta r6toilta r7toilta r8toilta r9toilta r10toilta r11toilta r12toilta r13toilta r14toilta r15toilta
label values r5toilta r6toilta r7toilta r8toilta r9toilta r10toilta r11toilta r12toilta r13toilta r14toilta r15toilta yesno_

*****ADL总分(6分)
*r5adl6a r6adl6a r7adl6a r8adl6a r9adl6a r10adl6a r11adl6a r12adl6a r13adl6a r14adl6a r15adl6a

*****IADL/使用电话是否困难
*r5phonea r6phonea r7phonea r8phonea r9phonea r10phonea r11phonea r12phonea r13phonea r14phonea r15phonea
label values r5phonea r6phonea r7phonea r8phonea r9phonea r10phonea r11phonea r12phonea r13phonea r14phonea r15phonea yesno_

*****IADL/管理金钱是否困难
*r5moneya r6moneya r7moneya r8moneya r9moneya r10moneya r11moneya r12moneya r13moneya r14moneya r15moneya
label values r5moneya r6moneya r7moneya r8moneya r9moneya r10moneya r11moneya r12moneya r13moneya r14moneya r15moneya yesno_

*****IADL/服用药物是否困难
*r5medsa r6medsa r7medsa r8medsa r9medsa r10medsa r11medsa r12medsa r13medsa r14medsa r15medsa
label values r5medsa r6medsa r7medsa r8medsa r9medsa r10medsa r11medsa r12medsa r13medsa r14medsa r15medsa yesno_

*****IADL/购买杂货是否困难
*r5shopa r6shopa r7shopa r8shopa r9shopa r10shopa r11shopa r12shopa r13shopa r14shopa r15shopa
label values r5shopa r6shopa r7shopa r8shopa r9shopa r10shopa r11shopa r12shopa r13shopa r14shopa r15shopa yesno_

*****IADL/准备热饭是否困难
*r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa r10mealsa r11mealsa r12mealsa r13mealsa r14mealsa r15mealsa
label values r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa r10mealsa r11mealsa r12mealsa r13mealsa r14mealsa r15mealsa yesno_

*****IADL(5分)
*r5iadl5a r6iadl5a r7iadl5a r8iadl5a r9iadl5a r10iadl5a r11iadl5a r12iadl5a r13iadl5a r14iadl5a
label values r5iadl5a r6iadl5a r7iadl5a r8iadl5a r9iadl5a r10iadl5a r11iadl5a r12iadl5a r13iadl5a r14iadl5a yesno_

*****其他功能限制/步行几个街区
*r5walksa r6walksa r7walksa r8walksa r9walksa r10walksa r11walksa r12walksa r13walksa r14walksa r15walksa
label values r5walksa r6walksa r7walksa r8walksa r9walksa r10walksa r11walksa r12walksa r13walksa r14walksa r15walksa yesno_

*****其他功能限制/慢跑一英里
*r5joga r6joga r7joga r8joga r9joga r10joga r11joga r12joga r13joga r14joga r15joga
label values r5joga r6joga r7joga r8joga r9joga r10joga r11joga r12joga r13joga r14joga r15joga yesno_

*****其他功能限制/步行一个街区
*r5walk1a r6walk1a r7walk1a r8walk1a r9walk1a r10walk1a r11walk1a r12walk1a r13walk1a r14walk1a r15walk1a
label values r5walk1a r6walk1a r7walk1a r8walk1a r9walk1a r10walk1a r11walk1a r12walk1a r13walk1a r14walk1a r15walk1a yesno_

*****其他功能限制/坐约2小时
*r5sita r6sita r7sita r8sita r9sita r10sita r11sita r12sita r13sita r14sita r15sita
label values r5sita r6sita r7sita r8sita r9sita r10sita r11sita r12sita r13sita r14sita r15sita yesno_

*****其他功能限制/长时间坐着从椅子上站起来
*r5chaira r6chaira r7chaira r8chaira r9chaira r10chaira r11chaira r12chaira r13chaira r14chaira r15chaira
label values r5chaira r6chaira r7chaira r8chaira r9chaira r10chaira r11chaira r12chaira r13chaira r14chaira r15chaira yesno_

*****其他功能限制/不休息地爬几段楼梯
*r5climsa r6climsa r7climsa r8climsa r9climsa r10climsa r11climsa r12climsa r13climsa r14climsa r15climsa
label values r5climsa r6climsa r7climsa r8climsa r9climsa r10climsa r11climsa r12climsa r13climsa r14climsa r15climsa yesno_

*****其他功能限制/不休息地爬一段楼梯
*r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a r10clim1a r11clim1a r12clim1a r13clim1a r14clim1a r15clim1a
label values r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a r10clim1a r11clim1a r12clim1a r13clim1a r14clim1a r15clim1a yesno_

*****其他功能限制/弯腰跪着或蹲着
*r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa r10stoopa r11stoopa r12stoopa r13stoopa r14stoopa r15stoopa
label values r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa r10stoopa r11stoopa r12stoopa r13stoopa r14stoopa r15stoopa yesno_

*****其他功能限制/举起或搬运超过10磅的重物
*r5lifta r6lifta r7lifta r8lifta r9lifta r10lifta r11lifta r12lifta r13lifta r14lifta r15lifta
label values r5lifta r6lifta r7lifta r8lifta r9lifta r10lifta r11lifta r12lifta r13lifta r14lifta r15lifta yesno_

*****其他功能限制/从桌子上捡起一角硬币
*r5dimea r6dimea r7dimea r8dimea r9dimea r10dimea r11dimea r12dimea r13dimea r14dimea r15dimea
label values r5dimea r6dimea r7dimea r8dimea r9dimea r10dimea r11dimea r12dimea r13dimea r14dimea r15dimea yesno_

*****其他功能限制/手臂超过肩膀
*r5armsa r6armsa r7armsa r8armsa r9armsa r10armsa r11armsa r12armsa r13armsa r14armsa r15armsa
label values r5armsa r6armsa r7armsa r8armsa r9armsa r10armsa r11armsa r12armsa r13armsa r14armsa r15armsa yesno_

*****其他功能限制/推或拉大型物体
*r5pusha r6pusha r7pusha r8pusha r9pusha r10pusha r11pusha r12pusha r13pusha r14pusha r15pusha
label values r5pusha r6pusha r7pusha r8pusha r9pusha r10pusha r11pusha r12pusha r13pusha r14pusha r15pusha yesno_

*****总财富
*h5atotb h6atotb h7atotb h8atotb h9atotb h10atotb h11atotb h12atotb h13atotb h14atotb h15atotb

*****总财富(不包括个人退休帐户)
*h5atotw h6atotw h7atotw h8atotw h9atotw h10atotw h11atotw h12atotw h13atotw h14atotw h15atotw

*****非住房总财富总额
*h5atotn h6atotn h7atotn h8atotn h9atotn h10atotn h11atotn h12atotn h13atotn h14atotn h15atotn

*****个人的收入
*r5iearn r6iearn r7iearn r8iearn r9iearn r10iearn r11iearn r12iearn r13iearn r14iearn r15iearn

*****受访者两人的收入
*h5itot h6itot h7itot h8itot h9itot h10itot h11itot h12itot h13itot h14itot h15itot

*****目前是否领取任何养老金收入
*r5peninc r6peninc r7peninc r8peninc r9peninc r10peninc r11peninc r12peninc r13peninc r14peninc r15peninc
label values r5peninc r6peninc r7peninc r8peninc r9peninc r10peninc r11peninc r12peninc r13peninc r14peninc r15peninc yesno_

*****是否有当前工作的养老金计划
*r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen r10jcpen r11jcpen r12jcpen r13jcpen r14jcpen r15jcpen
label values r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen r10jcpen r11jcpen r12jcpen r13jcpen r14jcpen r15jcpen yesno_

*****是否有任何政府健康保险
*r10higov r11higov r12higov r13higov r14higov r15higov
label values r10higov r11higov r12higov r13higov r14higov r15higov yesno_

*****是否有老年健康保险
*r5higov r6higov r7higov r8higov r9higov r10govmr r11govmr r12govmr r13govmr r14govmr r15govmr
label values r5higov r6higov r7higov r8higov r9higov r10govmr r11govmr r12govmr r13govmr r14govmr r15govmr yesno_

*****是否有穷人健康保险
*r5govmd r6govmd r7govmd r8govmd r9govmd r10govmd r11govmd r12govmd r13govmd r14govmd r15govmd
label values r5govmd r6govmd r7govmd r8govmd r9govmd r10govmd r11govmd r12govmd r13govmd r14govmd r15govmd yesno_

*****是否有军人健康保险
*r5govva r6govva r7govva r8govva r9govva r10govva r11govva r12govva r13govva r14govva r15govva
label values r5govva r6govva r7govva r8govva r9govva r10govva r11govva r12govva r13govva r14govva r15govva yesno_

*****私人健康保险的数量
*r5prpcnt r6prpcnt r7prpcnt r8prpcnt r9prpcnt r10prpcnt r11prpcnt r12prpcnt r13prpcnt r14prpcnt r15prpcnt

*****是否有其现任或前任雇主提供的健康保险
*r10covr r11covr r12covr r13covr r14covr r15covr
label values r10covr r11covr r12covr r13covr r14covr r15covr yesno_

*****是否受其配偶雇主的健康保险
*r5covr r6covr r7covr r8covr r9covr r10covs r11covs r12covs r13covs r14covs r15covs
label values r5covr r6covr r7covr r8covr r9covr r10covs r11covs r12covs r13covs r14covs r15covs yesno_

*****是否有其他类型的保险
*r5hiothp r6hiothp r7hiothp r8hiothp r9hiothp r10hiothp r11hiothp r12hiothp r13hiothp r14hiothp r15hiothp
label values r5hiothp r6hiothp r7hiothp r8hiothp r9hiothp r10hiothp r11hiothp r12hiothp r13hiothp r14hiothp r15hiothp yesno_

*****是否有长期护理保险
*r5hiltc r6hiltc r7hiltc r8hiltc r9hiltc r10hiltc r11hiltc r12hiltc r13hiltc r14hiltc r15hiltc
label values r5hiltc r6hiltc r7hiltc r8hiltc r9hiltc r10hiltc r11hiltc r12hiltc r13hiltc r14hiltc r15hiltc yesno_

*****是否有人寿保险
*r5lifein r6lifein r7lifein r8lifein r9lifein r10lifein r11lifein r12lifein r13lifein r14lifein r15lifein
label values r5lifein r6lifein r7lifein r8lifein r9lifein r10lifein r11lifein r12lifein r13lifein r14lifein r15lifein yesno_

*****家庭人数
*h5hhres h6hhres h7hhres h8hhres h9hhres h10hhres h11hhres h12hhres h13hhres h14hhres h15hhres

*****是否认为自己退休
*r5sayret r6sayret r7sayret r8sayret r9sayret r10sayret r11sayret r12sayret r13sayret r14sayret r15sayret
label define sayret_ 0 "没有退休" 1 "完全退休" 2 "部分退休" 3 "不相关和缺失"
label values r5sayret r6sayret r7sayret r8sayret r9sayret r10sayret r11sayret r12sayret r13sayret r14sayret r15sayret sayret_

*****退休月份
*r5retmon r6retmon r7retmon r8retmon r9retmon r10retmon r11retmon r12retmon r13retmon r14retmon r15retmon

*****退休年份
*r5retyr r6retyr r7retyr r8retyr r9retyr r10retyr r11retyr r12retyr r13retyr r14retyr r15retyr

*****是否在有偿工作
*r5work r6work r7work r8work r9work r10work r11work r12work r13work r14work r15work
label values r5work r6work r7work r8work r9work r10work r11work r12work r13work r14work r15work yesno_

*****是否自雇
*r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp r10slfemp r11slfemp r12slfemp r13slfemp r14slfemp r15slfemp
label values r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp r10slfemp r11slfemp r12slfemp r13slfemp r14slfemp r15slfemp yesno_

*****退休状态
*r5retemp r6retemp r7retemp r8retemp r9retemp r10retemp r11retemp r12retemp r13retemp r14retemp r15retemp
label define retemp_ 0 "没有退休" 1 "退休" 2 "处于其他状态且退休"
label values r5retemp r6retemp r7retemp r8retemp r9retemp r10retemp r11retemp r12retemp r13retemp r14retemp r15retemp retemp_

*****是否失业
*r5unemp r6unemp r7unemp r8unemp r9unemp r10unemp r11unemp r12unemp r13unemp r14unemp r15unemp
label values r5unemp r6unemp r7unemp r8unemp r9unemp r10unemp r11unemp r12unemp r13unemp r14unemp r15unemp yesno_

*****生活满意度7分
*r8lbsatwlf r9lbsatwlf r10lbsatwlf r11lbsatwlf r12lbsatwlf r13lbsatwlf r14lbsatwlf r15lbsatwlf

*****留后调查问卷的抽样权重
*r8lbwgtr r9lbwgtr r10lbwgtr r11lbwgtr r12lbwgtr r13lbwgtr r14lbwgtr r15lbwgtr

*****是否有资格接受留后调查
*r8lbelig r9lbelig r10lbelig r11lbelig r12lbelig r13lbelig r14lbelig r15lbelig
label values r8lbelig r9lbelig r10lbelig r11lbelig r12lbelig r13lbelig r14lbelig r15lbelig yesno_

*****是否完成留后调查问卷
*r8lbcomp r9lbcomp r10lbcomp r11lbcomp r12lbcomp r13lbcomp r14lbcomp r15lbcomp
label values r8lbcomp r9lbcomp r10lbcomp r11lbcomp r12lbcomp r13lbcomp r14lbcomp r15lbcomp yesno_

*****大五人格特质/神经质
*r8lbneur r9lbneur r10lbneur r11lbneur r12lbneur r13lbneur r14lbneur r15lbneur

*****大五人格特质/外倾性
*r8lbext r9lbext r10lbext r11lbext r12lbext r13lbext r14lbext r15lbext

*****大五人格特质/开放性
*r8lbopen r9lbopen r10lbopen r11lbopen r12lbopen r13lbopen r14lbopen r15lbopen

*****大五人格特质/宜人性
*r8lbagr r9lbagr r10lbagr r11lbagr r12lbagr r13lbagr r14lbagr r15lbagr

*****大五人格特质/尽责性
*r8lbcon5 r9lbcon5 r10lbcon5 r11lbcon5 r12lbcon5 r13lbcon5 r14lbcon5 r15lbcon5

*****大五人格特质/尽责性
*r10lbcon10 r11lbcon10 r12lbcon10 r13lbcon10 r14lbcon10 r15lbcon10

*****孤独3项
*r8lblonely3 r9lblonely3 r10lblonely3 r11lblonely3 r12lblonely3 r13lblonely3 r14lblonely3 r15lblonely3

*****孤独11项
*r9lblonely11 r10lblonely11 r11lblonely11 r12lblonely11 r13lblonely11 r14lblonely11 r15lblonely11

******************************** Harmonized HRS ********************************
*****统一可比的教育程度
*raeducl
label define raeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values raeducl raeducl_

*****居住在城市还是农村
*h5rural h6rural h7rural h8rural h9rural h10rural h11rural h12rural h13rural h14rural h15rural
label define hrural_ 1 "农村" 0 "城市"
label values h5rural h6rural h7rural h8rural h9rural h10rural h11rural h12rural h13rural h14rural h15rural hrural_ 

*****是否使用互联网发邮件或其他目的
*r6email r7email r8email r9email r10email r11email r12email r13email r14email r15email
label values r6email r7email r8email r9email r10email r11email r12email r13email r14email r15email yesno_

*****自评视力
*r5sight r6sight r7sight r8sight r9sight r10sight r11sight r12sight r13sight r14sight r15sight
forvalues i=5/15 {
  recode r`i'sight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label define sight_ 5 "非常好" 4 "很好" 3 "好" 2 "一般" 1 "差" 0 "失明"
label values r5sight r6sight r7sight r8sight r9sight r10sight r11sight r12sight r13sight r14sight r15sight sight_ 

*****远视评分
*r5dsight r6dsight r7dsight r8dsight r9dsight r10dsight r11dsight r12dsight r13dsight r14dsight r15dsight
forvalues i=5/15{
  recode r`i'dsight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label define dsight_ 5 "非常好" 4 "很好" 3 "好" 2 "一般" 1 "差" 0 "失明"
label values r5dsight r6dsight r7dsight r8dsight r9dsight r10dsight r11dsight r12dsight r13dsight r14dsight r15dsight dsight_ 

*****远视评分
*r5nsight r6nsight r7nsight r8nsight r9nsight r10nsight r11nsight r12nsight r13nsight r14nsight r15nsight
forvalues i=5/15{
  recode r`i'dsight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label define nsight_ 5 "非常好" 4 "很好" 3 "好" 2 "一般" 1 "差" 0 "失明"
label values r5nsight r6nsight r7nsight r8nsight r9nsight r10nsight r11nsight r12nsight r13nsight r14nsight r15nsight nsight_ 

*****本期是否报告白内障手术
*r5catrct r6catrct r7catrct r8catrct r9catrct r10catrct r11catrct r12catrct r13catrct r14catrct r15catrct
label values r5catrct r6catrct r7catrct r8catrct r9catrct r10catrct r11catrct r12catrct r13catrct r14catrct r15catrct yesno_

*****曾经是否做过白内障手术
*r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte r10catrcte r11catrcte r12catrcte r13catrcte r14catrcte r15catrcte
label values r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte r10catrcte r11catrcte r12catrcte r13catrcte r14catrcte r15catrcte yesno_

*****曾经接受过青光眼治疗
*r5glaucoma r6glaucoma r7glaucoma r8glaucoma r9glaucoma r10glaucoma r11glaucoma r12glaucoma r13glaucoma r14glaucoma r15glaucoma
label values r5glaucoma r6glaucoma r7glaucoma r8glaucoma r9glaucoma r10glaucoma r11glaucoma r12glaucoma r13glaucoma r14glaucoma r15glaucoma yesno_

*****自评听力
*r5hearing r6hearing r7hearing r8hearing r9hearing r10hearing r11hearing r12hearing r13hearing r14hearing r15hearing
forvalues i=5/15{
  recode r`i'hearing (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define hearing_ 5 "非常好" 4 "很好" 3 "好" 2 "一般" 1 "差"
label values r5hearing r6hearing r7hearing r8hearing r9hearing r10hearing r11hearing r12hearing r13hearing r14hearing r15hearing hearing_

*****是否戴助听器
*r5hearaid r6hearaid r7hearaid r8hearaid r9hearaid r10hearaid r11hearaid r12hearaid r13hearaid r14hearaid r15hearaid
label values r5hearaid r6hearaid r7hearaid r8hearaid r9hearaid r10hearing r11hearing r12hearing r13hearing r14hearing r15hearing yesno_

*****过去2年中是否跌倒过
*r5fall r6fall r7fall r8fall r9fall r10fall r11fall r12fall r13fall r14fall r15fall
label values r5fall r6fall r7fall r8fall r9fall r10fall r11fall r12fall r13fall r14fall r15fall yesno_

*****因跌倒而受伤
*r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj r10fallinj r11fallinj r12fallinj r13fallinj r14fallinj r15fallinj
label values r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj r10fallinj r11fallinj r12fallinj r13fallinj r14fallinj r15fallinj yesno_

*****跌倒次数
*r5fallnum r6fallnum r7fallnum r8fallnum r9fallnum r10fallnum r11fallnum r12fallnum r13fallnum r14fallnum r15fallnum

*****曾经是否髋部骨折
*r5hipe r6hipe r7hipe r8hipe r9hipe r10hipe r11hipe r12hipe r13hipe r14hipe r15hipe
label values r5hipe r6hipe r7hipe r8hipe r9hipe r10hipe r11hipe r12hipe r13hipe r14hipe r15hipe yesno_

*****去年是否尿失禁
*r5urinai r6urinai r7urinai r8urinai r9urinai r10urinai r11urinai r12urinai r13urinai r14urinai r15urinai
label values r5urinai r6urinai r7urinai r8urinai r9urinai r10urinai r11urinai r12urinai r13urinai r14urinai r15urinai yesno_

*****上个月尿失禁的天数
*r5urinaf r6urinaf r7urinaf r8urinaf r9urinaf r10urinaf r11urinaf r12urinaf r13urinaf r14urinaf r15urinaf

*****是否失去了所有的牙齿
*r8noteeth r9noteeth r10noteeth r11noteeth r12noteeth r13noteeth r14noteeth r15noteeth
label values r8noteeth r9noteeth r10noteeth r11noteeth r12noteeth r13noteeth r14noteeth r15noteeth yesno_

*****经历睡眠问题的频率
*r6fallslp r7fallslp r8fallslp r9fallslp r10fallslp r11fallslp r12fallslp r13fallslp r14fallslp r15fallslp
label define sleep 1 "大多数" 2 "有时" 3 "很少或从不"
label values r6fallslp r7fallslp r8fallslp r9fallslp r10fallslp r11fallslp r12fallslp r13fallslp r14fallslp r15fallslp sleep_ 

*****在夜间醒来的频率
*r6wakent r7wakent r8wakent r9wakent r10wakent r11wakent r12wakent r13wakent r14wakent r15wakent
label values r6wakent r7wakent r8wakent r9wakent r10wakent r11wakent r12wakent r13wakent r14wakent r15wakent sleep_ 

*****醒得太早而无法再入睡的频率
*r6wakeup r7wakeup r8wakeup r9wakeup r10wakeup r11wakeup r12wakeup r13wakeup r14wakeup r15wakeup
label values r10wakeup r11wakeup r12wakeup r13wakeup r14wakeup r15wakeup sleep_

*****醒来时感到精力充沛的的频率
*r6rested r7rested r8rested r9rested r10rested r11rested r12rested r13rested r14rested r15rested
label values r10rested r11rested r12rested r13rested r14rested r15rested sleep_ 

*****是否服用药物来帮助他们入睡
*r8rxslp r9rxslp r10rxslp r11rxslp r12rxslp r13rxslp r14rxslp r15rxslp
label values r8rxslp r9rxslp r10rxslp r11rxslp r12rxslp r13rxslp r14rxslp r15rxslp yesno_

*****是否经常感到疼痛
*r5painfr r6painfr r7painfr r8painfr r9painfr r10painfr r11painfr r12painfr r13painfr r14painfr r15painfr
label values r5painfr r6painfr r7painfr r8painfr r9painfr r10painfr r11painfr r12painfr r13painfr r14painfr r15painfr yesno_ 

*****疼痛程度
*r5painlv r6painlv r7painlv r8painlv r9painlv r10painlv r11painlv r12painlv r13painlv r14painlv r15painlv
label define painlv_ 0 "没有" 1 "轻度" 2 "中度" 3 "严重"
label values r5painlv r6painlv r7painlv r8painlv r9painlv r10painlv r11painlv r12painlv r13painlv r14painlv r15painlv painlv_

*****是否疼痛干扰正常活动
*r5paina r6paina r7paina r8paina r9paina r10paina r11paina r12paina r13paina r14paina r15paina
label values r5paina r6paina r7paina r8paina r9paina r10paina r11paina r12paina r13paina r14paina r15paina yesno_ 

*****是否服用关节或肌肉疼痛的药物
* r8rxpain r9rxpain r10rxpain r11rxpain r12rxpain r13rxpain r14rxpain r15rxpain
label values r8rxpain r9rxpain r10rxpain r11rxpain r12rxpain r13rxpain r14rxpain r15rxpain yesno_

*****是否曾经做过子宫切除术
*r9hystere r10hystere r11hystere r12hystere r13hystere r14hystere r15hystere
label values r9hystere r10hystere r11hystere r12hystere r13hystere r14hystere r15hystere yesno_

*****最后一次月经的年龄
*r9lstmnspd r10lstmnspd r11lstmnspd r12lstmnspd r13lstmnspd r14lstmnspd r15lstmnspd

*****是否经历过脚或脚踝的持续肿胀
*r5swell r6swell r7swell r8swell r9swell r10swell r11swell r12swell r13swell r14swell r15swell
label values r5swell r6swell r7swell r8swell r9swell r10swell r11swell r12swell r13swell r14swell r15swell yesno_ 

*****在清醒时是否经历过呼吸短促
*r5breath r6breath r7breath r8breath r9breath r10breath r11breath r12breath r13breath r14breath r15breath
label values r5breath r6breath r7breath r8breath r9breath r10breath r11breath r12breath r13breath r14breath r15breath yesno_  

*****是否经历过持续的头晕或头晕
*r5dizzy r6dizzy r7dizzy r8dizzy r9dizzy r10dizzy r11dizzy r12dizzy r13dizzy r14dizzy r15dizzy
label values r5dizzy r6dizzy r7dizzy r8dizzy r9dizzy r10dizzy r11dizzy r12dizzy r13dizzy r14dizzy r15dizzy yesno_   

*****是否经历过背部疼痛或问题
*r5backp r6backp r7backp r8backp r9backp r10backp r11backp r12backp r13backp r14backp r15backp
label values r5backp r6backp r7backp r8backp r9backp r10backp r11backp r12backp r13backp r14backp r15backp yesno_

*****是否经历过持续性头痛
*r5headache r6headache r7headache r8headache r9headache r10headache r11headache r12headache r13headache r14headache r15headache
label values r5headache r6headache r7headache r8headache r9headache r10headache r11headache r12headache r13headache r14headache r15headache yesno_

*****是否经历过严重的疲劳或疲惫
*r5fatigue r6fatigue r7fatigue r8fatigue r9fatigue r10fatigue r11fatigue r12fatigue r13fatigue r14fatigue r15fatigue
label values r5fatigue r6fatigue r7fatigue r8fatigue r9fatigue r10fatigue r11fatigue r12fatigue r13fatigue r14fatigue r15fatigue yesno_

*****是否经历过持续的喘息、咳嗽或带痰
*r5wheeze r6wheeze r7wheeze r8wheeze r9wheeze r10wheeze r11wheeze r12wheeze r13wheeze r14wheeze r15wheeze
label values r5wheeze r6wheeze r7wheeze r8wheeze r9wheeze r10wheeze r11wheeze r12wheeze r13wheeze r14wheeze r15wheeze yesno_

*****是否曾经被诊断患有心脏病
*r10hrtatte r11hrtatte r12hrtatte r13hrtatte r14hrtatte r15hrtatte
label values r10hrtatte r11hrtatte r12hrtatte r13hrtatte r14hrtatte r15hrtatte yesno_ 

*****是否曾被诊断为心绞痛
*r10angine r11angine r12angine r13angine r14angine r15angine
label values r10angine r11angine r12angine r13angine r14angine r15angine yesno_

*****是否曾被诊断为充血性心力衰竭
*r10conhrtfe r11conhrtfe r12conhrtfe r13conhrtfe r14conhrtfe r15conhrtfe
label values r10conhrtfe r11conhrtfe r12conhrtfe r13conhrtfe r14conhrtfe r15conhrtfe yesno_ 

*****是否曾被诊断患有带状疱疹
*r9shingle r10shingle r11shingle r12shingle r13shingle r14shingle r15shingle
label values r9shingle r10shingle r11shingle r12shingle r13shingle r14shingle r15shingle yesno_

*****是否曾被诊断为心律异常
*r10hrtrhme r11hrtrhme r12hrtrhme r13hrtrhme r14hrtrhme r15hrtrhme
label values r10hrtrhme r11hrtrhme r12hrtrhme r13hrtrhme r14hrtrhme r15hrtrhme yesno_ 

*****是否曾有骨质疏松症
*r11osteoe r12osteoe r13osteoe r14osteoe r15osteoe 
label values r11osteoe r12osteoe r13osteoe r14osteoe r15osteoe yesno_  

*****是否曾经有过高胆固醇
*r12hchole r13hchole r14hchole r15hchole
label values r12hchole r13hchole r14hchole r15hchole yesno_ 

*****近两年是否心脏病发作
*r10hrtatt r11hrtatt r12hrtatt r13hrtatt r14hrtatt r15hrtatt
label values r10hrtatt r11hrtatt r12hrtatt r13hrtatt r14hrtatt r15hrtatt yesno_

*****近两年是否心绞痛
*r10angin r11angin r12angin r13angin r14angin r15angin
label values r10angin r11angin r12angin r13angin r14angin r15angin yesno_

*****近两年是否充血性心力衰竭
*r10conhrtf r11conhrtf r12conhrtf r13conhrtf r14conhrtf r15conhrtf
label values r10conhrtf r11conhrtf r12conhrtf r13conhrtf r14conhrtf r15conhrtf yesno_

*****近两年是否心律异常
*r10hrtrhm r11hrtrhm r12hrtrhm r13hrtrhm r14hrtrhm r15hrtrhm
label values r10hrtrhm r11hrtrhm r12hrtrhm r13hrtrhm r14hrtrhm r15hrtrhm yesno_

*****是否服用高血压药物
*r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp r10rxhibp r11rxhibp r12rxhibp r13rxhibp r14rxhibp r15rxhibp
label values r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp r10rxhibp r11rxhibp r12rxhibp r13rxhibp r14rxhibp r15rxhibp yesno_ 

*****是否服用口服糖尿病药物
*r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo r10rxdiabo r11rxdiabo r12rxdiabo r13rxdiabo r14rxdiabo r15rxdiabo
label values r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo r10rxdiabo r11rxdiabo r12rxdiabo r13rxdiabo r14rxdiabo r15rxdiabo yesno_ 

*****是否使用胰岛素注射剂或胰岛素泵治疗糖尿病
*r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiabi r11rxdiabi r12rxdiabi r13rxdiabi r14rxdiabi r15rxdiabi 
label values r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiabi r11rxdiabi r12rxdiabi r13rxdiabi r14rxdiabi r15rxdiabi yesno_  

*****是否服用口服药物或使用胰岛素注射治疗糖尿病
*r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiab r11rxdiab r12rxdiab r13rxdiab r14rxdiab r15rxdiab r10rxstrok 
label values r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiab r11rxdiab r12rxdiab r13rxdiab r14rxdiab r15rxdiab r10rxstrok yesno_ 

*****是否服用中风药物
*r5rxstrok r6rxstrok r7rxstrok r8rxstrok r9rxstrok r10rxstrok r11rxstrok r12rxstrok r13rxstrok r14rxstrok r15rxstrok r10rxangina 
label values r5rxstrok r6rxstrok r7rxstrok r8rxstrok r9rxstrok r10rxstrok r11rxstrok r12rxstrok r13rxstrok r14rxstrok r15rxstrok r10rxangina yesno_  

*****是否服用心绞痛药物
*r5rxangina r6rxangina r7rxangina r8rxangina r9rxangina r10rxangina r11rxangina r12rxangina r13rxangina r14rxangina r15rxangina 
label values r5rxangina r6rxangina r7rxangina r8rxangina r9rxangina r10rxangina r11rxangina r12rxangina r13rxangina r14rxangina r15rxangina  yesno_

*****是否服用充血性心力衰竭药物
*r5rxchf r6rxchf r7rxchf r8rxchf r9rxchf r10rxchf r11rxchf r12rxchf r13rxchf r14rxchf r15rxchf 
label values r5rxchf r6rxchf r7rxchf r8rxchf r9rxchf r10rxchf r11rxchf r12rxchf r13rxchf r14rxchf r15rxchf yesno_

*****是否服用关节炎或风湿病药物
*r5rxarthr r6rxarthr r7rxarthr r8rxarthr r9rxarthr r10rxarthr r11rxarthr
label values r5rxarthr r6rxarthr r7rxarthr r8rxarthr r9rxarthr r10rxarthr r11rxarthr yesno_

*****是否服用慢性肺部疾病的药物
*r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung r10rxlung r11rxlung r12rxlung r13rxlung r14rxlung r15rxlung 
label values r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung r10rxlung r11rxlung r12rxlung r13rxlung r14rxlung r15rxlung yesno_

*****是否因情绪、神经或精神问题而服用药物
*r5rxpsych r6rxpsych r7rxpsych r8rxpsych r9rxpsych r10rxpsych r11rxpsych 
label values r5rxpsych r6rxpsych r7rxpsych r8rxpsych r9rxpsych r10rxpsych r11rxpsych yesno_

*****是否因情绪、神经或精神问题而接受治疗
*r5trpsych r6trpsych r7trpsych r8trpsych r9trpsych r10trpsych r11trpsych r12trpsych r13trpsych r14trpsych r15trpsych 
label values r5trpsych r6trpsych r7trpsych r8trpsych r9trpsych r10trpsych r11trpsych r12trpsych r13trpsych r14trpsych r15trpsych yesno_

*****是否接受化疗或药物治疗癌症
*r5cncrchem r6cncrchem r7cncrchem r8cncrchem r9cncrchem r10cncrchem r11cncrchem r12cncrchem r13cncrchem r14cncrchem r15cncrchem 
label values r5cncrchem r6cncrchem r7cncrchem r8cncrchem r9cncrchem r10cncrchem r11cncrchem r12cncrchem r13cncrchem r14cncrchem r15cncrchem yesno_

*****是否接受过手术或活检以治疗癌症
*r5cncrsurg r6cncrsurg r7cncrsurg r8cncrsurg r9cncrsurg r10cncrsurg r11cncrsurg r12cncrsurg r13cncrsurg r14cncrsurg r15cncrsurg
label values r5cncrsurg r6cncrsurg r7cncrsurg r8cncrsurg r9cncrsurg r10cncrsurg r11cncrsurg r12cncrsurg r13cncrsurg r14cncrsurg r15cncrsurg yesno_ 

*****是否接受过放射或x射线治疗癌症
*r5cncrradn r6cncrradn r7cncrradn r8cncrradn r9cncrradn r10cncrradn r11cncrradn r12cncrradn r13cncrradn r14cncrradn r15cncrradn 
label values r5cncrradn r6cncrradn r7cncrradn r8cncrradn r9cncrradn r10cncrradn r11cncrradn r12cncrradn r13cncrradn r14cncrradn r15cncrradn  yesno_

*****是否接受过另一种未指明的癌症治疗
*r5cncrothr r6cncrothr r7cncrothr r8cncrothr r9cncrothr r10cncrothr r11cncrothr r12cncrothr r13cncrothr r14cncrothr r15cncrothr 
label values r5cncrothr r6cncrothr r7cncrothr r8cncrothr r9cncrothr r10cncrothr r11cncrothr r12cncrothr r13cncrothr r14cncrothr r15cncrothr yesno_

*****是否接受了治疗癌症的药物或治疗症状(疼痛、恶心、皮疹)
*r5cncrmeds r6cncrmeds r7cncrmeds r8cncrmeds r9cncrmeds r10cncrmeds r11cncrmeds r12cncrmeds r13cncrmeds r14cncrmeds r15cncrmeds
label values r5cncrmeds r6cncrmeds r7cncrmeds r8cncrmeds r9cncrmeds r10cncrmeds r11cncrmeds r12cncrmeds r13cncrmeds r14cncrmeds r15cncrmeds yesno_
 
*****是否因心脏病发作或心肌梗死而服用药物
*r5rxhrtat r6rxhrtat r7rxhrtat r8rxhrtat r9rxhrtat r10rxhrtat r11rxhrtat r12rxhrtat r13rxhrtat r14rxhrtat r15rxhrtat 
label values r5rxhrtat r6rxhrtat r7rxhrtat r8rxhrtat r9rxhrtat r10rxhrtat r11rxhrtat r12rxhrtat r13rxhrtat r14rxhrtat r15rxhrtat yesno_

*****是否服用治疗心脏问题的药物
*r5rxheart r6rxheart r7rxheart r8rxheart r9rxheart r10rxheart r11rxheart r12rxheart r13rxheart r14rxheart r15rxheart 
label values r5rxheart r6rxheart r7rxheart r8rxheart r9rxheart r10rxheart r11rxheart r12rxheart r13rxheart r14rxheart r15rxheart  yesno_

*****是否服用了与记忆有关的疾病的药物
*r9rxmemry r10rxmemry r11rxmemry r12rxmemry r13rxmemry r14rxmemry r15rxmemry
label values r9rxmemry r10rxmemry r11rxmemry r12rxmemry r13rxmemry r14rxmemry r15rxmemry yesno_

*****首次被诊断为糖尿病的年龄
*radiagdiab

*****最近被诊断出患有癌症的年龄
*r5reccancr r6reccancr r7reccancr r8reccancr r9reccancr r10reccancr r11reccancr r12reccancr r13reccancr r14reccancr r15reccancr

*****最近一次心脏病发作的年龄
*r5rechrtatt r6rechrtatt r7rechrtatt r8rechrtatt r9rechrtatt r10rechrtatt r11rechrtatt r12rechrtatt r13rechrtatt r14rechrtatt r15rechrtatt

*****最近一次中风的年龄
*r5recstrok r6recstrok r7recstrok r8recstrok r9recstrok r10recstrok r11recstrok r12recstrok r13recstrok r14recstrok r15recstrok

*****最近一次心脏病发作的年龄
*rafrhrtatt

*****首次被诊断为充血性心力衰竭的年龄
*radiagchf

*****首次被诊断为心律异常的年龄
*radiaghrtr

*****首次被诊断为心绞痛的年龄
*radiagangin

*****最近两年内进行过心脏手术
*r5hrtsrg r6hrtsrg r7hrtsrg r8hrtsrg r9hrtsrg r10hrtsrg r11hrtsrg r12hrtsrg r13hrtsrg r14hrtsrg r15hrtsrg

*****最近两年内进行过关节置换手术
*r5jointr r6jointr r7jointr r8jointr r9jointr r10jointr r11jointr r12jointr r13jointr r14jointr r15jointr
label values r5jointr r6jointr r7jointr r8jointr r9jointr r10jointr r11jointr r12jointr r13jointr r14jointr r15jointr yesno_

*****是否服用高胆固醇类药物
*r8rxhchol r9rxhchol r10rxhchol r11rxhchol r12rxhchol r13rxhchol r14rxhchol r15rxhchol
label values r8rxhchol r9rxhchol r10rxhchol r11rxhchol r12rxhchol r13rxhchol r14rxhchol r15rxhchol yesno_

*****是否服用治疗呼吸问题的药物
*r8rxbreath r9rxbreath r10rxbreath r11rxbreath r12rxbreath r13rxbreath r14rxbreath r15rxbreath
label values r8rxbreath r9rxbreath r10rxbreath r11rxbreath r12rxbreath r13rxbreath r14rxbreath r15rxbreath yesno_ 

*****是否服用胃病药物
*r8rxstom r9rxstom r10rxstom r11rxstom r12rxstom r13rxstom r14rxstom r15rxstom
label values r8rxstom r9rxstom r10rxstom r11rxstom r12rxstom r13rxstom r14rxstom r15rxstom yesno_

*****是否服用药物来帮助缓解焦虑或抑郁
*r8rxdepres r9rxdepres r10rxdepres r11rxdepres r12rxdepres r13rxdepres r14rxdepres r15rxdepres
label values r8rxdepres r9rxdepres r10rxdepres r11rxdepres r12rxdepres r13rxdepres r14rxdepres r15rxdepres yesno_  

*****是否服用阿司匹林以外的药物来稀释血液或防止血栓
*r11rxbldthn r12rxbldthn r13rxbldthn r14rxbldthn r15rxbldthn
label values r11rxbldthn r12rxbldthn r13rxbldthn r14rxbldthn r15rxbldthn yesno_ 

*****bmi分类(自报)
*r5bmicat r6bmicat r7bmicat r8bmicat r9bmicat r10bmicat r11bmicat r12bmicat r13bmicat r14bmicat r15bmicat
label define bmicat_ 1 "体重不足" 2 "正常体重" 3 "肥胖前期" 4 "肥胖等级1" 5 "肥胖等级2" 6 "肥胖等级3"
label values r5bmicat r6bmicat r7bmicat r8bmicat r9bmicat r10bmicat r11bmicat r12bmicat r13bmicat r14bmicat r15bmicat 

*****是否肥胖
*r5obese r6obese r7obese r8obese r9obese r10obese r11obese r12obese r13obese r14obese r15obese
label values r5obese r6obese r7obese r8obese r9obese r10obese r11obese r12obese r13obese r14obese r15obese yesno_

*****是否曾经酗酒
*r5drinkb r6drinkb r7drinkb r8drinkb r9drinkb r10drinkb r11drinkb r12drinkb r13drinkb r14drinkb r15drinkb
label values r5drinkb r6drinkb r7drinkb r8drinkb r9drinkb r10drinkb r11drinkb r12drinkb r13drinkb r14drinkb r15drinkb yesno_

*****酗酒天数
*r5binged r6binged r7binged r8binged r9binged r10binged r11binged r12binged r13binged r14binged r15binged

*****每天抽多少支烟
*r5smokef r6smokef r7smokef r8smokef r9smokef r10smokef r11smokef r12smokef r13smokef r14smokef r15smokef

*****开始吸烟的年龄
*r5strtsmok r6strtsmok r7strtsmok r8strtsmok r9strtsmok r10strtsmok r11strtsmok r12strtsmok r13strtsmok r14strtsmok r15strtsmok

*****戒烟的年龄
*r5quitsmok r6quitsmok r7quitsmok r8quitsmok r9quitsmok r10quitsmok r11quitsmok r12quitsmok r13quitsmok r14quitsmok r15quitsmok

*****是否曾接种过带状疱疹疫苗
*r9shnglshte r10shnglshte r11shnglshte r12shnglshte r13shnglshte r14shnglshte
label values r9shnglshte r10shnglshte r11shnglshte r12shnglshte r13shnglshte r14shnglshte yesno_

*****是否曾接种过肺炎疫苗
*r11pneushte r12pneushte r13pneushte r14pneushte r15pneushte
label values r11pneushte r12pneushte r13pneushte r14pneushte r15pneushte yesno_

*****正确命名月、月、年和星期的能力
*r5orient r6orient r7orient r8orient r9orient r10orient r11orient r12orient r13orient

*****数学表现能力进行评分的总结性测量
*r6numer r7numer r8numer r9numer r10numer r11numer r12numer r13numer r14numer r15numer

*****语言流利度分数
*r10verbf r11verbf r12verbf r13verbf r14verbf r15verbf

*****统一可比的母亲教育水平
*ramomeducl
label define ramomeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values ramomeducl ramomeducl_

*****父亲教育水平
*radadeducl
label define radadeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values radadeducl radadeducl_

*****16岁时父亲的职业
*radadoccup
label define radadoccup_ 1 "白领" 2 "蓝领" 3 "军队"
label values radadoccup radadoccup_ 

*****家庭的居住安排
*h5lvwith h6lvwith h7lvwith h8lvwith h9lvwith h10lvwith h11lvwith h12lvwith h13lvwith h14lvwith h15lvwith
label define lvwith_ 1 "独居" 2 "只与配偶生活在一起" 3 "只和孩子生活在一起" ///
  4 "与配偶和子女同住" 5 "与配偶、子女和/或其他家庭成员共同生活"
label values h5lvwith h6lvwith h7lvwith h8lvwith h9lvwith h10lvwith h11lvwith h12lvwith h13lvwith h14lvwith h15lvwith lvwith_

*****过去一年中是否至少每周参加一次宗教仪式
*r5relgwk r7relgwk r8relgwk r9relgwk r10relgwk r11relgwk r12relgwk r13relgwk r14relgwk r15relgwk
label values r5relgwk r7relgwk r8relgwk r9relgwk r10relgwk r11relgwk r12relgwk r13relgwk r14relgwk r15relgwk yesno_

*****过去一年中参加宗教仪式的频率
*r5socrelg_h r7socrelg_h r8socrelg_h r9socrelg_h r10socrelg_h r11socrelg_h r12socrelg_h r13socrelg_h r14socrelg_h r15socrelg_h
foreach i in 5 7 8 9 10 11 12 13 14 15 {
 recode r`i'socrelg_h (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define socrelg_h_ 5 "每周至少一次" 4 "每周一次" 3 "每月2~3次" 2 "每年一次或更多" 1 "没有"
label values r5socrelg_h r7socrelg_h r8socrelg_h r9socrelg_h r10socrelg_h r11socrelg_h r12socrelg_h r13socrelg_h r14socrelg_h r15socrelg_h socrelg_h_

*****是否每周参加任何社会活动
*r9socwk r10socwk r11socwk r12socwk r13socwk r14socwk r15socwk
label values r9socwk r10socwk r11socwk r12socwk r13socwk r14socwk r15socwk yesno_

*****是否每月参加任何社会活动
*r9socmn r10socmn r11socmn r12socmn r13socmn r14socmn r15socmn
label values r9socmn r10socmn r11socmn r12socmn r13socmn r14socmn r15socmn yesno_

*****是否为联邦、州或地方政府工作
*r8jgovtemp r9jgovtemp r10jgovtemp r11jgovtemp r12jgovtemp r13jgovtemp r14jgovtemp r15jgovtemp
label values r8jgovtemp r9jgovtemp r10jgovtemp r11jgovtemp r12jgovtemp r13jgovtemp r14jgovtemp r15jgovtemp yesno_

*****工作中对其他人的工资和晋升做出决定
*r5jsprvs r6jsprvs r7jsprvs r8jsprvs r9jsprvs r10jsprvs r11jsprvs r12jsprvs r13jsprvs r14jsprvs r15jsprvs
label values r5jsprvs r6jsprvs r7jsprvs r8jsprvs r9jsprvs r10jsprvs r11jsprvs r12jsprvs r13jsprvs r14jsprvs r15jsprvs yesno_

*****第一次收缩压读数
*r8systo1 r9systo1 r10systo1 r11systo1 r12systo1 r13systo1 r14systo1

*****第二次收缩压读数
*r8systo2 r9systo2 r10systo2 r11systo2 r12systo2 r13systo2 r14systo2

*****第三次收缩压读数
*r8systo3 r9systo3 r10systo3 r11systo3 r12systo3 r13systo3 r14systo3

*****收缩压读数的平均值
*r8systo r9systo r10systo r11systo r12systo r13systo r14systo

*****第一次脉冲读数
*r8diasto1 r9diasto1 r10diasto1 r11diasto1 r12diasto1 r13diasto1 r14diasto1

*****第二次脉冲读数
*r8diasto2 r9diasto2 r10diasto2 r11diasto2 r12diasto2 r13diasto2 r14diasto2

*****第三次脉冲读数
*r8diasto3 r9diasto3 r10diasto3 r11diasto3 r12diasto3 r13diasto3 r14diasto3

*****舒张压读数的平均值
*r8diasto r9diasto r10diasto r11diasto r12diasto r13diasto r14diasto

*****第一次脉冲读数
*r8pulse1 r9pulse1 r10pulse1 r11pulse1 r12pulse1 r13pulse1 r14pulse1

*****第二次脉冲读数
*r8pulse2 r9pulse2 r10pulse2 r11pulse2 r12pulse2 r13pulse2 r14pulse2

*****第三次脉冲读数
*r8pulse3 r9pulse3 r10pulse3 r11pulse3 r12pulse3 r13pulse3 r14pulse3

*****脉冲读数的平均值
*r8pulse r9pulse r10pulse r11pulse r12pulse r13pulse r14pulse

*****是否愿意并能够完成血压测试
*r8bpcomp r9bpcomp r10bpcomp r11bpcomp r12bpcomp r13bpcomp r14bpcomp
label values r8bpcomp r9bpcomp r10bpcomp r11bpcomp r12bpcomp r13bpcomp r14bpcomp yesno_

*****第一次呼吸测试结果
*r7puff1 r8puff1 r9puff1 r10puff1 r11puff1 r12puff1 r13puff1 r14puff1

*****第二次呼吸测试结果
*r7puff2 r8puff2 r9puff2 r10puff2 r11puff2 r12puff2 r13puff2 r14puff2

*****第三次呼吸测试结果
*r7puff3 r8puff3 r9puff3 r10puff3 r11puff3 r12puff3 r13puff3 r14puff3

*****呼吸测试的最大测量值
*r7puff r8puff r9puff r10puff r11puff r12puff r13puff r14puff

*****是否愿意并能够完成呼吸测试
*r7puffcomp r8puffcomp r9puffcomp r10puffcomp r11puffcomp r12puffcomp r13puffcomp r14puffcomp
label values r8puffcomp r9puffcomp r10puffcomp r11puffcomp r12puffcomp r13puffcomp r14puffcomp yesno_

*****左手第一次的力量测量值
*r7lgrip1 r8lgrip1 r9lgrip1 r10lgrip1 r11lgrip1 r12lgrip1 r13lgrip1 r14lgrip1

*****左手第二次的力量测量值
*r7lgrip2 r8lgrip2 r9lgrip2 r10lgrip2 r11lgrip2 r12lgrip2 r13lgrip2 r14lgrip2

*****右手第一次的力量测量值
*r7rgrip1 r8rgrip1 r9rgrip1 r10rgrip1 r11rgrip1 r12rgrip1 r13rgrip1 r14rgrip1

*****右手第二次的力量测量值
*r7rgrip2 r8rgrip2 r9rgrip2 r10rgrip2 r11rgrip2 r12rgrip2 r13rgrip2 r14rgrip2

*****左手最大手部力量测量值
*r7lgrip r8lgrip r9lgrip r10lgrip r11lgrip r12lgrip r13lgrip r14lgrip

*****右手最大手部力量测量值
*r7rgrip r8rgrip r9rgrip r10rgrip r11rgrip r12rgrip r13rgrip r14rgrip

*****是否愿意并能够完成握力测试
*r7gripcomp r8gripcomp r9gripcomp r10gripcomp r11gripcomp r12gripcomp r13gripcomp r14gripcomp
label values r7gripcomp r8gripcomp r9gripcomp r10gripcomp r11gripcomp r12gripcomp r13gripcomp r14gripcomp yesno_

*****双脚半前后站立的时间
*r8semitan r9semitan r10semitan r11semitan r12semitan r13semitan r14semitan

*****是否双脚半前后站立保持10秒
*r8semidone r9semidone r10semidone r11semidone r12semidone r13semidone r14semidone
label values r8semidone r9semidone r10semidone r11semidone r12semidone r13semidone r14semidone yesno_ 

*****是否愿意并能够完成双脚半前后站立
*r8semicomp r9semicomp r10semicomp r11semicomp r12semicomp r13semicomp r14semicomp
label values r8semicomp r9semicomp r10semicomp r11semicomp r12semicomp r13semicomp r14semicomp yesno_ 

*****双脚前后成一直线站立的时间
*r8fulltan r9fulltan r10fulltan r11fulltan r12fulltan r13fulltan r14fulltan

*****是否双脚前后成一直线站立保持整整30/60秒的平衡
*r8fulldone r9fulldone r10fulldone r11fulldone r12fulldone r13fulldone r14fulldone
label values r8fulldone r9fulldone r10fulldone r11fulldone r12fulldone r13fulldone r14fulldone yesno_ 

*****是否愿意并能够双脚前后成一直线站立
*r8fullcomp r9fullcomp r10fullcomp r11fullcomp r12fullcomp r13fullcomp r14fullcomp
label values r8fullcomp r9fullcomp r10fullcomp r11fullcomp r12fullcomp r13fullcomp r14fullcomp yesno_ 

*****双脚并拢站立测试的时间
*r8sbstan r9sbstan r10sbstan r11sbstan r12sbstan r13sbstan r14sbstan

*****是否在双脚并拢站立测试10秒内保持平衡
*r8sbsdone r9sbsdone r10sbsdone r11sbsdone r12sbsdone r13sbsdone r14sbsdone
label values r8sbsdone r9sbsdone r10sbsdone r11sbsdone r12sbsdone r13sbsdone r14sbsdone yesno_ 

*****是否愿意并且能够完成双脚并拢站立测试
*r8sbscomp r9sbscomp r10sbscomp r11sbscomp r12sbscomp r13sbscomp r14sbscomp
label values r8sbscomp r9sbscomp r10sbscomp r11sbscomp r12sbscomp r13sbscomp r14sbscomp yesno_ 

*****第一次行走速度
*r7wspeed1 r8wspeed1 r9wspeed1 r10wspeed1 r11wspeed1 r12wspeed1 r13wspeed1 r14wspeed1

*****第二次行走速度
*r7wspeed2 r8wspeed2 r9wspeed2 r10wspeed2 r11wspeed2 r12wspeed2 r13wspeed2 r14wspeed2

*****平均行走速度
*r7wspeed r8wspeed r9wspeed r10wspeed r11wspeed r12wspeed r13wspeed r14wspeed

*****是否愿意并且能够完成步行速度测试
*r7walkcomp r8walkcomp r9walkcomp r10walkcomp r11walkcomp r12walkcomp r13walkcomp r14walkcomp
label values r7walkcomp r8walkcomp r9walkcomp r10walkcomp r11walkcomp r12walkcomp r13walkcomp r14walkcomp yesno_

*****测量身高(米)
*r7mheight r8mheight r9mheight r10mheight r11mheight r12mheight r13mheight r14mheight

*****测量体重(公斤)
*r7mweight r8mweight r9mweight r10mweight r11mweight r12mweight r13mweight r14mweight

*****测量腰围(厘米)
*r8mwaist r9mwaist r10mwaist r11mwaist r12mwaist r13mwaist r14mwaist

*****测量BMI
*r7mbmi r8mbmi r9mbmi r10mbmi r11mbmi r12mbmi r13mbmi r14mbmi

*****BMI类别
*r7mbmicat r8mbmicat r9mbmicat r10mbmi r10mbmicat r11mbmicat r12mbmicat r13mbmicat r14mbmicat
label define mbmicat_ 1 "体重不足" 2 "正常体重" 3 "肥胖前期" 4 "肥胖1级" 5 "肥胖2级" 6 "肥胖3级"
label values r7mbmicat r8mbmicat r9mbmicat r10mbmi r10mbmicat r11mbmicat r12mbmicat r13mbmicat r14mbmicat mbmicat_

*****是否被归类为测量肥胖
*r7mobese r8mobese r9mobese r10mobese r11mobese r12mobese r13mobese r14mobese
label values r7mobese r8mobese r9mobese r10mobese r11mobese r12mobese r13mobese r14mobese yesno_

*****是否愿意并能够完成身高测量
*r7htcomp r8htcomp r9htcomp r10htcomp r11htcomp r12htcomp r13htcomp r14htcomp
label values r7htcomp r8htcomp r9htcomp r10htcomp r11htcomp r12htcomp r13htcomp r14htcomp yesno_

*****是否愿意并能够完成体重测量
*r7wtcomp r8wtcomp r9wtcomp r10wtcomp r11wtcomp r12wtcomp r13wtcomp r14wtcomp
label values r7wtcomp r8wtcomp r9wtcomp r10wtcomp r11wtcomp r12wtcomp r13wtcomp r14wtcomp yesno_ 

*****是否愿意并能够完成腰围测量
*r8watcomp r9watcomp r10watcomp r11watcomp r12watcomp r13watcomp r14watcomp
label values r8watcomp r9watcomp r10watcomp r11watcomp r12watcomp r13watcomp r14watcomp yesno_ 

*****左耳第一次听力6分
*r13hear_l1 r14hear_l1

*****右耳第一次听力6分
*r13hear_r1 r14hear_r1

*****左耳第二次听力6分
*r13hear_l2 r14hear_l2

*****右耳第二次听力6分
*r13hear_r2 r14hear_r2

*****左耳听力总12分
*r13hear_l r14hear_l

*****右耳听力总12分
*r13hear_r r14hear_r

*****是否愿意并能够完成听力测试
*r13hearcomp r14hearcomp
label values r13hearcomp r14hearcomp yesno_

*****是否佩戴助听器
*r13hear_aid r14hear_aid
label values r13hear_aid r14hear_aid yesno_

*****听力测试中是否出现任何问题
*r13hear_p r14hear_p
label values r13hear_p r14hear_p yesno_

*****重度抑郁发作
*通过焦虑症筛查的受访者被问及在他们感觉最糟糕的两周内是否经历过以下7种症状:
*对大多数事情失去兴趣;感到比平时更疲惫或精力不足;食欲变化(食欲不振或食欲增加，单独询问);
*比平时更难以入睡，并报告说每天晚上或几乎每天晚上都会发生这种情况;比平时更难集中注意力;
*对自己感到失望，觉得自己一无是处或毫无价值;
*思考了很多关于死亡的问题，无论是他们自己的，别人的，还是一般意义上的死亡

*****测量烦躁不安(抑郁情绪)
*r5cididep r6cididep r7cididep r8cididep r9cididep r10cididep r11cididep r12cididep r13cididep r14cididep r15cididep

*****测量快感缺乏(对通常能给他们带来快乐的事物失去兴趣)
*r5cidianh r6cidianh r7cidianh r8cidianh r9cidianh r10cidianh r11cidianh r12cidianh r13cidianh r14cidianh r15cidianh

*****遇到的症状总数
*r5cidisymp r6cidisymp r7cidisymp r8cidisymp r9cidisymp r10cidisymp r11cidisymp r12cidisymp r13cidisymp r14cidisymp r15cidisymp

*****是否有过可能的重度抑郁发作3+
*r5cidimde3 r6cidimde3 r7cidimde3 r8cidimde3 r9cidimde3 r10cidimde3 r11cidimde3 r12cidimde3 r13cidimde3 r14cidimde3 r15cidimde3

*****是否有过可能的重度抑郁发作5+
*r5cidimde5 r6cidimde5 r7cidimde5 r8cidimde5 r9cidimde5 r10cidimde5 r11cidimde5 r12cidimde5 r13cidimde5 r14cidimde5 r15cidimde5

*****对自己生活的满意程度7分
*r7lstsf r8lstsf r9lstsf r10lstsf r11lstsf r12lstsf r13lstsf r14lstsf r15lstsf

*****生活满意度5分量表
*r9satlife_h r10satlife_h r11satlife_h r12satlife_h r13satlife_h r14satlife_h r15satlife_h
label define satlife_h_ 1 "一点也不满意" 2 "不满意" 3 "有点满意" 4 "非常满意" 5 "完全满意"
label values r9satlife_h r10satlife_h r11satlife_h r12satlife_h r13satlife_h r14satlife_h r15satlife_h satlife_h_

*****生活满意度z标准化
*r9satlifez r10satlifez r11satlifez r12satlifez r13satlifez r14satlifez r15satlifez

*****社会等级自评(数字越大地位越高)
*r7cantril r8cantril r9cantril r10cantril r11cantril r12cantril r13cantril r14cantril r15cantril

*****过去30天内感到坚定的程度
*r9dtrmnd r10dtrmnd r11dtrmnd r12dtrmnd r13dtrmnd r14dtrmnd r15dtrmnd 
label define positive_ 1 "一点也不" 2 "一点" 3 "适度" 4 "相当多" 5 "非常" 
label values r9dtrmnd r10dtrmnd r11dtrmnd r12dtrmnd r13dtrmnd r14dtrmnd r15dtrmnd  positive_

*****过去30天内感到热情的程度
*r9enthstc r10enthstc r11enthstc r12enthstc r13enthstc r14enthstc r15enthstc 
label values r9enthstc r10enthstc r11enthstc r12enthstc r13enthstc r14enthstc r15enthstc positive_

*****过去30天内感到活跃的程度
*r9active r10active r11active r12active r13active r14active r15active
label values r9active r10active r11active r12active r13active r14active r15active positive_ 

*****过去30天内感到自豪的程度
*r9proud r10proud r11proud r12proud r13proud r14proud r15proud 
label values r9proud r10proud r11proud r12proud r13proud r14proud r15proud positive_

*****过去30天内感兴趣的程度
*r9intrstd r10intrstd r11intrstd r12intrstd r13intrstd r14intrstd r15intrstd 
label values r9intrstd r10intrstd r11intrstd r12intrstd r13intrstd r14intrstd r15intrstd positive_

*****过去30天内感到快乐的程度
*r9fhappy r10fhappy r11fhappy r12fhappy r13fhappy r14fhappy r15fhappy 
label values r9fhappy r10fhappy r11fhappy r12fhappy r13fhappy r14fhappy r15fhappy positive_

*****过去30天内感到关注的程度
*r9attntv r10attntv r11attntv r12attntv r13attntv r14attntv r15attntv 
label values r9attntv r10attntv r11attntv r12attntv r13attntv r14attntv r15attntv positive_

*****过去30天内感到满意的程度
*r9content r10content r11content r12content r13content r14content r15content 
label values r9content r10content r11content r12content r13content r14content r15content positive_

*****过去30天内受到启发的程度
*r9insprd r10insprd r11insprd r12insprd r13insprd r14insprd r15insprd 
label values r9insprd r10insprd r11insprd r12insprd r13insprd r14insprd r15insprd positive_

*****过去30天内感到有希望的程度
*r9hopeful r10hopeful r11hopeful r12hopeful r13hopeful r14hopeful r15hopeful 
label values r9hopeful r10hopeful r11hopeful r12hopeful r13hopeful r14hopeful r15hopeful positive_

*****过去30天内感到警觉的程度
*r9alert r10alert r11alert r12alert r13alert r14alert r15alert 
label values r9alert r10alert r11alert r12alert r13alert r14alert r15alert positive_

*****过去30天内感到平静的程度
*r9calm r10calm r11calm r12calm r13calm r14calm r15calm 
label values r9calm r10calm r11calm r12calm r13calm r14calm r15calm positive_

*****过去30天内感到兴奋的程度
*r9exctd r10exctd r11exctd r12exctd r13exctd r14exctd r15exctd
label values r9exctd r10exctd r11exctd r12exctd r13exctd r14exctd r15exctd positive_

*****13项积极情绪指数
*r9panasp13 r10panasp13 r11panasp13 r12panasp13 r13panasp13 r14panasp13 r15panasp13 

*****过去30天内感到害怕的程度
*r9afraid r10afraid r11afraid r12afraid r13afraid r14afraid r15afraid 
label define negative_ 1 "一点也不" 2 "一点" 3 "适度" 4 "相当多" 5 "非常" 
label values r9afraid r10afraid r11afraid r12afraid r13afraid r14afraid r15afraid negative_

*****过去30天内感到不安的程度
*r9fupset r10fupset r11fupset r12fupset r13fupset r14fupset r15fupset 
label values r9fupset r10fupset r11fupset r12fupset r13fupset r14fupset r15fupset negative_

*****过去30天内感到内疚的程度
*r9guilty r10guilty r11guilty r12guilty r13guilty r14guilty r15guilty 
label values r9guilty r10guilty r11guilty r12guilty r13guilty r14guilty r15guilty negative_

*****过去30天内感到害怕的程度
*r9scared r10scared r11scared r12scared r13scared r14scared r15scared 
label values r9scared r10scared r11scared r12scared r13scared r14scared r15scared negative_

*****过去30天内感到沮丧的程度
*r9frustrat r10frustrat r11frustrat r12frustrat r13frustrat r14frustrat r15frustrat
label values r9frustrat r10frustrat r11frustrat r12frustrat r13frustrat r14frustrat r15frustrat negative_

*****过去30天内感到无聊的程度
*r9bored r10bored r11bored r12bored r13bored r14bored r15bored 
label values r9bored r10bored r11bored r12bored r13bored r14bored r15bored negative_

*****过去30天内感受到敌意的程度
*r9hostile r10hostile r11hostile r12hostile r13hostile r14hostile r15hostile 
label values r9hostile r10hostile r11hostile r12hostile r13hostile r14hostile r15hostile negative_

*****过去30天内感到紧张的程度
*r9jittery r10jittery r11jittery r12jittery r13jittery r14jittery r15jittery
label values r9jittery r10jittery r11jittery r12jittery r13jittery r14jittery r15jittery negative_

*****过去30天内感到羞耻的程度
*r9ashamd r10ashamd r11ashamd r12ashamd r13ashamd r14ashamd r15ashamd 
label values r9ashamd r10ashamd r11ashamd r12ashamd r13ashamd r14ashamd r15ashamd  negative_

*****过去30天内感到紧张的程度
*r9nrvous r10nrvous r11nrvous r12nrvous r13nrvous r14nrvous r15nrvous 
label values r9nrvous r10nrvous r11nrvous r12nrvous r13nrvous r14nrvous r15nrvous negative_

*****过去30天内感到悲伤的程度
*r9pfsad r10pfsad r11pfsad r12pfsad r13pfsad r14pfsad r15pfsad 
label values r9pfsad r10pfsad r11pfsad r12pfsad r13pfsad r14pfsad r15pfsad negative_

*****过去30天内感到痛苦的程度
*r9dstres r10dstres r11dstres r12dstres r13dstres r14dstres r15dstres 
label values r9dstres r10dstres r11dstres r12dstres r13dstres r14dstres r15dstres negative_

*****12个项目的负面情绪指数
*r9panasn12 r10panasn12 r11panasn12 r12panasn12 r13panasn12 r14panasn12 r15panasn12 
label values r9panasn12 r10panasn12 r11panasn12 r12panasn12 r13panasn12 r14panasn12 r15panasn12  negative_

*****衰弱指数
*r5frailty r6frailty r7frailty r8frailty r9frailty r10frailty r11frailty 
*r12frailty r13frailty r14frailty r15frailty
*衰弱定义为衰弱指数≥25，非衰弱定义为衰弱指数<25
forvalues i=5/9 {
  gen r`i'memory1=r`i'memrye 
}

forvalues i=10/15 {
  gen r`i'memory1=0 if r`i'alzhee==0 & r`i'demene==0
  replace r`i'memory1=1 if r`i'alzhee==1 | r`i'demene==1
}

forvalues i=5/15 {
  recode r`i'sight (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'sight1)
}

forvalues i=5/15 {
  recode r`i'hearing (1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'hearing1)
  replace r`i'hearing1=1 if r`i'hearaid==1
}

forvalues i=5/15 {
  recode r`i'shlt (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'shlt1)
}

gen r14tr20=r14tr20w
replace r14tr20=r14tr20p if mi(r14tr20)
gen r15tr20=r15tr20w
replace r15tr20=r15tr20p if mi(r15tr20)
gen r14bwc20=r14bwc20p
replace r14bwc20=r14bwc20w if mi(r14bwc20)
gen r15bwc20=r15bwc20p
replace r15bwc20=r15bwc20w if mi(r15bwc20)
gen r14mo=r14mop
gen r15mo=r15mop
gen r14dy=r14dyp
gen r15dy=r15dyp
gen r14yr=r14yrp 
gen r15yr=r15yrp
gen r15dw=r15dwp
gen r14ser7=r14ser7p
replace r14ser7=r14ser7w if mi(r14ser7)
gen r15ser7=r15ser7p
replace r15ser7=r15ser7w if mi(r15ser7)
forvalues i=5/15 {
  egen r`i'cog_total=rowtotal(r`i'tr20 r`i'mo r`i'dy r`i'yr r`i'dw r`i'ser7)
  gen r`i'cogition=(29-r`i'tr20 - r`i'mo - r`i'dy - r`i'yr - r`i'dw - r`i'ser7)/29
}

forvalues i=5/15 {
egen r`i'frailty=rowtotal(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'psyche r`i'memory1 r`i'sight1 r`i'hearing1 r`i'shlt1 ///
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'moneya r`i'medsa r`i'shopa /// 
  r`i'mealsa r`i'walk1a r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa ///
  r`i'armsa r`i'depressive r`i'cogition),mi
replace r`i'frailty=r`i'frailty/30*100
}

*****记忆的z标准化
*r5memory_z r6memory_z r7memory_z r8memory_z r9memory_z r10memory_z r11memory_z r12memory_z r13memory_z r14memory_z r15memory_z
*r5orient_z r6orient_z r7orient_z r8orient_z r9orient_z r10orient_z r11orient_z r12orient_z r13orient_z 
*r5executive_z r6executive_z r7executive_z r8executive_z r9executive_z r10executive_z r11executive_z r12executive_z r13executive_z 
*r14executive_z  r15executive_z 
*r5tcog_z_z r6tcog_z_z r7tcog_z_z r8tcog_z_z r9tcog_z_z r10tcog_z_z r11tcog_z_z r12tcog_z_z r13tcog_z_z 

forvalues i=5/15 {
 egen r`i'mean_memory=mean(r5tr20)
 egen r`i'sd_memory=sd(r5tr20)
 gen r`i'memory_z=(r`i'tr20-r`i'mean_memory)/r`i'sd_memory
}

*****定向的z标准化(ref基线)
forvalues i=5/13 {
 egen r`i'mean_orient=mean(r5orient)
 egen r`i'sd_orient=sd(r5orient)
 gen r`i'orient_z=(r`i'orient-r`i'mean_orient)/r`i'sd_orient
}

*****执行的z标准化(ref基线)
forvalues i=5/15 {
 egen r`i'executive=rowtotal(r`i'bwc20 r`i'ser7),mi
 egen r`i'mean_executive=mean(r5executive)
 egen r`i'executive_sd=sd(r5executive)
 gen r`i'executive_z=(r`i'executive-r`i'mean_executive)/r`i'executive_sd
}
*****总体认知能力z标准化(ref基线)
forvalues i=5/13 {
 egen r`i'tcog_z=rowmean(r`i'memory_z r`i'orient_z r`i'executive_z)
 egen r`i'tcog_z_mean=mean(r5tcog_z)
 egen r`i'tcog_z_sd=sd(r5tcog_z)
 gen r`i'tcog_z_z=(r`i'tcog_z-r`i'tcog_z_mean)/r`i'tcog_z_sd
}

*****是否定期每周中度以上的身体活动
*r7pa r8pa r9pa r10pa r11pa r12pa r13pa r14pa r15pa 
forvalues i=7/15 {
  gen r`i'pa=1 if (r`i'vgactx>=2 & !mi(r`i'vgactx)) | (r`i'mdactx>=2 & !mi(r`i'mdactx))
  replace r`i'pa=0 if (r`i'vgactx<2 & !mi(r`i'vgactx)) & (r`i'mdactx<2 & !mi(r`i'mdactx))
}
label values r7pa r8pa r9pa r10pa r11pa r12pa r13pa r14pa r15pa yesno_

*****MET等效活动点
*r7met r8met r9met r10met r11met r12met r13met r14met r15met
forvalues i=7/15 {
  recode r`i'vgactx (0=0) (1=4.25) (2=9) (3=13) (4=17),gen(r`i'met3)
  recode r`i'mdactx (0=0) (1=2.5) (2=5) (3=7.5) (4=10),gen(r`i'met2)
  recode r`i'ltactx (0=0) (1=1) (2=2) (3=3) (4=4),gen(r`i'met1)
  egen r`i'met=rowtotal(r`i'met3 r`i'met2 r`i'met1),mi
}


*****按需求间隔依赖性分类划分的功能依赖性
*r5dependency r6dependency r7dependency r8dependency r9dependency r10dependency r11dependency
*r12dependency r13dependency r14dependency r15dependency
label define dependency_ 0 "独立" 1 "低依赖性" 2 "中等依赖性" 3 "高依赖性"
forvalues i=5/15 {
  gen r`i'dependency=.
  replace r`i'dependency=0 if r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0 & ///
  r`i'mealsa==0 & r`i'medsa==0 & r`i'eata==0 & r`i'dressa==0 & r`i'beda==0 & r`i'toilta==0 & r`i'walkra==0 
  replace r`i'dependency=1 if r`i'batha==1 | r`i'moneya==1 | r`i'shopa==1 | r`i'phonea==1 
  replace r`i'dependency=2 if (r`i'mealsa==1 | r`i'medsa==1) & (r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0) 
  replace r`i'dependency=3 if (r`i'eata==1 | r`i'dressa==1 | r`i'beda==1 | r`i'toilta==1 | r`i'walkra==1) & ///
  (r`i'mealsa==0 & r`i'medsa==0 & r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0) 
  label values r`i'dependency dependency_
}

*****与子女至少每月联系一次
*r8cntc r9cntc r10cntc r11cntc r12cntc r13cntc r14cntc r15cntc
label values r8cntc r9cntc r10cntc r11cntc r12cntc r13cntc r14cntc r15cntc yesno_

*****与亲戚至少每月联系一次
*r8cntr r9cntr r10cntr r11cntr r12cntr r13cntr r14cntr r15cntr
label values r8cntr r9cntr r10cntr r11cntr r12cntr r13cntr r14cntr r15cntr yesno_

*****与朋友至少每月联系一次
*r8cntf r9cntf r10cntf r11cntf r12cntf r13cntf r14cntf r15cntf
label values r8cntf r9cntf r10cntf r11cntf r12cntf r13cntf r14cntf r15cntf yesno_

*****是否有爱好
*r9hobby r10hobby r11hobby r12hobby r13hobby r14hobby r15hobby 
label values r9hobby r10hobby r11hobby r12hobby r13hobby r14hobby r15hobby yesno_

*****各种社会活动
*r9care_adult r10care_adult r11care_adult  r12care_adult r13care_adult r14care_adult r15care_adult 
*r10with_grand r11with_grand r12with_grand r13with_grand r14with_grand r15with_grand 
*r9volunteer r10volunteer r11volunteer r12volunteer r13volunteer r14volunteer r15volunteer
*r9charity r10charity  r11charity r12charity r13charity r14charity r15charity
*r9education r10education r11education r12education r13education r14education r15education
*r9club r10club r11club r12club r13club r14club r15club
*r9nonreligious r10nonreligious r11nonreligious r12nonreligious r13nonreligious r14nonreligious r15nonreligious
*r9pray r10pray r11pray r12pray r13pray r14pray r15pray 
*r9read r10read  r11read r12read r13read r14read r15read
*r9watch_tel r10watch_tel r11watch_tel r12watch_tel r13watch_tel r14watch_tel r15watch_tel 
*r9word_game r10word_game r11word_game r12word_game r13word_game r14word_game r15word_game 
*r9play_card r10play_card r11play_card r12play_card r13play_card r14play_card r15play_card 
*r9writing r10writing r11writing r12writing r13writing r14writing r15writing 
*r9use_computer r10use_computer r11use_computer r12use_computer r13use_computer r14use_computer r15use_computer
*r9gardening r10gardening r11gardening r12gardening r13gardening r14gardening r15gardening 
*r9bake r10bake r11bake r12bake r13bake r14bake r15bake r16bake r17bake 
*r9sew r10sew r11sew r12sew r13sew r14sew r15sew 
*r9do_hobby r10do_hobby r11do_hobby r12do_hobby r13do_hobby r14do_hobby 
*r9exercize r10exercize r11exercize r12exercize r13exercize r14exercize r15exercize
*r9walk r10walk r11walk  r12walk r13walk r14walk r15walk 
*r13art r14art r15art 
label define freq_act 1 "每天" 2 "每周多次" 3 "每周一次" 4 "每月多次" 5 "每月至少一次" 6 "上月没有" 7 "从来没有"
label values r9care_adult r10care_adult r11care_adult  r12care_adult r13care_adult r14care_adult r15care_adult ///
r10with_grand r11with_grand r12with_grand r13with_grand r14with_grand r15with_grand  ///
r9volunteer r10volunteer r11volunteer r12volunteer r13volunteer r14volunteer r15volunteer ///
r9charity r10charity  r11charity r12charity r13charity r14charity r15charity ///
r9education r10education r11education r12education r13education r14education r15education ///
r9club r10club r11club r12club r13club r14club r15club ///
r9nonreligious r10nonreligious r11nonreligious r12nonreligious r13nonreligious r14nonreligious r15nonreligious ///
r9pray r10pray r11pray r12pray r13pray r14pray r15pray  ///
r9read r10read  r11read r12read r13read r14read r15read ///
r10watch_tel r11watch_tel r12watch_tel r13watch_tel r14watch_tel r15watch_tel  ///
r9word_game r10word_game r11word_game r12word_game r13word_game r14word_game r15word_game  ///
r9play_card r10play_card r11play_card r12play_card r13play_card r14play_card r15play_card  ///
r9writing r10writing r11writing r12writing r13writing r14writing r15writing  ///
r9use_computer r10use_computer r11use_computer r12use_computer r13use_computer r14use_computer r15use_computer ///
r9gardening r10gardening r11gardening r12gardening r13gardening r14gardening r15gardening  ///
r9bake r10bake r11bake r12bake r13bake r14bake r15bake  ///
r9sew r10sew r11sew r12sew r13sew r14sew r15sew  ///
r9do_hobby r10do_hobby r11do_hobby r12do_hobby r13do_hobby r14do_hobby  ///
r9exercize r10exercize r11exercize r12exercize r13exercize r14exercize r15exercize ///
r9walk r10walk r11walk  r12walk r13walk r14walk r15walk  ///
r13art r14art r15art freq_act

*****过去12个月志愿者服务
*r8vol r9vol r10vol r11vol r12vol r13vol r14vol r15vol
label values r8vol r9vol r10vol r11vol r12vol r13vol r14vol r15vol yesno_

*****志愿服务时间区间
*r8hour_vol r9hour_vol r10hour_vol r11hour_vol r12hour_vol r13hour_vol r14hour_vol r15hour_vol 
label define hour_ 0 "没有" 1 "1~99小时" 2 "100~199小时" 3 "200+小时"
label values r8hour_vol r9hour_vol r10hour_vol r11hour_vol r12hour_vol r13hour_vol r14hour_vol r15hour_vol hour_

*****是否有子女住在10英里以内
*r8away_child r9away_child r10away_child r11away_child r12away_child r13away_child r14away_child r15away_child
label values r8away_child r9away_child r10away_child r11away_child r12away_child r13away_child r14away_child r15away_child yesno_



*****保留特定变量
keep h5atotb h6atotb h7atotb h8atotb h9atotb h10atotb h11atotb h12atotb h13atotb h14atotb h15atotb ///
h5atotn h6atotn h7atotn h8atotn h9atotn h10atotn h11atotn h12atotn h13atotn h14atotn h15atotn ///
h5atotw h6atotw h7atotw h8atotw h9atotw h10atotw h11atotw h12atotw h13atotw h14atotw h15atotw ///
h5hhid h6hhid h7hhid h8hhid h9hhid h10hhid h11hhid h12hhid h13hhid h14hhid h15hhid ///
h5hhres h6hhres h7hhres h8hhres h9hhres h10hhres h11hhres h12hhres h13hhres h14hhres h15hhres ///
h5itot h6itot h7itot h8itot h9itot h10itot h11itot h12itot h13itot h14itot h15itot ///
h5lvwith h6lvwith h7lvwith h8lvwith h9lvwith h10lvwith h11lvwith h12lvwith h13lvwith h14lvwith h15lvwith ///
h5rural h6rural h7rural h8rural h9rural h10rural h11rural h12rural h13rural h14rural h15rural ///
hacohort ///
hhidpn ///
inw5 inw6 inw7 inw8 inw9 inw10 inw11 inw12 inw13 inw14 inw15 ///
r10alzhe r11alzhe r12alzhe r13alzhe r14alzhe r15alzhe ///
r10alzhee r11alzhee r12alzhee r13alzhee r14alzhee r15alzhee ///
r10angin r11angin r12angin r13angin r14angin r15angin ///
r10angine r11angine r12angine r13angine r14angine r15angine ///
r5cogtot r6cogtot r7cogtot r8cogtot r9cogtot r10cogtot r11cogtot r12cogtot r13cogtot  ///
r10conhrtf r11conhrtf r12conhrtf r13conhrtf r14conhrtf r15conhrtf ///
r10conhrtfe r11conhrtfe r12conhrtfe r13conhrtfe r14conhrtfe r15conhrtfe ///
r10covr r11covr r12covr r13covr r14covr r15covr ///
r10demen r11demen r12demen r13demen r14demen r15demen ///
r10demene r11demene r12demene r13demene r14demene r15demene ///
r10higov r11higov r12higov r13higov r14higov r15higov ///
r10hrtatt r11hrtatt r12hrtatt r13hrtatt r14hrtatt r15hrtatt ///
r10hrtatte r11hrtatte r12hrtatte r13hrtatte r14hrtatte r15hrtatte ///
r10hrtrhm r11hrtrhm r12hrtrhm r13hrtrhm r14hrtrhm r15hrtrhm ///
r10hrtrhme r11hrtrhme r12hrtrhme r13hrtrhme r14hrtrhme r15hrtrhme ///
r5medsa r6medsa r7medsa r8medsa r9medsa r10medsa r11medsa r12medsa r13medsa r14medsa r15medsa ///
r10verbf r11verbf r12verbf r13verbf r14verbf r15verbf ///
r11osteoe r12osteoe r13osteoe r14osteoe r15osteoe  ///
r11pneushte r12pneushte r13pneushte r14pneushte r15pneushte ///
r11rxbldthn r12rxbldthn r13rxbldthn r14rxbldthn r15rxbldthn ///
r12hchole r13hchole r14hchole r15hchole ///
r13hear_aid r14hear_aid ///
r13hear_l r14hear_l ///
r13hear_l1 r14hear_l1 ///
r13hear_l2 r14hear_l2 ///
r13hear_p r14hear_p ///
r13hear_r r14hear_r ///
r13hear_r1 r14hear_r1 ///
r13hear_r2 r14hear_r2 ///
r13hearcomp r14hearcomp ///
r13sleepe r14sleepe r15sleepe ///
r14bwc20p r15bwc20p  ///
r14bwc20w r15bwc20w ///
r14cactp r15cactp ///
r14cogtotp r15cogtotp ///
r14dlrcp r15dlrcp ///
r14dlrcw r15dlrcw ///
r14dwp r15dwp ///
r14dyp r15dyp ///
r14imrcp r14imrcw  ///
r14mop r15mop ///
r14mstotp r15mstotp ///
r14presp r15presp ///
r14scisp r15scisp ///
r14ser7p r15ser7p  ///
r14ser7w r15ser7w ///
r14tr20p r15tr20p ///
r14tr20w r15tr20w ///
r14vocabp r15vocabp ///
r14vpp r15vpp ///
r14yrp r15yrp ///
r15imrcp r15imrcw ///
r5smoken r6smoken r7smoken r8smoken r9smoken r10smoken r11smoken r12smoken r13smoken r14smoken r15smoken ///
r5adl6a r6adl6a r7adl6a r8adl6a r9adl6a r10adl6a r11adl6a r12adl6a r13adl6a r14adl6a r15adl6a ///
r5agey_b r6agey_b r7agey_b r8agey_b r9agey_b r10agey_b r11agey_b r12agey_b r13agey_b r14agey_b r15agey_b ///
r5agey_e r6agey_e r7agey_e r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e r15agey_e ///
r5agey_m r6agey_m r7agey_m r8agey_m r9agey_m r10agey_m r11agey_m r12agey_m r13agey_m r14agey_m r15agey_m ///
r5armsa r6armsa r7armsa r8armsa r9armsa r10armsa r11armsa r12armsa r13armsa r14armsa r15armsa ///
r5arthre r6arthre r7arthre r8arthre r9arthre r10arthre r11arthre r12arthre r13arthre r14arthre r15arthre ///
r5back r6back r7back r8back r9back r10back r11back r12back r13back r14back r15back ///
r5backp r6backp r7backp r8backp r9backp r10backp r11backp r12backp r13backp r14backp r15backp ///
r5batha r6batha r7batha r8batha r9batha r10batha r11batha r12batha r13batha r14batha r15batha  ///
r5eata r6eata r7eata r8eata r9eata r10eata r11eata r12eata r13eata r14eata r15eata  ///
r5beda r6beda r7beda r8beda r9beda r10beda r11beda r12beda r13beda r14beda r15beda  ///
r5binged r6binged r7binged r8binged r9binged r10binged r11binged r12binged r13binged r14binged r15binged ///
r5bmi r6bmi r7bmi r8bmi r9bmi r10bmi r11bmi r12bmi r13bmi r14bmi r15bmi ///
r5bmicat r6bmicat r7bmicat r8bmicat r9bmicat r10bmicat r11bmicat r12bmicat r13bmicat r14bmicat r15bmicat ///
r5breath r6breath r7breath r8breath r9breath r10breath r11breath r12breath r13breath r14breath r15breath ///
r5bwc20 r6bwc20 r7bwc20 r8bwc20 r9bwc20 r10bwc20 r11bwc20 r12bwc20 r13bwc20 ///
r5cact r6cact r7cact r8cact r9cact r10cact r11cact r12cact r13cact ///
r5cancre r6cancre r7cancre r8cancre r9cancre r10cancre r11cancre r12cancre r13cancre r14cancre r15cancre ///
r5catrct r6catrct r7catrct r8catrct r9catrct r10catrct r11catrct r12catrct r13catrct r14catrct r15catrct ///
r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte r10catrcte r11catrcte r12catrcte r13catrcte r14catrcte r15catrcte ///
r5cenreg r6cenreg r7cenreg r8cenreg r9cenreg r10cenreg r11cenreg r12cenreg r13cenreg r14cenreg r15cenreg ///
r5cesd r6cesd r7cesd r8cesd r9cesd r10cesd r11cesd r12cesd r13cesd r14cesd r15cesd ///
r5chaira r6chaira r7chaira r8chaira r9chaira r10chaira r11chaira r12chaira r13chaira r14chaira r15chaira ///
r5cholst r6cholst r7cholst r8cholst r9cholst r10cholst r11cholst r12cholst r13cholst r14cholst r15cholst ///
r5cidianh r6cidianh r7cidianh r8cidianh r9cidianh r10cidianh r11cidianh r12cidianh r13cidianh r14cidianh r15cidianh ///
r5cididep r6cididep r7cididep r8cididep r9cididep r10cididep r11cididep r12cididep r13cididep r14cididep r15cididep ///
r5cidimde3 r6cidimde3 r7cidimde3 r8cidimde3 r9cidimde3 r10cidimde3 r11cidimde3 r12cidimde3 r13cidimde3 r14cidimde3 r15cidimde3 ///
r5cidimde5 r6cidimde5 r7cidimde5 r8cidimde5 r9cidimde5 r10cidimde5 r11cidimde5 r12cidimde5 r13cidimde5 r14cidimde5 r15cidimde5 /// ///
r5cidisymp r6cidisymp r7cidisymp r8cidisymp r9cidisymp r10cidisymp r11cidisymp r12cidisymp r13cidisymp r14cidisymp r15cidisymp ///
r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a r10clim1a r11clim1a r12clim1a r13clim1a r14clim1a r15clim1a ///
r5climsa r6climsa r7climsa r8climsa r9climsa r10climsa r11climsa r12climsa r13climsa r14climsa r15climsa ///
r5cncrchem r6cncrchem r7cncrchem r8cncrchem r9cncrchem r10cncrchem r11cncrchem r12cncrchem r13cncrchem r14cncrchem r15cncrchem  ///
r5cncrmeds r6cncrmeds r7cncrmeds r8cncrmeds r9cncrmeds r10cncrmeds r11cncrmeds r12cncrmeds r13cncrmeds r14cncrmeds r15cncrmeds ///
r5cncrothr r6cncrothr r7cncrothr r8cncrothr r9cncrothr r10cncrothr r11cncrothr r12cncrothr r13cncrothr r14cncrothr r15cncrothr  ///
r5cncrradn r6cncrradn r7cncrradn r8cncrradn r9cncrradn r10cncrradn r11cncrradn r12cncrradn r13cncrradn r14cncrradn r15cncrradn  ///
r5cncrsurg r6cncrsurg r7cncrsurg r8cncrsurg r9cncrsurg r10cncrsurg r11cncrsurg r12cncrsurg r13cncrsurg r14cncrsurg r15cncrsurg ///
r5covr r6covr r7covr r8covr r9covr r10covs r11covs r12covs r13covs r14covs r15covs ///
r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv r10dadliv r11dadliv r12dadliv r13dadliv r14dadliv r15dadliv ///
r5diabe r6diabe r7diabe r8diabe r9diabe r10diabe r11diabe r12diabe r13diabe r14diabe r15diabe ///
r5dimea r6dimea r7dimea r8dimea r9dimea r10dimea r11dimea r12dimea r13dimea r14dimea r15dimea ///
r5dizzy r6dizzy r7dizzy r8dizzy r9dizzy r10dizzy r11dizzy r12dizzy r13dizzy r14dizzy r15dizzy ///
r5dlrc r6dlrc r7dlrc r8dlrc r9dlrc r10dlrc r11dlrc r12dlrc r13dlrc  ///
r5doctim r6doctim r7doctim r8doctim r9doctim r10doctim r11doctim r12doctim r13doctim r14doctim r15doctim ///
r5doctor r6doctor r7doctor r8doctor r9doctor r10doctor r11doctor r12doctor r13doctor r14doctor r15doctor ///
r5dressa r6dressa r7dressa r8dressa r9dressa r10dressa r11dressa r12dressa r13dressa r14dressa r15dressa  ///
r5drink r6drink r7drink r8drink r9drink r10drink r11drink r12drink r13drink r14drink r15drink ///
r5drinkb r6drinkb r7drinkb r8drinkb r9drinkb r10drinkb r11drinkb r12drinkb r13drinkb r14drinkb r15drinkb ///
r5drinkd r6drinkd r7drinkd r8drinkd r9drinkd r10drinkd r11drinkd r12drinkd r13drinkd r14drinkd r15drinkd ///
r5dsight r6dsight r7dsight r8dsight r9dsight r10dsight r11dsight r12dsight r13dsight r14dsight r15dsight ///
r5dw r6dw r7dw r8dw r9dw r10dw r11dw r12dw r13dw ///
r5dy r6dy r7dy r8dy r9dy r10dy r11dy r12dy r13dy ///
r5fall r6fall r7fall r8fall r9fall r10fall r11fall r12fall r13fall r14fall r15fall ///
r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj r10fallinj r11fallinj r12fallinj r13fallinj r14fallinj r15fallinj ///
r5fallnum r6fallnum r7fallnum r8fallnum r9fallnum r10fallnum r11fallnum r12fallnum r13fallnum r14fallnum r15fallnum ///
r5fatigue r6fatigue r7fatigue r8fatigue r9fatigue r10fatigue r11fatigue r12fatigue r13fatigue r14fatigue r15fatigue ///
r5flusht r6flusht r7flusht r8flusht r9flusht r10flusht r11flusht r12flusht r13flusht r14flusht r15flusht ///
r5glaucoma r6glaucoma r7glaucoma r8glaucoma r9glaucoma r10glaucoma r11glaucoma r12glaucoma r13glaucoma r14glaucoma r15glaucoma ///
r5govmd r6govmd r7govmd r8govmd r9govmd r10govmd r11govmd r12govmd r13govmd r14govmd r15govmd ///
r5govva r6govva r7govva r8govva r9govva r10govva r11govva r12govva r13govva r14govva r15govva ///
r5headache r6headache r7headache r8headache r9headache r10headache r11headache r12headache r13headache r14headache r15headache ///
r5hearaid r6hearaid r7hearaid r8hearaid r9hearaid r10hearaid r11hearaid r12hearaid r13hearaid r14hearaid r15hearaid ///
r5hearing r6hearing r7hearing r8hearing r9hearing r10hearing r11hearing r12hearing r13hearing r14hearing r15hearing ///
r5hearte r6hearte r7hearte r8hearte r9hearte r10hearte r11hearte r12hearte r13hearte r14hearte r15hearte ///
r5height r6height r7height r8height r9height r10height r11height r12height r13height r14height r15height ///
r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe r10hibpe r11hibpe r12hibpe r13hibpe r14hibpe r15hibpe ///
r5higov r6higov r7higov r8higov r9higov r10govmr r11govmr r12govmr r13govmr r14govmr r15govmr ///
r5hiltc r6hiltc r7hiltc r8hiltc r9hiltc r10hiltc r11hiltc r12hiltc r13hiltc r14hiltc r15hiltc ///
r5hiothp r6hiothp r7hiothp r8hiothp r9hiothp r10hiothp r11hiothp r12hiothp r13hiothp r14hiothp r15hiothp ///
r5hipe r6hipe r7hipe r8hipe r9hipe r10hipe r11hipe r12hipe r13hipe r14hipe r15hipe ///
r5homcar r6homcar r7homcar r8homcar r9homcar r10homcar r11homcar r12homcar r13homcar r14homcar r15homcar ///
r5hosp r6hosp r7hosp r8hosp r9hosp r10hosp r11hosp r12hosp r13hosp r14hosp r15hosp ///
r5hrtsrg r6hrtsrg r7hrtsrg r8hrtsrg r9hrtsrg r10hrtsrg r11hrtsrg r12hrtsrg r13hrtsrg r14hrtsrg r15hrtsrg ///
r5hspnit r6hspnit r7hspnit r8hspnit r9hspnit r10hspnit r11hspnit r12hspnit r13hspnit r14hspnit r15hspnit ///
r5hsptim r6hsptim r7hsptim r8hsptim r9hsptim r10hsptim r11hsptim r12hsptim r13hsptim r14hsptim r15hsptim ///
r5iadl5a r6iadl5a r7iadl5a r8iadl5a r9iadl5a r10iadl5a r11iadl5a r12iadl5a r13iadl5a r14iadl5a ///
r5iearn r6iearn r7iearn r8iearn r9iearn r10iearn r11iearn r12iearn r13iearn r14iearn r15iearn ///
r5imrc r6imrc r7imrc r8imrc r9imrc r10imrc r11imrc r12imrc r13imrc  ///
r5iwendm r6iwendm r7iwendm r8iwendm r9iwendm r10iwendm r11iwendm r12iwendm r13iwendm r14iwendm r15iwendm ///
r5iwendy r6iwendy r7iwendy r8iwendy r9iwendy r10iwendy r11iwendy r12iwendy r13iwendy r14iwendy r15iwendy ///
r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat r10iwstat r11iwstat r12iwstat r13iwstat r14iwstat r15iwstat ///
r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen r10jcpen r11jcpen r12jcpen r13jcpen r14jcpen r15jcpen ///
r5joga r6joga r7joga r8joga r9joga r10joga r11joga r12joga r13joga r14joga r15joga ///
r5jointr r6jointr r7jointr r8jointr r9jointr r10jointr r11jointr r12jointr r13jointr r14jointr r15jointr ///
r5jsprvs r6jsprvs r7jsprvs r8jsprvs r9jsprvs r10jsprvs r11jsprvs r12jsprvs r13jsprvs r14jsprvs r15jsprvs ///
r5lifein r6lifein r7lifein r8lifein r9lifein r10lifein r11lifein r12lifein r13lifein r14lifein r15lifein ///
r5lifta r6lifta r7lifta r8lifta r9lifta r10lifta r11lifta r12lifta r13lifta r14lifta r15lifta ///
r5lunge r6lunge r7lunge r8lunge r9lunge r10lunge r11lunge r12lunge r13lunge r14lunge r15lunge ///
r5mammog r6mammog r7mammog r9mammog r10mammog r11mammog r12mammog r13mammog r14mammog r15mammog ///
r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa r10mealsa r11mealsa r12mealsa r13mealsa r14mealsa r15mealsa ///
r5mo r6mo r7mo r8mo r9mo r10mo r11mo r12mo r13mo ///
r5momliv r6momliv r7momliv r8momliv r9momliv r10momliv r11momliv r12momliv r13momliv r14momliv r15momliv ///
r5moneya r6moneya r7moneya r8moneya r9moneya r10moneya r11moneya r12moneya r13moneya r14moneya r15moneya ///
r5mstath r6mstath r7mstath r8mstath r9mstath r10mstath r11mstath r12mstath r13mstath r14mstath r15mstath ///
r5mstot r6mstot r7mstot r8mstot r9mstot r10mstot r11mstot r12mstot r13mstot  ///
r5nrshom r6nrshom r7nrshom r8nrshom r9nrshom r10nrshom r11nrshom r12nrshom r13nrshom r14nrshom r15nrshom ///
r5nrsnit r6nrsnit r7nrsnit r8nrsnit r9nrsnit r10nrsnit r11nrsnit r12nrsnit r13nrsnit r14nrsnit r15nrsnit ///
r5nrstim r6nrstim r7nrstim r8nrstim r9nrstim r10nrstim r11nrstim r12nrstim r13nrstim r14nrstim r15nrstim ///
r5nsight r6nsight r7nsight r8nsight r9nsight r10nsight r11nsight r12nsight r13nsight r14nsight r15nsight ///
r5obese r6obese r7obese r8obese r9obese r10obese r11obese r12obese r13obese r14obese r15obese ///
r5oopmd r6oopmd r7oopmd r8oopmd r9oopmd r10oopmd r11oopmd r12oopmd r13oopmd r14oopmd r15oopmd ///
r5orient r6orient r7orient r8orient r9orient r10orient r11orient r12orient r13orient ///
r5paina r6paina r7paina r8paina r9paina r10paina r11paina r12paina r13paina r14paina r15paina ///
r5painfr r6painfr r7painfr r8painfr r9painfr r10painfr r11painfr r12painfr r13painfr r14painfr r15painfr ///
r5painlv r6painlv r7painlv r8painlv r9painlv r10painlv r11painlv r12painlv r13painlv r14painlv r15painlv ///
r5papsm r6papsm r8papsm r9papsm r10papsm r11papsm r12papsm r13papsm r14papsm r15papsm ///
r5peninc r6peninc r7peninc r8peninc r9peninc r10peninc r11peninc r12peninc r13peninc r14peninc r15peninc ///
r5phonea r6phonea r7phonea r8phonea r9phonea r10phonea r11phonea r12phonea r13phonea r14phonea r15phonea ///
r5pres r6pres r7pres r8pres r9pres r10pres r11pres r12pres r13pres  ///
r5prost r6prost r7prost r8prost r9prost r10prost r11prost r12prost r13prost r14prost r15prost ///
r5prpcnt r6prpcnt r7prpcnt r8prpcnt r9prpcnt r10prpcnt r11prpcnt r12prpcnt r13prpcnt r14prpcnt r15prpcnt ///
r5psyche r6psyche r7psyche r8psyche r9psyche r10psyche r11psyche r12psyche r13psyche r14psyche r15psyche ///
r5pusha r6pusha r7pusha r8pusha r9pusha r10pusha r11pusha r12pusha r13pusha r14pusha r15pusha ///
r5quitsmok r6quitsmok r7quitsmok r8quitsmok r9quitsmok r10quitsmok r11quitsmok r12quitsmok r13quitsmok r14quitsmok r15quitsmok ///
r5reccancr r6reccancr r7reccancr r8reccancr r9reccancr r10reccancr r11reccancr r12reccancr r13reccancr r14reccancr r15reccancr ///
r5rechrtatt r6rechrtatt r7rechrtatt r8rechrtatt r9rechrtatt r10rechrtatt r11rechrtatt r12rechrtatt r13rechrtatt r14rechrtatt r15rechrtatt ///
r5recstrok r6recstrok r7recstrok r8recstrok r9recstrok r10recstrok r11recstrok r12recstrok r13recstrok r14recstrok r15recstrok ///
r5relgwk r7relgwk r8relgwk r9relgwk r10relgwk r11relgwk r12relgwk r13relgwk r14relgwk r15relgwk ///
r5retemp r6retemp r7retemp r8retemp r9retemp r10retemp r11retemp r12retemp r13retemp r14retemp r15retemp ///
r5retmon r6retmon r7retmon r8retmon r9retmon r10retmon r11retmon r12retmon r13retmon r14retmon r15retmon ///
r5retyr r6retyr r7retyr r8retyr r9retyr r10retyr r11retyr r12retyr r13retyr r14retyr r15retyr ///
r5rxangina r6rxangina r7rxangina r8rxangina r9rxangina r10rxangina r11rxangina r12rxangina r13rxangina r14rxangina r15rxangina  ///
r5rxarthr r6rxarthr r7rxarthr r8rxarthr r9rxarthr r10rxarthr r11rxarthr ///
r5rxchf r6rxchf r7rxchf r8rxchf r9rxchf r10rxchf r11rxchf r12rxchf r13rxchf r14rxchf r15rxchf  ///
r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiab r11rxdiab r12rxdiab r13rxdiab r14rxdiab r15rxdiab r10rxstrok  ///
r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi r10rxdiabi r11rxdiabi r12rxdiabi r13rxdiabi r14rxdiabi r15rxdiabi  ///
r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo r10rxdiabo r11rxdiabo r12rxdiabo r13rxdiabo r14rxdiabo r15rxdiabo ///
r5rxheart r6rxheart r7rxheart r8rxheart r9rxheart r10rxheart r11rxheart r12rxheart r13rxheart r14rxheart r15rxheart  ///
r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp r10rxhibp r11rxhibp r12rxhibp r13rxhibp r14rxhibp r15rxhibp ///
r5rxhrtat r6rxhrtat r7rxhrtat r8rxhrtat r9rxhrtat r10rxhrtat r11rxhrtat r12rxhrtat r13rxhrtat r14rxhrtat r15rxhrtat  ///
r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung r10rxlung r11rxlung r12rxlung r13rxlung r14rxlung r15rxlung  ///
r5rxpsych r6rxpsych r7rxpsych r8rxpsych r9rxpsych r10rxpsych r11rxpsych  ///
r5rxstrok r6rxstrok r7rxstrok r8rxstrok r9rxstrok r10rxstrok r11rxstrok r12rxstrok r13rxstrok r14rxstrok r15rxstrok r10rxangina  ///
r5sayret r6sayret r7sayret r8sayret r9sayret r10sayret r11sayret r12sayret r13sayret r14sayret r15sayret ///
r5scis r6scis r7scis r8scis r9scis r10scis r11scis r12scis r13scis ///
r5ser7 r6ser7 r7ser7 r8ser7 r9ser7 r10ser7 r11ser7 r12ser7 r13ser7 ///
r5shlt r6shlt r7shlt r8shlt r9shlt r10shlt r11shlt r12shlt r13shlt r14shlt r15shlt ///
r5shopa r6shopa r7shopa r8shopa r9shopa r10shopa r11shopa r12shopa r13shopa r14shopa r15shopa /// ///
r5sight r6sight r7sight r8sight r9sight r10sight r11sight r12sight r13sight r14sight r15sight ///
r5sita r6sita r7sita r8sita r9sita r10sita r11sita r12sita r13sita r14sita r15sita ///
r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp r10slfemp r11slfemp r12slfemp r13slfemp r14slfemp r15slfemp ///
r5slfmem r6slfmem r7slfmem r8slfmem r9slfmem r10slfmem r11slfmem r12slfmem r13slfmem r14slfmem r15slfmem ///
r5smokef r6smokef r7smokef r8smokef r9smokef r10smokef r11smokef r12smokef r13smokef r14smokef r15smokef ///
r5smokev r6smokev r7smokev r8smokev r9smokev r10smokev r11smokev r12smokev r13smokev r14smokev r15smokev ///
r5socrelg_h r7socrelg_h r8socrelg_h r9socrelg_h r10socrelg_h r11socrelg_h r12socrelg_h r13socrelg_h r14socrelg_h r15socrelg_h ///
r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa r10stoopa r11stoopa r12stoopa r13stoopa r14stoopa r15stoopa ///
r5stroke r6stroke r7stroke r8stroke r9stroke r10stroke r11stroke r12stroke r13stroke r14stroke r15stroke ///
r5strtsmok r6strtsmok r7strtsmok r8strtsmok r9strtsmok r10strtsmok r11strtsmok r12strtsmok r13strtsmok r14strtsmok r15strtsmok ///
r5swell r6swell r7swell r8swell r9swell r10swell r11swell r12swell r13swell r14swell r15swell ///
r5toilta r6toilta r7toilta r8toilta r9toilta r10toilta r11toilta r12toilta r13toilta r14toilta r15toilta ///
r5tr20 r6tr20 r7tr20 r8tr20 r9tr20 r10tr20 r11tr20 r12tr20 r13tr20 ///
r5trpsych r6trpsych r7trpsych r8trpsych r9trpsych r10trpsych r11trpsych r12trpsych r13trpsych r14trpsych r15trpsych  ///
r5unemp r6unemp r7unemp r8unemp r9unemp r10unemp r11unemp r12unemp r13unemp r14unemp r15unemp ///
r5urbrur r6urbrur r7urbrur r8urbrur r9urbrur r10urbrur r11urbrur r12urbrur r13urbrur r14urbrur r15urbrur ///
r5urinaf r6urinaf r7urinaf r8urinaf r9urinaf r10urinaf r11urinaf r12urinaf r13urinaf r14urinaf r15urinaf ///
r5urinai r6urinai r7urinai r8urinai r9urinai r10urinai r11urinai r12urinai r13urinai r14urinai r15urinai ///
r5vocab r6vocab r7vocab r8vocab r9vocab r10vocab r11vocab r12vocab r13vocab  ///
r5vp r6vp r7vp r8vp r9vp r10vp r11vp r12vp r13vp  ///
r5walk1a r6walk1a r7walk1a r8walk1a r9walk1a r10walk1a r11walk1a r12walk1a r13walk1a r14walk1a r15walk1a ///
r5walkra r6walkra r7walkra r8walkra r9walkra r10walkra r11walkra r12walkra r13walkra r14walkra r15walkra ///
r5walksa r6walksa r7walksa r8walksa r9walksa r10walksa r11walksa r12walksa r13walksa r14walksa r15walksa ///
r5weight r6weight r7weight r8weight r9weight r10weight r11weight r12weight r13weight r14weight r15weight ///
r5wheeze r6wheeze r7wheeze r8wheeze r9wheeze r10wheeze r11wheeze r12wheeze r13wheeze r14wheeze r15wheeze ///
r5work r6work r7work r8work r9work r10work r11work r12work r13work r14work r15work ///
r5yr r6yr r7yr r8yr r9yr r10yr r11yr r12yr r13yr ///
r6email r7email r8email r9email r10email r11email r12email r13email r14email r15email ///
r6fallslp r7fallslp r8fallslp r9fallslp r10fallslp r11fallslp r12fallslp r13fallslp r14fallslp r15fallslp ///
r6numer r7numer r8numer r9numer r10numer r11numer r12numer r13numer r14numer r15numer ///
r6rested r7rested r8rested r9rested r10rested r11rested r12rested r13rested r14rested r15rested ///
r6wakent r7wakent r8wakent r9wakent r10wakent r11wakent r12wakent r13wakent r14wakent r15wakent ///
r6wakeup r7wakeup r8wakeup r9wakeup r10wakeup r11wakeup r12wakeup r13wakeup r14wakeup r15wakeup ///
r7cantril r8cantril r9cantril r10cantril r11cantril r12cantril r13cantril r14cantril r15cantril ///
r7gripcomp r8gripcomp r9gripcomp r10gripcomp r11gripcomp r12gripcomp r13gripcomp r14gripcomp ///
r7htcomp r8htcomp r9htcomp r10htcomp r11htcomp r12htcomp r13htcomp r14htcomp ///
r7lgrip r8lgrip r9lgrip r10lgrip r11lgrip r12lgrip r13lgrip r14lgrip ///
r7lgrip1 r8lgrip1 r9lgrip1 r10lgrip1 r11lgrip1 r12lgrip1 r13lgrip1 r14lgrip1 ///
r7lgrip2 r8lgrip2 r9lgrip2 r10lgrip2 r11lgrip2 r12lgrip2 r13lgrip2 r14lgrip2 ///
r7ltactx r8ltactx r9ltactx r10ltactx r11ltactx r12ltactx r13ltactx r14ltactx r15ltactx ///
r7mbmi r8mbmi r9mbmi r10mbmi r11mbmi r12mbmi r13mbmi r14mbmi ///
r7mbmicat r8mbmicat r9mbmicat r10mbmi r10mbmicat r11mbmicat r12mbmicat r13mbmicat r14mbmicat ///
r7mdactx r8mdactx r9mdactx r10mdactx r11mdactx r12mdactx r13mdactx r14mdactx r15mdactx ///
r7mheight r8mheight r9mheight r10mheight r11mheight r12mheight r13mheight r14mheight ///
r7mobese r8mobese r9mobese r10mobese r11mobese r12mobese r13mobese r14mobese ///
r7mweight r8mweight r9mweight r10mweight r11mweight r12mweight r13mweight r14mweight /// ///
r7puff r8puff r9puff r10puff r11puff r12puff r13puff r14puff ///
r7puff1 r8puff1 r9puff1 r10puff1 r11puff1 r12puff1 r13puff1 r14puff1 /// 
r7puff2 r8puff2 r9puff2 r10puff2 r11puff2 r12puff2 r13puff2 r14puff2 ///
r7puff3 r8puff3 r9puff3 r10puff3 r11puff3 r12puff3 r13puff3 r14puff3 ///
r7puffcomp r8puffcomp r9puffcomp r10puffcomp r11puffcomp r12puffcomp r13puffcomp r14puffcomp ///
r7rgrip r8rgrip r9rgrip r10rgrip r11rgrip r12rgrip r13rgrip r14rgrip ///
r7rgrip1 r8rgrip1 r9rgrip1 r10rgrip1 r11rgrip1 r12rgrip1 r13rgrip1 r14rgrip1 ///
r7rgrip2 r8rgrip2 r9rgrip2 r10rgrip2 r11rgrip2 r12rgrip2 r13rgrip2 r14rgrip2 ///
r7vgactx r8vgactx r9vgactx r10vgactx r11vgactx r12vgactx r13vgactx r14vgactx r15vgactx ///
r7walkcomp r8walkcomp r9walkcomp r10walkcomp r11walkcomp r12walkcomp r13walkcomp r14walkcomp ///
r7wspeed r8wspeed r9wspeed r10wspeed r11wspeed r12wspeed r13wspeed r14wspeed ///
r7wspeed1 r8wspeed1 r9wspeed1 r10wspeed1 r11wspeed1 r12wspeed1 r13wspeed1 r14wspeed1 ///
r7wspeed2 r8wspeed2 r9wspeed2 r10wspeed2 r11wspeed2 r12wspeed2 r13wspeed2 r14wspeed2 ///
r7wtcomp r8wtcomp r9wtcomp r10wtcomp r11wtcomp r12wtcomp r13wtcomp r14wtcomp ///
r8bpcomp r9bpcomp r10bpcomp r11bpcomp r12bpcomp r13bpcomp r14bpcomp ///
r8bpdia r9bpdia r10bpdia r11bpdia r12bpdia r13bpdia r14bpdia ///
r8bppuls r9bppuls r10bppuls r11bppuls r12bppuls r13bppuls r14bppuls ///
r8bpsys r9bpsys r10bpsys r11bpsys r12bpsys r13bpsys r14bpsys ///
r8diasto r9diasto r10diasto r11diasto r12diasto r13diasto r14diasto ///
r8diasto1 r9diasto1 r10diasto1 r11diasto1 r12diasto1 r13diasto1 r14diasto1 ///
r8diasto2 r9diasto2 r10diasto2 r11diasto2 r12diasto2 r13diasto2 r14diasto2 ///
r8diasto3 r9diasto3 r10diasto3 r11diasto3 r12diasto3 r13diasto3 r14diasto3 ///
r8fullcomp r9fullcomp r10fullcomp r11fullcomp r12fullcomp r13fullcomp r14fullcomp ///
r8fulldone r9fulldone r10fulldone r11fulldone r12fulldone r13fulldone r14fulldone ///
r8fulltan r9fulltan r10fulltan r11fulltan r12fulltan r13fulltan r14fulltan ///
r8grp r9grp r10grp r11grp r12grp r13grp r14grp ///
r8grpl r9grpl r10grpl r11grpl r12grpl r13grpl r14grpl ///
r8grpr r9grpr r10grpr r11grpr r12grpr r13grpr r14grpr ///
r8jgovtemp r9jgovtemp r10jgovtemp r11jgovtemp r12jgovtemp r13jgovtemp r14jgovtemp r15jgovtemp ///
r8lbsatwlf r9lbsatwlf r10lbsatwlf r11lbsatwlf r12lbsatwlf r13lbsatwlf r14lbsatwlf r15lbsatwlf ///
r8mwaist r9mwaist r10mwaist r11mwaist r12mwaist r13mwaist r14mwaist ///
r8noteeth r9noteeth r10noteeth r11noteeth r12noteeth r13noteeth r14noteeth r15noteeth ///
r8pmbmi r9pmbmi r10pmbmi r11pmbmi r12pmbmi r13pmbmi r14pmbmi ///
r8pmhght r9pmhght r10pmhght r11pmhght r12pmhght r13pmhght r14pmhght ///
r8pmwaist r9pmwaist r10pmwaist r11pmwaist r12pmwaist r13pmwaist r14pmwaist ///
r8pmwght r9pmwght r10pmwght r11pmwght r12pmwght r13pmwght r14pmwght ///
r8pulse r9pulse r10pulse r11pulse r12pulse r13pulse r14pulse ///
r8pulse1 r9pulse1 r10pulse1 r11pulse1 r12pulse1 r13pulse1 r14pulse1 ///
r8pulse2 r9pulse2 r10pulse2 r11pulse2 r12pulse2 r13pulse2 r14pulse2 ///
r8pulse3 r9pulse3 r10pulse3 r11pulse3 r12pulse3 r13pulse3 r14pulse3 ///
r8rxbreath r9rxbreath r10rxbreath r11rxbreath r12rxbreath r13rxbreath r14rxbreath r15rxbreath ///
r8rxdepres r9rxdepres r10rxdepres r11rxdepres r12rxdepres r13rxdepres r14rxdepres r15rxdepres ///
r8rxhchol r9rxhchol r10rxhchol r11rxhchol r12rxhchol r13rxhchol r14rxhchol r15rxhchol ///
r8rxslp r9rxslp r10rxslp r11rxslp r12rxslp r13rxslp r14rxslp r15rxslp ///
r8rxstom r9rxstom r10rxstom r11rxstom r12rxstom r13rxstom r14rxstom r15rxstom ///
r8sbscomp r9sbscomp r10sbscomp r11sbscomp r12sbscomp r13sbscomp r14sbscomp ///
r8sbsdone r9sbsdone r10sbsdone r11sbsdone r12sbsdone r13sbsdone r14sbsdone ///
r8sbstan r9sbstan r10sbstan r11sbstan r12sbstan r13sbstan r14sbstan ///
r8semicomp r9semicomp r10semicomp r11semicomp r12semicomp r13semicomp r14semicomp ///
r8semidone r9semidone r10semidone r11semidone r12semidone r13semidone r14semidone ///
r8semitan r9semitan r10semitan r11semitan r12semitan r13semitan r14semitan ///
r8systo r9systo r10systo r11systo r12systo r13systo r14systo ///
r8systo1 r9systo1 r10systo1 r11systo1 r12systo1 r13systo1 r14systo1 ///
r8systo2 r9systo2 r10systo2 r11systo2 r12systo2 r13systo2 r14systo2 ///
r8systo3 r9systo3 r10systo3 r11systo3 r12systo3 r13systo3 r14systo3 ///
r8timwlk r9timwlk r10timwlk r11timwlk r12timwlk r13timwlk r14timwlk ///
r8watcomp r9watcomp r10watcomp r11watcomp r12watcomp r13watcomp r14watcomp ///
r9hystere r10hystere r11hystere r12hystere r13hystere r14hystere r15hystere ///
r9lstmnspd r10lstmnspd r11lstmnspd r12lstmnspd r13lstmnspd r14lstmnspd r15lstmnspd ///
r9rxmemry r10rxmemry r11rxmemry r12rxmemry r13rxmemry r14rxmemry r15rxmemry ///
r9satlife_h r10satlife_h r11satlife_h r12satlife_h r13satlife_h r14satlife_h r15satlife_h ///
r9satlifez r10satlifez r11satlifez r12satlifez r13satlifez r14satlifez r15satlifez ///
r9shingle r10shingle r11shingle r12shingle r13shingle r14shingle r15shingle ///
r9shnglshte r10shnglshte r11shnglshte r12shnglshte r13shnglshte r14shnglshte ///
r9socmn r10socmn r11socmn r12socmn r13socmn r14socmn r15socmn ///
r9socwk r10socwk r11socwk r12socwk r13socwk r14socwk r15socwk ///
rabmonth ///
rabyear ///
racohbyr ///
radadeducl ///
radadoccup ///
radiagangin ///
radiagchf ///
radiagdiab ///
radiaghrtr ///
radmonth ///
radyear ///
raeducl ///
raedyrs ///
rafrhrtatt ///
ragender ///
rahispan ///
ramomeducl ///
raracem ///
rarelig ///
r7lstsf r8lstsf r9lstsf r10lstsf r11lstsf r12lstsf r13lstsf r14lstsf r15lstsf  ///
r9dtrmnd r10dtrmnd r11dtrmnd r12dtrmnd r13dtrmnd r14dtrmnd r15dtrmnd /// 
r9enthstc r10enthstc r11enthstc r12enthstc r13enthstc r14enthstc r15enthstc /// 
r9active r10active r11active r12active r13active r14active r15active  ///
r9proud r10proud r11proud r12proud r13proud r14proud r15proud  ///
r9intrstd r10intrstd r11intrstd r12intrstd r13intrstd r14intrstd r15intrstd  ///
r9fhappy r10fhappy r11fhappy r12fhappy r13fhappy r14fhappy r15fhappy  ///
r9attntv r10attntv r11attntv r12attntv r13attntv r14attntv r15attntv  ///
r9content r10content r11content r12content r13content r14content r15content  ///
r9insprd r10insprd r11insprd r12insprd r13insprd r14insprd r15insprd  ///
r9hopeful r10hopeful r11hopeful r12hopeful r13hopeful r14hopeful r15hopeful /// 
r9alert r10alert r11alert r12alert r13alert r14alert r15alert  ///
r9calm r10calm r11calm r12calm r13calm r14calm r15calm  ///
r9exctd r10exctd r11exctd r12exctd r13exctd r14exctd r15exctd ///
r9panasp13 r10panasp13 r11panasp13 r12panasp13 r13panasp13 r14panasp13 r15panasp13  ///
r9afraid r10afraid r11afraid r12afraid r13afraid r14afraid r15afraid  ///
r9fupset r10fupset r11fupset r12fupset r13fupset r14fupset r15fupset  ///
r9guilty r10guilty r11guilty r12guilty r13guilty r14guilty r15guilty  ///
r9scared r10scared r11scared r12scared r13scared r14scared r15scared  ///
r9frustrat r10frustrat r11frustrat r12frustrat r13frustrat r14frustrat r15frustrat ///
r9bored r10bored r11bored r12bored r13bored r14bored r15bored  ///
r9hostile r10hostile r11hostile r12hostile r13hostile r14hostile r15hostile  ///
r9jittery r10jittery r11jittery r12jittery r13jittery r14jittery r15jittery ///
r9ashamd r10ashamd r11ashamd r12ashamd r13ashamd r14ashamd r15ashamd  ///
r9nrvous r10nrvous r11nrvous r12nrvous r13nrvous r14nrvous r15nrvous  ///
r9pfsad r10pfsad r11pfsad r12pfsad r13pfsad r14pfsad r15pfsad  ///
r9dstres r10dstres r11dstres r12dstres r13dstres r14dstres r15dstres  ///
r9panasn12 r10panasn12 r11panasn12 r12panasn12 r13panasn12 r14panasn12 r15panasn12  ///
r5cog27 r6cog27 r7cog27 r8cog27 r9cog27 r10cog27 r11cog27 r12cog27 r13cog27 r14cog27 r15cog27 ///
r5dementia r6dementia r7dementia r8dementia r9dementia r10dementia r11dementia ///
r12dementia r13dementia r14dementia r15dementia ///
r5depressive r6depressive r7depressive r8depressive r9depressive r10depressive /// 
r11depressive r12depressive r13depressive r14depressive r15depressive ///
r5memrye r6memrye r7memrye r8memrye r9memrye ///
r5wthh r6wthh r7wthh r8wthh r9wthh r10wthh r11wthh r12wthh r13wthh r14wthh r15wthh  ///
r5wtresp r6wtresp r7wtresp r8wtresp r9wtresp r10wtresp r11wtresp r12wtresp r13wtresp r14wtresp r15wtresp  ///
r5wtr_nh r6wtr_nh r7wtr_nh r8wtr_nh r9wtr_nh r10wtr_nh r11wtr_nh r12wtr_nh r13wtr_nh r14wtr_nh r15wtr_nh  ///
r5wtcrnh r6wtcrnh r7wtcrnh r8wtcrnh r9wtcrnh r10wtcrnh r11wtcrnh r12wtcrnh r13wtcrnh r14wtcrnh r15wtcrnh ///
race ///
r5proxy r6proxy r7proxy r8proxy r9proxy r10proxy r11proxy r12proxy r13proxy r14proxy r15proxy ///
radtimtdth ///
r8balsemi r9balsemi r10balsemi r11balsemi r12balsemi r13balsemi r14balsemi ///
r8balsemic r9balsemic r10balsemic r11balsemic r12balsemic r13balsemic r14balsemic ///
r8balsbs r9balsbs r10balsbs r11balsbs r12balsbs r13balsbs r14balsbs ///
r8balsbsc r9balsbsc r10balsbsc r11balsbsc r12balsbsc r13balsbsc r14balsbsc ///
r8balful r9balful r10balful r11balful r12balful r13balful r14balful ///
r8balfulc r9balfulc r10balfulc r11balfulc r12balfulc r13balfulc r14balfulc ///
r8balfult r9balfult r10balfult r11balfult r12balfult r13balfult r14balfult ///
r8lbwgtr r9lbwgtr r10lbwgtr r11lbwgtr r12lbwgtr r13lbwgtr r14lbwgtr r15lbwgtr ///
r8lbelig r9lbelig r10lbelig r11lbelig r12lbelig r13lbelig r14lbelig r15lbelig ///
r8lbcomp r9lbcomp r10lbcomp r11lbcomp r12lbcomp r13lbcomp r14lbcomp r15lbcomp ///
r8lbneur r9lbneur r10lbneur r11lbneur r12lbneur r13lbneur r14lbneur r15lbneur ///
r8lbext r9lbext r10lbext r11lbext r12lbext r13lbext r14lbext r15lbext ///
r8lbopen r9lbopen r10lbopen r11lbopen r12lbopen r13lbopen r14lbopen r15lbopen ///
r8lbagr r9lbagr r10lbagr r11lbagr r12lbagr r13lbagr r14lbagr r15lbagr ///
r8lbcon5 r9lbcon5 r10lbcon5 r11lbcon5 r12lbcon5 r13lbcon5 r14lbcon5 r15lbcon5 ///
r10lbcon10 r11lbcon10 r12lbcon10 r13lbcon10 r14lbcon10 r15lbcon10 ///
r8lblonely3 r9lblonely3 r10lblonely3 r11lblonely3 r12lblonely3 r13lblonely3 r14lblonely3 r15lblonely3 ///
r9lblonely11 r10lblonely11 r11lblonely11 r12lblonely11 r13lblonely11 r14lblonely11 r15lblonely11 ///
r5frailty r6frailty r7frailty r8frailty r9frailty r10frailty r11frailty  ///
r12frailty r13frailty r14frailty r15frailty ///
r5memory_z r6memory_z r7memory_z r8memory_z r9memory_z r10memory_z r11memory_z  ///
r12memory_z r13memory_z r14memory_z r15memory_z r5orient_z r6orient_z r7orient_z ///
r8orient_z r9orient_z r10orient_z r11orient_z r12orient_z r13orient_z ///
r5executive_z r6executive_z r7executive_z r8executive_z r9executive_z ///
r10executive_z r11executive_z r12executive_z r13executive_z r14executive_z  r15executive_z  /// 
r5tcog_z_z r6tcog_z_z r7tcog_z_z r8tcog_z_z r9tcog_z_z r10tcog_z_z  ///
r11tcog_z_z r12tcog_z_z r13tcog_z_z ///
r7pa r8pa r9pa r10pa r11pa r12pa r13pa r14pa r15pa r7met r8met r9met r10met  ///
r11met r12met r13met r14met r15met r5dependency r6dependency r7dependency  ///
r8dependency r9dependency r10dependency r11dependency r12dependency r13dependency  ///
r14dependency r15dependency ///
r8cntc r9cntc r10cntc r11cntc r12cntc r13cntc r14cntc r15cntc ///
r8cntr r9cntr r10cntr r11cntr r12cntr r13cntr r14cntr r15cntr ///
r8cntf r9cntf r10cntf r11cntf r12cntf r13cntf r14cntf r15cntf ///
r9hobby r10hobby r11hobby r12hobby r13hobby r14hobby r15hobby  ///
r9care_adult r10care_adult r11care_adult  r12care_adult r13care_adult r14care_adult r15care_adult  ///
r10with_grand r11with_grand r12with_grand r13with_grand r14with_grand r15with_grand  ///
r9volunteer r10volunteer r11volunteer r12volunteer r13volunteer r14volunteer r15volunteer  ///
r9charity r10charity  r11charity r12charity r13charity r14charity r15charity ///
r9education r10education r11education r12education r13education r14education r15education ///
r9club r10club r11club r12club r13club r14club r15club ///
r9nonreligious r10nonreligious r11nonreligious r12nonreligious r13nonreligious r14nonreligious r15nonreligious ///
r9pray r10pray r11pray r12pray r13pray r14pray r15pray  ///
r9read r10read  r11read r12read r13read r14read r15read ///
r10watch_tel r11watch_tel r12watch_tel r13watch_tel r14watch_tel r15watch_tel  ///
r9word_game r10word_game r11word_game r12word_game r13word_game r14word_game r15word_game  ///
r9play_card r10play_card r11play_card r12play_card r13play_card r14play_card r15play_card  ///
r9writing r10writing r11writing r12writing r13writing r14writing r15writing  ///
r9use_computer r10use_computer r11use_computer r12use_computer r13use_computer r14use_computer r15use_computer ///
r9gardening r10gardening r11gardening r12gardening r13gardening r14gardening r15gardening  ///
r9bake r10bake r11bake r12bake r13bake r14bake r15bake ///
r9sew r10sew r11sew r12sew r13sew r14sew r15sew  ///
r9do_hobby r10do_hobby r11do_hobby r12do_hobby r13do_hobby r14do_hobby r15do_hobby ///
r9exercize r10exercize r11exercize r12exercize r13exercize r14exercize r15exercize ///
r9walk r10walk r11walk  r12walk r13walk r14walk r15walk  ///
r13art r14art r15art  ///
r8vol r9vol r10vol r11vol r12vol r13vol r14vol r15vol ///
r8hour_vol r9hour_vol r10hour_vol r11hour_vol r12hour_vol r13hour_vol r14hour_vol r15hour_vol ///
r8away_child r9away_child r10away_child r11away_child r12away_child r13away_child r14away_child r15away_child

*****宽数据转长数据
reshape long h@hhid inw@ r@iwstat r@iwendm r@iwendy r@agey_b r@agey_e r@agey_m  r@cenreg r@urbrur ///
r@mstath r@momliv r@dadliv r@shlt r@hosp r@hsptim r@hspnit r@nrshom  ///
r@nrstim r@nrsnit r@doctor r@doctim r@homcar r@cesd r@hibpe r@diabe r@cancre r@lunge r@hearte  ///
r@stroke r@psyche r@arthre r@sleepe r@alzhe r@alzhee r@demen r@demene r@bmi r@height  ///
r@weight r@back r@vgactx r@mdactx r@ltactx r@drink r@drinkd r@cholst r@flusht r@mammog  ///
r@papsm r@prost r@smokev r@smoken r@slfmem r@imrc r@imrcp r@imrcw r@dlrc r@dlrcp r@dlrcw  ///
r@ser7 r@ser7p r@ser7w r@bwc20 r@bwc20p r@bwc20w r@mo r@mop r@dy r@dyp r@yr r@yrp r@dw ///
r@dwp r@scis r@scisp r@cact r@cactp r@pres r@presp r@vp r@vpp r@vocab r@vocabp r@tr20 /// ///
r@tr20p r@tr20w r@mstot r@mstotp r@cogtot r@cogtotp r@bpsys r@bpdia r@bppuls r@grp  ///
r@grpl r@grpr r@timwlk r@pmbmi r@pmhght r@pmwght r@pmwaist r@walkra r@dressa r@batha r@eata  ///
r@beda r@toilta r@adl6a r@phonea r@medsa r@moneya r@shopa r@mealsa r@iadl5a r@walksa r@joga  ///
r@walk1a r@sita r@chaira r@climsa r@clim1a r@stoopa r@lifta r@dimea r@armsa r@pusha h@atotb  ///
h@atotw h@atotn r@iearn h@itot r@peninc r@jcpen r@higov r@govmr r@govmd r@govva r@prpcnt  ///
r@covr r@covs r@hiothp r@hiltc r@lifein h@hhres r@sayret r@retmon r@retyr r@work r@slfemp  ///
r@retemp r@unemp r@lbsatwlf h@rural r@email r@sight r@dsight r@nsight r@catrct  ///
r@catrcte r@glaucoma r@hearing r@hearaid r@fall r@fallinj r@fallnum r@hipe r@urinai r@urinaf  ///
r@noteeth r@fallslp r@wakent r@rested r@rxslp r@painfr r@painlv r@paina r@rxpain  ///
r@hystere r@lstmnspd r@swell r@breath r@dizzy r@backp r@headache r@fatigue r@wheeze r@hrtatte /// 
r@angine r@conhrtfe r@shingle r@hrtrhme r@osteoe r@hchole r@hrtatt r@angin r@conhrtf r@hrtrhm ///
r@rxhibp r@rxdiabo r@rxdiabi r@rxdiab r@rxstrok r@rxangina r@rxchf r@rxarthr r@rxlung r@rxpsych  ///
r@trpsych r@cncrchem r@cncrsurg r@cncrradn r@cncrothr r@cncrmeds r@rxhrtat r@rxheart r@rxmemry  ///
r@reccancr r@rechrtatt r@recstrok r@hrtsrg r@jointr r@rxhchol r@rxbreath r@rxstom r@rxdepres ///
r@rxbldthn r@bmicat r@obese r@drinkb r@binged r@smokef r@strtsmok r@quitsmok r@shnglshte ///
r@pneushte r@orient r@numer r@verbf h@lvwith r@relgwk r@socrelg_h r@socwk r@socmn  ///
r@jgovtemp r@jsprvs r@systo1 r@systo2 r@systo3 r@systo r@diasto1 r@diasto2 r@diasto3 r@diasto  ///
r@pulse1 r@pulse2 r@pulse3 r@pulse r@bpcomp r@puff1 r@puff2 r@puff3 r@puff r@puffcomp r@lgrip1  ///
r@lgrip2 r@rgrip1 r@rgrip2 r@lgrip r@rgrip r@gripcomp r@semitan r@semidone r@semicomp r@fulltan  ///
r@fulldone r@fullcomp r@sbstan r@sbsdone r@sbscomp r@wspeed1 r@wspeed2 r@wspeed r@walkcomp r@mheight  ///
r@mweight r@mwaist r@mbmi r@mbmicat r@mobese r@htcomp r@wtcomp r@watcomp r@hear_l1 r@hear_r1  ///
r@hear_l2 r@hear_r2 r@hear_l r@hear_r r@hearcomp r@hear_aid r@hear_p r@cididep r@cidianh r@cidisymp ///
r@cidimde3 r@cidimde5 r@satlife_h r@satlifez r@cantril r@wakeup r@oopmd r@lstsf r@dtrmnd ///
r@enthstc r@active r@proud r@intrstd r@fhappy r@attntv r@content r@insprd r@hopeful ///
r@alert r@calm r@exctd r@panasp13 r@afraid r@fupset r@guilty r@scared r@frustrat r@bored /// 
r@hostile r@jittery r@ashamd r@nrvous r@pfsad r@dstres r@panasn12 r@cog27 r@dementia r@depressive ///
r@memrye r@wthh r@wtresp r@wtr_nh r@wtcrnh r@proxy r@balsemi  /// 
r@balsemic r@balsbs r@balsbsc r@balful r@balfulc r@balfult r@lbwgtr r@lbelig r@lbcomp  ///
r@lbneur r@lbext r@lbopen r@lbagr r@lbcon5 r@lbcon10 r@lblonely3 r@lblonely11  ///
r@frailty r@memory_z r@orient_z r@executive_z r@tcog_z_z r@pa r@met r@dependency ///
r@cntc r@cntr r@cntf r@hobby r@care_adult r@with_grand ///
r@volunteer r@charity r@education r@club r@nonreligious r@pray r@read ///
r@watch_tel r@word_game r@play_card r@writing r@use_computer r@gardening ///
r@bake r@sew r@do_hobby r@exercize r@walk r@vol r@hour_vol r@away_child r@art,i(hhidpn) j(wave)

rename (hhidpn wave inw rmstath rcenreg hacohort hhhid ragender rahispan raracem ///
rabmonth rabyear riwstat radmonth radyear raedyrs rurbrur rarelig ragey_b ragey_e ragey_m   ///
racohbyr riwendm riwendy rshlt rcesd rvgactx rmdactx rltactx rflusht rcholst  ///
rmammog rpapsm rprost rbmi rheight rweight rback rsmokev rsmoken rdrink ///
rdrinkd rsleepe rhibpe rcancre rlunge rhearte rstroke rpsyche rarthre ralzhe ///
ralzhee rdemen rdemene rimrcp rimrcw rdlrcp rdlrcw rtr20p rtr20w rser7p rser7w  ///
rbwc20p rbwc20w rmop rdyp ryrp rdwp rscisp rcactp rpresp rvpp rmstotp rcogtotp  ///
rslfmem rhosp rnrshom rdoctor rhomcar rhsptim rnrstim rhspnit rdoctim  ///
rnrsnit hatotn hatotb hatotw riearn hitot rcovr rcovs rhigov rgovmr rgovmd rgovva ///
rhiothp rhiltc rprpcnt rlifein rsayret rretmon rretyr rretemp rwork rslfemp runemp ///
hhhres rdadliv rmomliv rpeninc rjcpen rwalksa rjoga rwalk1a rwalkra rsita rchaira /// 
rclimsa rclim1a rstoopa rlifta rdimea rarmsa rpusha rdressa rbatha reata rbeda /// 
rmoneya rphonea rmedsa rtoilta rmealsa rshopa radl6a rlbsatwlf raeducl hrural  ///
remail rsight rdsight rnsight rcatrct rcatrcte rglaucoma rhearing rhearaid rfall /// 
rfallinj rfallnum rhipe rurinai rurinaf rnoteeth rfallslp rwakent rwakeup ///
rrested rrxslp rpainfr rpainlv rpaina rrxpain ///
rhystere rlstmnspd rswell rbreath rdizzy rbackp rheadache rfatigue rwheeze rhrtatte  ///
rangine rconhrtfe rshingle rhrtrhme rosteoe rhchole rhrtatt rangin rconhrtf rhrtrhm  ///
rrxhibp rrxdiabo rrxdiabi rrxdiab rrxstrok rrxangina rrxchf rrxlung rtrpsych rcncrchem  ///
rcncrsurg rcncrradn rcncrothr rcncrmeds rrxhrtat rrxheart rrxmemry radiagdiab rreccancr  ///
rrechrtatt rrecstrok rafrhrtatt radiagchf radiaghrtr radiagangin rhrtsrg rjointr rrxhchol  ///
rrxbreath rrxstom rrxdepres rrxbldthn rbmicat robese rdrinkb rbinged rsmokef rstrtsmok  ///
rquitsmok rpneushte rnumer rverbf ramomeducl radadeducl radadoccup hlvwith rrelgwk  ///
rsocrelg_h rsocwk rsocmn rjgovtemp rjsprvs rcididep rcidianh rcidisymp rcidimde3  ///
rcidimde5 rsatlife_h rsatlifez rcantril rdiabe rimrc rdlrc rser7 rbwc20 rmo ///
rdy ryr rdw rscis rcact rpres rvp rvocab rvocabp rtr20 rmstot rcogtot rbpsys rbpdia ///
rbppuls rgrp rgrpl rgrpr rtimwlk rpmbmi rpmhght rpmwght rpmwaist riadl5a rrxarthr  ///
rrxpsych rshnglshte rorient rsysto1 rsysto2 rsysto3 rsysto rdiasto1 rdiasto2 rdiasto3 /// 
rdiasto rpulse1 rpulse2 rpulse3 rpulse rbpcomp rpuff1 rpuff2 rpuff3 rpuff rpuffcomp /// 
rlgrip1 rlgrip2 rrgrip1 rrgrip2 rlgrip rrgrip rgripcomp rsemitan rsemidone rsemicomp /// 
rfulltan rfulldone rfullcomp rsbstan rsbsdone rsbscomp rwspeed1 rwspeed2 rwspeed  ///
rwalkcomp rmheight rmweight rmwaist rmbmi rmbmicat rmobese rhtcomp rwtcomp rwatcomp ///
rhear_l1 rhear_r1 rhear_l2 rhear_r2 rhear_l rhear_r rhearcomp rhear_aid rhear_p roopmd rlstsf ///
rdtrmnd renthstc ractive rproud rintrstd rfhappy rattntv rcontent rinsprd rhopeful ///
ralert rcalm rexctd rpanasp13 rafraid rfupset rguilty rscared rfrustrat rbored /// 
rhostile rjittery rashamd rnrvous rpfsad rdstres rpanasn12 rcog27 rdementia rdepressive rmemrye ///
rwthh rwtresp rwtr_nh rwtcrnh race rproxy radtimtdth rbalsemi  /// 
rbalsemic rbalsbs rbalsbsc rbalful rbalfulc rbalfult rlbwgtr rlbelig rlbcomp  ///
rlbneur rlbext rlbopen rlbagr rlbcon5 rlbcon10 rlblonely3 rlblonely11  ///
rfrailty rmemory_z rorient_z rexecutive_z rtcog_z_z rpa rmet rdependency ///
rcntc rcntr rcntf rhobby rcare_adult rwith_grand ///
rvolunteer rcharity reducation rclub rnonreligious rpray rread ///
rwatch_tel rword_game rplay_card rwriting ruse_computer rgardening ///
rbake rsew rdo_hobby rexercize rwalk rvol rhour_vol raway_child rart) ///
(hhidpn wave inw mstath cenreg hacohort hhhid ragender rahispan raracem ///
rabmonth rabyear iwstat radmonth radyear raedyrs urbrur rarelig ragey_b ragey_e ragey_m   ///
racohbyr iwendm iwendy shlt cesd vgactx mdactx ltactx flusht cholst  ///
mammog papsm prost bmi height weight back smokev smoken drink ///
drinkd sleepe hibpe cancre lunge hearte stroke psyche arthre alzhe ///
alzhee demen demene imrcp imrcw dlrcp dlrcw tr20p tr20w ser7p ser7w  ///
bwc20p bwc20w mop dyp yrp dwp scisp cactp presp vpp mstotp cogtotp  ///
slfmem hosp nrshom doctor homcar hsptim nrstim hspnit doctim  ///
nrsnit atotn atotb atotw iearn itot covr covs higov govmr govmd govva ///
hiothp hiltc prpcnt lifein sayret retmon retyr retemp work slfemp unemp ///
hhres dadliv momliv peninc jcpen walksa joga walk1a walkra sita chaira /// 
climsa clim1a stoopa lifta dimea armsa pusha dressa batha eata beda /// 
moneya phonea medsa toilta mealsa shopa adl6a lbsatwlf raeducl rural  //////
email sight dsight nsight catrct catrcte glaucoma hearing hearaid fall /// 
fallinj fallnum hipe urinai urinaf noteeth fallslp wakent wakeup ///
rested rxslp painfr painlv paina rxpain ///
hystere lstmnspd swell breath dizzy backp headache fatigue wheeze hrtatte  ///
angine conhrtfe shingle hrtrhme osteoe hchole hrtatt angin conhrtf hrtrhm  ///
rxhibp rxdiabo rxdiabi rxdiab rxstrok rxangina rxchf rxlung trpsych cncrchem  ///
cncrsurg cncrradn cncrothr cncrmeds rxhrtat rxheart rxmemry radiagdiab reccancr  ///
rechrtatt recstrok rafrhrtatt radiagchf radiaghrtr radiagangin hrtsrg jointr rxhchol  ///
rxbreath rxstom rxdepres rxbldthn bmicat obese drinkb binged smokef strtsmok  ///
quitsmok pneushte numer verbf ramomeducl radadeducl radadoccup lvwith relgwk  ///
socrelg_h socwk socmn jgovtemp jsprvs cididep cidianh cidisymp cidimde3  ///
cidimde5 satlife_h satlifez cantril diabe imrc dlrc ser7 bwc20 mo ///
dy yr dw scis cact pres vp vocab vocabp tr20 mstot cogtot bpsys bpdia ///
bppuls grp grpl grpr timwlk pmbmi pmhght pmwght pmwaist iadl5a rxarthr  ///
rxpsych shnglshte orient systo1 systo2 systo3 systo diasto1 diasto2 diasto3 /// 
diasto pulse1 pulse2 pulse3 pulse bpcomp puff1 puff2 puff3 puff puffcomp /// 
lgrip1 lgrip2 rgrip1 rgrip2 lgrip rgrip gripcomp semitan semidone semicomp /// 
fulltan fulldone fullcomp sbstan sbsdone sbscomp wspeed1 wspeed2 wspeed  ///
walkcomp mheight mweight mwaist mbmi mbmicat mobese htcomp wtcomp watcomp  ///
hear_l1 hear_r1 hear_l2 hear_r2 hear_l hear_r hearcomp hear_aid hear_p oopmd lstsf ///
dtrmnd enthstc active proud intrstd fhappy attntv content insprd hopeful ///
alert calm exctd panasp13 afraid fupset guilty scared frustrat bored /// 
hostile jittery ashamd nrvous pfsad dstres panasn12 cog27 dementia depressive memrye ///
wthh wtresp wtr_nh wtcrnh race proxy radtimtdth balsemi  /// 
balsemic balsbs balsbsc balful balfulc balfult lbwgtr lbelig lbcomp  ///
lbneur lbext lbopen lbagr lbcon5 lbcon10 lblonely3 lblonely11  ///
frailty memory_z orient_z executive_z tcog_z_z pa met dependency ///
cntc cntr cntf hobby care_adult with_grand ///
volunteer charity education club nonreligious pray read ///
watch_tel word_game play_card writing use_computer gardening ///
bake sew do_hobby exercize walk vol hour_vol away_child art) 

label var puff1 "第一次呼吸测试结果"
label var cidimde3 "是否有过可能的重度抑郁发作3+阈值"
label var diasto "舒张压读数的平均值"
label var adl6a "ADL总分(6分)"
label var ragey_b "受访开始时的年龄"
label var ragey_e "受访中间时的年龄"
label var ragey_m "受访结束时的年龄"
label var alzhe "本期诊断为阿尔茨海默病"
label var alzhee "医生曾诊断阿尔茨海默病"
label var angin "近两年是否心绞痛"
label var angine "是否曾被诊断为心绞痛"
label var armsa "其他限制/手臂过肩膀是否困难"
label var arthre "医生曾诊断关节炎或风湿病"
label var atotb "总财富"
label var atotn "非住房财富总额"
label var atotw "总财富(不包括个人退休帐户)"
label var back "背部疼痛或问题"
label var backp "是否经历过背部疼痛或问题"
label var batha "ADL/洗澡是否困难"
label var beda  "ADL/上下床是否困难"
label var binged "酗酒天数"
label var bmi "自报BMI"
label var bmicat "bmi分类(自报)"
label var bpcomp "是否愿意并能够完成血压测试"
label var bpdia "舒张压"
label var bppuls "脉搏测量值"
label var breath "在清醒时是否经历过呼吸短促"
label var bwc20 "认知/倒数20(2分)"
label var bwc20p "认知/倒数20(2分)P"
label var bwc20w "认知/倒数20(2分)W"
label var cact "认知/正确地命名仙人掌(1分)"
label var cactp "认知/正确地命名仙人掌(1分)P"
label var cancre "医生曾诊断癌症或者恶性肿瘤"
label var cantril "社会等级自评(数字越大地位越高)"
label var catrct "本期是否报告白内障手术"
label var catrcte "曾经是否做过白内障手术"
label var cenreg "人口普查区域"
label var cesd "CESD心理健康8分(得分越高越差)"
label var chaira "其他限制/长时间坐着从椅子上站起来是否困难"
label var cholst "是否血液胆固醇检查"
label var cidianh "快感缺乏症(7分)"
label var cididep "重度抑郁发作(7分)"
label var cidimde5 "是否有过可能的重度抑郁发作5+阈值"
label var cidisymp "遇到的症状总数(7分)"
label var clim1a "其他限制/不休息地爬一段楼梯是否困难"
label var climsa "其他限制/不休息地爬几段楼梯是否困难"
label var cncrchem "是否接受化疗或药物治疗癌症"
label var cncrmeds "是否接受了治疗癌症的药物或治疗症状(疼痛、恶心、皮疹)"
label var cncrothr "是否接受过另一种未指明的癌症治疗"
label var cncrradn "是否接受过放射或x射线治疗癌症"
label var cncrsurg "是否接受过手术或活检以治疗癌症"
label var cogtot "认知能力(35分)"
label var cogtotp "认知能力(35分)P"
label var conhrtf "近两年是否充血性心力衰竭"
label var conhrtfe "是否曾被诊断为充血性心力衰竭"
label var covr "是否有其现任或前任雇主提供的医疗保险"
label var covs "是否受其配偶雇主的健康保险"
label var dadliv "父亲是否健在"
label var demen "本期诊断为痴呆症"
label var demene "医生曾诊断痴呆症"
label var diabe "医生曾诊断糖尿病或高血糖"
label var diasto1 "第一次脉冲读数"
label var diasto2 "第二次脉冲读数"
label var diasto3 "第三次脉冲读数"
label var dimea "其他限制/捡起一角硬币是否困难"
label var dizzy "是否经历过持续的头晕或头晕"
label var dlrc "认知/延迟单词回忆(10分)"
label var dlrcp "认知/延迟单词回忆(10分)P"
label var dlrcw "认知/延迟单词回忆(10分)W"
label var doctim "过去2年门诊次数"
label var doctor "过去2年是否门诊"
label var dressa "ADL/穿衣是否困难"
label var drink "是否饮酒"
label var drinkb "是否曾经酗酒"
label var drinkd "饮酒频率(每周喝几天)"
label var dsight "远视评分"
label var dw "认知/星期(1分)"
label var dwp "认知/星期(1分)P"
label var dy "认知/日(1分)"
label var dyp "认知/日(1分)P"
label var eata "ADL/吃饭是否困难"
label var email "是否使用互联网发邮件或其他目的"
label var fall "过去2年中是否跌倒过"
label var fallinj "是否因跌倒而受伤"
label var fallnum "跌倒次数"
label var fallslp "经历睡眠问题的频率"
label var fallslp "醒得太早而无法再入睡的频率"
label var fatigue "是否经历过严重的疲劳或疲惫"
label var flusht "是否流感疫苗"
label var fullcomp "是否愿意并能够双脚前后成一直线站立"
label var fulldone "是否双脚前后成一直线站立保持整整30/60秒的平衡"
label var fulltan "双脚前后成一直线站立的时间"
label var vocab "认知/词汇(5分)"
label var vocabp "认知/词汇(5分)P"
label var glaucoma "曾经接受过青光眼治疗"
label var govmd "是否有穷人健康保险"
label var govmr "是否有老年健康保险"
label var govva "是否有军人健康保险"
label var gripcomp "是否愿意并能够完成握力测试"
label var grp "双手的总合测量"
label var grpl "左手握力最大值"
label var grpr "右手握力最大值"
label var hacohort "家庭最初被抽样的队列"
label var hacohort "家庭最初被抽样的队列"
label var hchole "是否曾经有过高胆固醇"
label var headache "是否经历过持续性头痛"
label var hear_aid "参加听力测试是否佩戴助听器"
label var hear_l "左耳听力总12分"
label var hear_l1 "左耳听力6分"
label var hear_l2 "左耳第二次听力6分"
label var hear_p "听力测试中是否出现任何问题"
label var hear_r "右耳听力总12分"
label var hear_r1 "右耳听力6分"
label var hear_r2 "右耳第二次听力6分"
label var hearcomp "是否愿意并能够完成听力测试"
label var hearing "自评听力"
label var hearte "医生曾诊断心脏病"
label var height "自报身高m"
label var hhhid "家庭标识符"
label var hhidpn "个人标识符"
label var hhres "家庭人数" 
label var hibpe "医生曾诊断高血压"
label var higov "是否被任何政府健康保险计划所覆盖"
label var hiltc "是否有长期护理保险"
label var hiothp "是否有其他类型的保险"
label var hipe "曾经是否髋部骨折"
label var homcar "过去2年是否有任何家庭护理"
label var hosp "过去2年是否住院"
label var hrtatt "近两年是否心脏病发作"
label var hrtatte "是否曾经被诊断患有心脏病"
label var hrtrhm "近两年是否心律异常"
label var hrtrhme "是否曾被诊断为心律异常"
label var hrtsrg "最近两年内进行过心脏手术"
label var rural "家庭生活在城市还是农村"
label var hspnit "过去2年住院天数"
label var hsptim "最近2年住院次数"
label var htcomp "是否愿意并能够完成身高测量"
label var hystere "是否曾经做过子宫切除术"
label var iadl5a "IADL总分(5分)"
label var iearn "个人的收入"
label var imrc "认知/即时单词回忆10分"
label var imrcp "认知/即时单词回忆10分P"
label var imrcw "认知/即时单词回忆10分W"
label var inw "是否参与本次调查"
label var itot "受访者两人的收入"
label var iwendm "受访月份"
label var iwendy "受访年份"
label var iwstat "是否死亡"
label var jcpen "是否有当前工作的养老金计划"
label var joga "其他/慢跑一英里是否困难"
label var jointr "最近两年内进行过关节置换手术"
label var jsprvs "工作中对其他人的工资和晋升做出决定"
label var lbsatwlf "生活满意度7分"
label var lgrip "左手最大手部力量测量值"
label var lgrip1 "左手第一次的力量测量值"
label var lgrip2 "左手第二次的力量测量值"
label var lifein "是否有人寿保险"
label var lifta "其他限制/举起或搬运超过10磅的重物是否困难"
label var lstmnspd "最后一次月经的年龄"
label var ltactx "轻度身体活动频率"
label var lunge "医生曾诊断慢性肺部疾病"
label var lvwith "家庭的居住安排"
label var mammog "是否乳房x光检查"
label var mbmi "测量BMI"
label var mbmicat "BMI类别"
label var mdactx "中度身体活动频率"
label var mealsa "IADL/准备热饭是否困难"
label var medsa "IADL/吃药是否困难"
label var mheight "测量身高(米)"
label var mo "认知/月(1分)"
label var mobese "是否被归类为测量肥胖"
label var momliv "母亲是否健在"
label var moneya "IADL/管钱是否困难"
label var mop "认知/月(1分)P"
label var mstath "婚姻状况"
label var mstot "心理状态(15分)"
label var mstotp "心理状态(15分)P"
label var mwaist "测量腰围(厘米)"
label var mweight "测量体重(公斤)"
label var noteeth "是否失去了所有的牙齿"
label var nrshom "过去2年是否曾在养老院过夜"
label var nrsnit "过去2年养老院住宿天数"
label var nrstim "过去2年养老院住宿次数"
label var nsight "远视评分"
label var numer "数学表现能力进行评分的总结性测量3分"
label var obese "是否肥胖"
label var oopmd "过去2年自付医疗费用"
label var orient "正确命名月、月、年和星期的能力4分"
label var osteoe "是否曾有骨质疏松症"
label var paina "是否疼痛干扰正常活动"
label var painfr "是否经常感到疼痛"
label var painlv "疼痛程度"
label var papsm "是否巴氏涂片检查"
label var peninc "目前是否领取任何养老金收入"
label var phonea "IADL/使用电话是否困难"
label var pmbmi "测量的BMI"
label var pmhght "测量的身高m"
label var pmwaist "测量的腰围(英寸)"
label var pmwght "测量的体重kg"
label var pneushte "是否曾接种过肺炎疫苗"
label var pres "正确说出美国现任总统(1分)"
label var presp "认知/正确说出美国现任总统(1分)P"
label var prost "是否前列腺癌检查"
label var prpcnt "私人健康保险的数量"
label var psyche "医生曾诊断情绪、神经或精神问题"
label var bpsys "收缩压"
label var puff "呼吸测试测量值的最大值"
label var puff "呼吸测试的最大测量值"
label var puff2 "第二次呼吸测试结果"
label var puff3 "第三次呼吸测试结果"
label var puffcomp "是否愿意并能够完成呼吸测试"
label var pulse "脉冲读数的平均值"
label var pulse1 "第一次脉冲读数"
label var pulse2 "第二次脉冲读数"
label var pulse3 "第三次脉冲读数"
label var pusha "其他限制/推拉物体是否困难"
label var quitsmok "戒烟的年龄"
label var rabmonth "出生月份"
label var rabyear "出生年份"
label var radadeducl "父亲教育水平"
label var radadoccup "16岁时父亲的职业"
label var radiagangin "首次被诊断为心绞痛的年龄"
label var radiagchf "首次被诊断为充血性心力衰竭的年龄"
label var radiagdiab "首次被诊断为糖尿病的年龄"
label var radiaghrtr "首次被诊断为心律异常的年龄"
label var radmonth "死亡月份"
label var radyear "死亡年份"
label var raeducl "统一可比的教育程度"
label var raedyrs "受教育年限"
label var rafrhrtatt "最近一次心脏病发作的年龄"
label var ragender "性别"
label var rahispan "是否西班牙裔"
label var ramomeducl "统一可比的母亲教育水平"
label var raracem "种族"
label var rarelig "宗教"
label var reccancr "最近被诊断出患有癌症的年龄"
label var rechrtatt "最近一次心脏病发作的年龄"
label var recstrok "最近一次中风的年龄"
label var relgwk "过去一年中是否至少每周参加一次宗教仪式"
label var rested "醒来时感到精力充沛的的频率"
label var retemp "退休状态"
label var retmon "退休月份"
label var retyr "退休年份"
label var rgrip "右手最大手部力量测量值"
label var rgrip1 "右手第一次的力量测量值"
label var rgrip2 "右手第二次的力量测量值"
label var rxangina "是否服用心绞痛药物"
label var rxarthr "是否服用关节炎或风湿病药物"
label var rxbldthn "是否服用阿司匹林以外的药物来稀释血液或防止血栓"
label var rxbreath "是否服用治疗呼吸问题的药物"
label var rxchf "是否服用充血性心力衰竭药物"
label var rxdepres "是否服用药物来帮助缓解焦虑或抑郁"
label var rxdiab "是否服用口服药物或使用胰岛素注射治疗糖尿病"
label var rxdiabi "是否使用胰岛素注射剂或胰岛素泵治疗糖尿病"
label var rxdiabo "是否服用口服糖尿病药物" 
label var rxhchol "是否服用高胆固醇类药物"
label var rxheart "是否服用治疗心脏问题的药物"
label var rxhibp "是否服用高血压药物"
label var rxhrtat "是否因心脏病发作或心肌梗死而服用药物"
label var rxlung "是否服用慢性肺部疾病的药物"
label var rxmemry "是否服用了与记忆有关的疾病的药物"
label var rxpain "是否服用关节或肌肉疼痛的药物"
label var rxpsych "是否因情绪、神经或精神问题而服用药物"
label var rxslp "是否服用药物来帮助他们入睡"
label var rxstom "是否服用胃病药物"
label var rxstrok "是否服用中风药物"
label var satlife_h "生活满意度"
label var satlifez "生活满意度Z标准化"
label var sayret "是否认为自己退休"
label var sbscomp "是否愿意并且能够完成双脚并拢站立测试"
label var sbsdone "是否在双脚并拢站立测试10秒内保持平衡"
label var sbstan "双脚并拢站立测试的时间"
label var scis "认知/正确地命名剪刀(1分)"
label var scisp "认知/正确地命名剪刀(1分)P"
label var semicomp "是否愿意并能够完成双脚半前后站立"
label var semidone "是否双脚半前后站立保持10秒"
label var semitan "双脚半前后站立的时间"
label var ser7p "认知/减法(5分)P"
label var ser7w "认知/减法(5分)W"
label var shingle "是否曾被诊断患有带状疱疹"
label var shlt "自评健康"
label var shnglshte "是否曾接种过带状疱疹疫苗"
label var shopa "IADL/购买杂货是否困难"
label var sight "自评视力"
label var sita "其他限制/坐约2小时是否困难"
label var sleepe "医生曾诊断睡眠障碍"
label var slfemp "是否自雇"
label var slfmem "自评记忆"
label var smokef "每天抽多少支烟"
label var smoken "现在是否吸烟"
label var smokev "曾经是否吸过烟"
label var socmn "是否每月参加任何社会活动"
label var socrelg_h "过去一年中参加宗教仪式的频率"
label var socwk "是否每周参加任何社会活动"
label var stoopa "其他限制/弯腰跪蹲是否困难"
label var stroke "医生曾诊断中风或短暂性脑缺血发作"
label var strtsmok "开始吸烟的年龄"
label var swell "是否经历过脚或脚踝的持续肿胀"
label var systo "收缩压读数的平均值"
label var systo1 "第一次收缩压读数"
label var systo2 "第二次收缩压读数"
label var systo3 "第三次收缩压读数"
label var timwlk "正常速度行走98.5英寸所需的最短秒数"
label var toilta "ADL/上厕所是否困难"
label var tr20 "单词回忆(20分)"
label var tr20p "单词回忆(20分)P"
label var tr20w "单词回忆(20分)W"
label var trpsych "是否因情绪、神经或精神问题而接受治疗"
label var unemp "是否失业"
label var urbrur "城市化程度"
label var urinaf "上个月尿失禁的天数"
label var urinai "去年是否尿失禁"
label var verbf "语言流利度分数"
label var vgactx "强度身体活动频率"
label var vp "认知/正确说出美国现任副总统(1分)"
label var vpp "认知/正确说出美国现任副总统(1分)P"
label var wakent "在夜间醒来的频率"
label var walk1a "其他限制/步行一个街区是否困难"
label var walkcomp "是否愿意并且能够完成步行速度测试"
label var walkra "ADL/房间里行走是否困难"
label var walksa "其他限制/步行几个街区是否困难"
label var watcomp "是否愿意并能够完成腰围测量"
label var weight "自报体重kg"
label var wheeze "是否经历过持续的喘息、咳嗽或带痰"
label var work "是否在有偿工作"
label var wspeed "平均行走速度"
label var wspeed1 "第一次行走速度"
label var wspeed2 "第二次行走速度"
label var wtcomp "是否愿意并能够完成体重测量"
label var yr "认知/年(1分)"
label var yrp "认知/年(1分)P"
label var lstsf "对自己生活的满意程度7分"
label var wave "第几轮调查"
label define wave_ 5 "第5轮" 6 "第6轮" 7 "第7轮" 8 "第8轮" 9 "第9轮" 10 "第10轮" ///
  11 "第11轮" 12 "第12轮" 13 "第13轮" 14 "第14轮" 15 "第15轮" 
label values wave wave_
label var racohbyr "根据被调查者的出生年份确定其所属队列" 
label var dtrmnd "过去30天内感到坚定的程度"
label var enthstc "过去30天内感到热情的程度"
label var active "过去30天内感到活跃的程度"
label var proud "过去30天内感到自豪的程度"
label var intrstd "过去30天内感兴趣的程度"
label var fhappy "过去30天内感到快乐的程度"
label var attntv "过去30天内感到关注的程度"
label var content "过去30天内感到满意的程度"
label var insprd "过去30天内受到启发的程度"
label var hopeful "过去30天内感到有希望的程度"
label var alert "过去30天内感到警觉的程度"
label var calm "过去30天内感到平静的程度"
label var exctd "过去30天内感到兴奋的程度"
label var panasp13 "13项积极情绪指数"
label var afraid "过去30天内感到害怕的程度"
label var fupset "过去30天内感到不安的程度"
label var guilty "过去30天内感到内疚的程度"
label var scared "过去30天内感到害怕的程度"
label var frustrat "过去30天内感到沮丧的程度"
label var bored "过去30天内感到无聊的程度"
label var hostile "过去30天内感受到敌意的程度"
label var jittery "过去30天内感到紧张的程度"
label var ashamd "过去30天内感到羞耻的程度"
label var nrvous "过去30天内感到紧张的程度"
label var pfsad "过去30天内感到悲伤的程度"
label var dstres "过去30天内感到痛苦的程度"
label var panasn12 "12个项目的负面情绪指数"
label var cog27 "认知能力27分量表"
label var dementia "痴呆症/认知27分类"
label var depressive "CESD是否抑郁"
label var memrye "医生曾诊断患有记忆疾病"
label var wthh "家庭权重"
label var wtresp "个体权重"
label var wtr_nh "生活在养老院的个人权重"
label var wtcrnh "个人层面权重和养老院权重的总和"
label var race "种族四等划分"
label var proxy "是否代理回答"
label var radtimtdth "最后一次受访和死亡之间的时间跨度"
label var balsemi "双脚半前后站立秒数"
label var balsemic "双脚半前后站立站立测量过程中是否做了任何补偿动作来稳定自己"
label var balsbs "双脚并拢站立秒数"
label var balsbsc "双脚并拢站立测量过程中是否做了任何补偿动作来稳定自己"
label var balful "双脚前后成一直线站立秒数"
label var balfulc "双脚前后成一直线站立测量过程中是否做了任何补偿动作来稳定自己"
label var balfult "双脚前后成一直线站立完成要求的时间"
label var lbwgtr "留后调查问卷的抽样权重"
label var lbelig "是否有资格回答留后调查问卷"
label var lbcomp "是否完成了留后调查问卷"
label var lbneur "大五人格特质/神经质"
label var lbext "大五人格特质/外倾性"
label var lbopen "大五人格特质/开放性"
label var lbagr "大五人格特质/宜人性"
label var lbcon5 "大五人格特质/尽责性"
label var lbcon10 "大五人格特质/尽责性"
label var lblonely3 "孤独3项"
label var lblonely11 "孤独11项"
label var frailty "衰弱指数"
label var memory_z "记忆力z标准化(ref基线)"
label var orient_z "定向z标准化(ref基线)"
label var executive_z "执行z标准化(ref基线)"
label var tcog_z_z "总体认知能力z标准化(ref基线)"
label var pa "是否定期每周中度以上的身体活动"
label var met "MET等效活动点"
label var dependency "按需求间隔依赖性分类划分的功能依赖性"
label var away_child "是否有子女住在10英里以内"
label var hearaid "是否戴助听器" 
label var wakeup "醒得太早而无法再入睡的频率" 
label var jgovtemp "是否为政府工作" 
label var walk "步行20分钟" 
label var art "参与社区艺术小组频率"  
label var care_adult "照顾成年人频率"
label var with_grand "与孙子孙女一起活动频率"
label var volunteer "志愿服务青少年频率"
label var charity "慈善工作频率"
label var education "教育频率"
label var club "参加体育/社交/俱乐部频率"
label var nonreligious "参加非宗教组织频率"
label var pray "私下祈祷频率"
label var read "阅读频率"
label var watch_tel "看电视频率"
label var word_game "做文字游戏频率"
label var play_card "玩纸牌和游戏频率"
label var writing "做写作频率"
label var use_computer "使用电脑频率"
label var gardening "维护/园频率艺"
label var bake "烘焙或烹饪频率"
label var sew "缝纫或编织频率"
label var do_hobby "做爱好频率"
label var exercize "运动/锻炼频率"
label var cntc "是否每月与子女接触"
label var cntr "是否每月与亲人接触"
label var cntf "是否每月与朋友接触"
label var hobby "是否爱好"
label var vol "是否志愿服务"
label var hour_vol "志愿者时长区间"
label var ser7 "认知/减法(5分)"

*****所有缺失值类型转为.
mvencode _all, mv(-999.99) 
mvdecode _all, mv(-999.99)

*****只保留参与每一轮调查的样本
keep if inw==1   //只保留参与调查的个体
drop inw

*****final sort
sort hhidpn

*****compress dataset
compress	

*****add label
label data "Shawn老师 @丁点帮你"

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你

save "$working_data/hrs.dta",replace

*****单独保存每一期数据
local num_waves = 15 // 设置波次总数

forvalues wave = 5/`num_waves' {
    use "$working_data/hrs.dta", clear
    keep if wave == `wave'
    save "$working_data/hrs_wave`wave'.dta", replace
}

