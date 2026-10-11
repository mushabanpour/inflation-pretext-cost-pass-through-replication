/********************************************************************
BASELINE REGRESSIONS: COST PASS-THROUGH IN AIRLINE INDUSTRY
Output: $out/baseline/tables/
Tables: 2 (main), 3 (inflation x concentration), 4 (carrier technology),
        5 (dominance and concentrated)

Notes:
- Bottom panel reports controls, route FE, carrier FE, first-stage statistic, and R-squared.
- The text log includes first-stage output via the ivreghdfe first option.
********************************************************************/

clear all
set more off
capture log close _all

*----------------------------
* 0) Paths
*----------------------------
global data  "`c(pwd)'/rkt_ready.dta"
global out   "`c(pwd)'/output"
global base  "$out/baseline"
global tabs  "$base/tables"
global logs  "$base/logs"

cap mkdir "$out"
cap mkdir "$base"
cap mkdir "$tabs"
cap mkdir "$logs"

log using "$logs/baseline_passthrough.log", replace text

use "$data", clear
xtset panel_id quarter_date


*=========================================================
* NOTE: All analysis variables (fuel_growth, us_jetfuel_growth, inflation,
*       high_inf, hhi[/1000], high_hhi, share, high_share, carrier_type,
*       income_growth, population_growth) are pre-built in rkt_ready.dta
*       by build_rkt_ready.do. This file only runs the regressions/tables.
*=========================================================

*=========================================================
* HELPER: Bottom-panel statistics for esttab
*=========================================================

capture program drop add_bottom_panel
program define add_bottom_panel
    tempname fs r2val

    * Qualitative bottom-panel indicators
    estadd local controls   "Yes"
    estadd local route_fe   "Yes"
    estadd local carrier_fe "Yes"

    * Robust IV first-stage / weak-ID statistic.
    * With ivreghdfe/ivreg2 and robust SEs, e(widstat) is typically
    * the Kleibergen-Paap rk Wald F statistic. If unavailable, leave missing.
    capture scalar `fs' = e(widstat)
    if _rc {
        scalar `fs' = .
    }
    estadd scalar firststage = `fs'

    * R-squared from the second-stage model, if reported.
    capture scalar `r2val' = e(r2)
    if _rc {
        scalar `r2val' = .
    }
    estadd scalar r2stat = `r2val'
end

*=========================================================
* HELPER: formatted coefficients for manually written tables
*=========================================================

capture program drop make_star
program define make_star, rclass
    syntax, B(real) SE(real) P(real)

    local stars ""
    if `p' < 0.01 local stars "\sym{***}"
    else if `p' < 0.05 local stars "\sym{**}"
    else if `p' < 0.10 local stars "\sym{*}"

    return local bstr  = strtrim(string(`b', "%9.3f")) + "`stars'"
    return local sestr = "(" + strtrim(string(`se', "%9.3f")) + ")"
end

capture program drop one_lincom
program define one_lincom, rclass
    syntax anything

    quietly lincom `anything'

    local b  = r(estimate)
    local se = r(se)
    local p  = r(p)

    make_star, b(`b') se(`se') p(`p')

    return local bstr  = "`r(bstr)'"
    return local sestr = "`r(sestr)'"
    return scalar b    = `b'
    return scalar se   = `se'
    return scalar p    = `p'
end

*=========================================================
* TABLE 2: MAIN PASS-THROUGH RESULTS (6 specifications)
*          Uses only High Inflation and High HHI dummies;
*          continuous inflation and continuous HHI are excluded.
*=========================================================

eststo clear

* Model 1: Fuel + HHI
ivreghdfe price_growth ///
    (fuel_growth = us_jetfuel_growth) ///
    high_hhi ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m1_fuel_hhi


* Model 2: Add Inflation
ivreghdfe price_growth ///
    high_inf high_hhi ///
    (fuel_growth = us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m2_add_inf


* Model 3: Add Fuel x Inflation
ivreghdfe price_growth ///
    high_inf high_hhi ///
    (fuel_growth ///
     c.high_inf#c.fuel_growth = ///
     us_jetfuel_growth ///
     c.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m3_fuelXinf


* Model 4: Add Fuel x HHI instead of Fuel x Inflation
ivreghdfe price_growth ///
    high_inf high_hhi ///
    (fuel_growth ///
     c.high_hhi#c.fuel_growth = ///
     us_jetfuel_growth ///
     c.high_hhi#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m4_fuelXhhi


* Model 5: Add Fuel x Inflation and Fuel x HHI
ivreghdfe price_growth ///
    high_inf high_hhi ///
    (fuel_growth ///
     c.high_inf#c.fuel_growth ///
     c.high_hhi#c.fuel_growth = ///
     us_jetfuel_growth ///
     c.high_inf#c.us_jetfuel_growth ///
     c.high_hhi#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m5_fuelXinf_hhi


* Model 6: Triple interaction Fuel x Inflation x HHI
ivreghdfe price_growth ///
    high_inf high_hhi c.high_inf#c.high_hhi ///
    (fuel_growth ///
     c.high_inf#c.fuel_growth ///
     c.high_hhi#c.fuel_growth ///
     c.high_inf#c.high_hhi#c.fuel_growth = ///
     us_jetfuel_growth ///
     c.high_inf#c.us_jetfuel_growth ///
     c.high_hhi#c.us_jetfuel_growth ///
     c.high_inf#c.high_hhi#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store m6_triple


esttab m1_fuel_hhi m2_add_inf m3_fuelXinf m4_fuelXhhi m5_fuelXinf_hhi m6_triple ///
    using "$tabs/table2.tex", replace ///
    fragment label noobs nonotes ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    keep(fuel_growth ///
         high_inf ///
         c.high_inf#c.fuel_growth ///
         high_hhi ///
         c.high_hhi#c.fuel_growth ///
         c.high_inf#c.high_hhi ///
         c.high_inf#c.high_hhi#c.fuel_growth) ///
    order(fuel_growth ///
          high_hhi ///
          high_inf ///
          c.high_inf#c.fuel_growth ///
          c.high_hhi#c.fuel_growth ///
          c.high_inf#c.high_hhi ///
          c.high_inf#c.high_hhi#c.fuel_growth) ///
    varlabels(fuel_growth "Fuel Growth" ///
              high_hhi "High HHI" ///
              high_inf "High Inflation" ///
              c.high_inf#c.fuel_growth "Fuel Growth \$\times\$ High Inflation" ///
              c.high_hhi#c.fuel_growth "Fuel Growth \$\times\$ High HHI" ///
              c.high_inf#c.high_hhi "High Inflation \$\times\$ High HHI" ///
              c.high_inf#c.high_hhi#c.fuel_growth "Fuel Growth \$\times\$ High Inflation \$\times\$ High HHI") ///
    mtitles("Fuel + HHI" "+Inflation" "+Fuel\$\times\$Inf." "+Fuel\$\times\$HHI" "+Both Fuel Interactions" "+Triple") ///
    prehead("\begin{sidewaystable}[p]" ///
            "\centering" ///
            "\caption{Main Fuel Cost Pass-Through Specifications}" ///
            "\label{tab:main_passthrough}" ///
            "\scriptsize" ///
            "\setlength{\tabcolsep}{2pt}" ///
            "\renewcommand{\arraystretch}{0.9}" ///
            "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
            "\begin{tabular}{l*{6}{c}}" ///
            "\\[-1.8ex]\hline" ///
            "\hline \\[-1.8ex]") ///
    posthead("\hline \\[-1.8ex]") ///
    prefoot("\hline \\[-1.8ex]") ///
    stats(N controls route_fe carrier_fe firststage r2stat, ///
          labels("Observations" "Controls" "Route FE" "Carrier FE" "Kleibergen-Paap F" "R-squared") ///
          fmt(%9.0fc %9s %9s %9s %9.2f %9.3f)) ///
    postfoot("\hline \\[-1.8ex]" ///
             "\end{tabular}" ///
             "\begin{tablenotes}[Note]" ///
             "All specifications are estimated via 2SLS. Fuel growth and its endogenous interaction terms are instrumented with U.S. jet fuel growth and the corresponding interaction instruments. High Inflation is defined as inflation \$>3\%\$; High HHI is defined as HHI \$>2500\$. Continuous inflation and continuous HHI are excluded from Table 2; regime dummies are included instead. Controls are income growth and population growth. Route and carrier fixed effects are absorbed. Robust standard errors are in parentheses. Kleibergen-Paap F reports the Kleibergen-Paap rk Wald F statistic when available.\sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
             "\end{tablenotes}" ///
             "\end{sidewaystable}")


*=========================================================
* TABLE 3: INFLATION x CONCENTRATION
*=========================================================

eststo clear

* Cell 1: Low Inflation, Low Concentration
ivreghdfe price_growth ///
    (fuel_growth = us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_inf == 0 & high_hhi == 0, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store cell_loinf_lohhi

* Cell 2: Low Inflation, High Concentration
ivreghdfe price_growth ///
    (fuel_growth = us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_inf == 0 & high_hhi == 1, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store cell_loinf_hihhi

* Cell 3: High Inflation, Low Concentration
ivreghdfe price_growth ///
    (fuel_growth = us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_inf == 1 & high_hhi == 0, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store cell_hiinf_lohhi

* Cell 4: High Inflation, High Concentration
ivreghdfe price_growth ///
    (fuel_growth = us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_inf == 1 & high_hhi == 1, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store cell_hiinf_hihhi

esttab cell_loinf_lohhi cell_loinf_hihhi cell_hiinf_lohhi cell_hiinf_hihhi ///
    using "$tabs/table3.tex", replace ///
    fragment label noobs nonotes ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    keep(fuel_growth) ///
    varlabels(fuel_growth "Fuel Growth") ///
    mgroups("Low Inflation" "High Inflation", ///
            pattern(1 0 1 0) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            span erepeat(\cline{@span})) ///
    mtitles("Low HHI" "High HHI" "Low HHI" "High HHI") ///
    prehead("\begin{table}[p]" ///
            "\centering" ///
            "\caption{Fuel Cost Pass-Through by Inflation and Market Concentration}" ///
            "\label{tab:inflation_concentration}" ///
            "\scriptsize" ///
            "\setlength{\tabcolsep}{2pt}" ///
            "\renewcommand{\arraystretch}{0.9}" ///
            "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
            "\begin{tabular}{l*{4}{c}}" ///
            "\\[-1.8ex]\hline" ///
            "\hline \\[-1.8ex]") ///
    posthead("\hline \\[-1.8ex]") ///
    prefoot("\hline \\[-1.8ex]") ///
    stats(N controls route_fe carrier_fe firststage r2stat, ///
          labels("Observations" "Controls" "Route FE" "Carrier FE" "Kleibergen-Paap F" "R-squared") ///
          fmt(%9.0fc %9s %9s %9s %9.2f %9.3f)) ///
    postfoot("\hline \\[-1.8ex]" ///
             "\end{tabular}" ///
             "\begin{tablenotes}[Note]" ///
             "All specifications are estimated via 2SLS. Fuel growth is instrumented with rivals' fuel growth. Columns split the sample by inflation and route-level concentration. High Inflation is defined as inflation \$>3\%\$; High HHI is defined as HHI \$>2500\$. HHI is divided by 1000 in the estimation dataset. Controls are income growth and population growth. Route and carrier fixed effects are absorbed. Robust standard errors are in parentheses. Kleibergen-Paap F reports the Kleibergen-Paap rk Wald F statistic when available.\sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
             "\end{tablenotes}" ///
             "\end{table}")


*=========================================================
* TABLE 4: Carrier Technology
*=========================================================

eststo clear

* Column (1): baseline pass-through by carrier type
ivreghdfe price_growth ///
    (ibn.carrier_type#c.fuel_growth = ///
     ibn.carrier_type#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store type_base

local N_type_base = e(N)
capture scalar __r2_type_base = e(r2)
if _rc local r2_type_base = .
else local r2_type_base = __r2_type_base
capture scalar __kpF_type_base = e(widstat)
if _rc local kpF_type_base = .
else local kpF_type_base = __kpF_type_base

tempfile type_base_results
postfile typebase int type_id str20 type_name ///
    double b se p using `type_base_results', replace

forvalues t = 1/3 {
    local tname : label carrier_type_lbl `t'

    one_lincom `t'.carrier_type#c.fuel_growth

    post typebase (`t') ("`tname'") (r(b)) (r(se)) (r(p))
}
postclose typebase


* Column (2): high-inflation premium by carrier type
ivreghdfe price_growth ///
    (ibn.carrier_type#ibn.high_inf#c.fuel_growth = ///
     ibn.carrier_type#ibn.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store type_inf

local N_type_inf = e(N)
capture scalar __r2_type_inf = e(r2)
if _rc local r2_type_inf = .
else local r2_type_inf = __r2_type_inf
capture scalar __kpF_type_inf = e(widstat)
if _rc local kpF_type_inf = .
else local kpF_type_inf = __kpF_type_inf

tempfile type_inf_results
postfile typeinf int type_id double b se p using `type_inf_results', replace

forvalues t = 1/3 {
    one_lincom `t'.carrier_type#1.high_inf#c.fuel_growth ///
        - `t'.carrier_type#0bn.high_inf#c.fuel_growth

    post typeinf (`t') (r(b)) (r(se)) (r(p))
}
postclose typeinf


* Column (3): high-HHI premium by carrier type
ivreghdfe price_growth ///
    (ibn.carrier_type#ibn.high_hhi#c.fuel_growth = ///
     ibn.carrier_type#ibn.high_hhi#c.us_jetfuel_growth) ///
    income_growth population_growth, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store type_hhi

local N_type_hhi = e(N)
capture scalar __r2_type_hhi = e(r2)
if _rc local r2_type_hhi = .
else local r2_type_hhi = __r2_type_hhi
capture scalar __kpF_type_hhi = e(widstat)
if _rc local kpF_type_hhi = .
else local kpF_type_hhi = __kpF_type_hhi

tempfile type_hhi_results
postfile typehhi int type_id double b se p using `type_hhi_results', replace

forvalues t = 1/3 {
    one_lincom `t'.carrier_type#1.high_hhi#c.fuel_growth ///
        - `t'.carrier_type#0bn.high_hhi#c.fuel_growth

    post typehhi (`t') (r(b)) (r(se)) (r(p))
}
postclose typehhi


* Merge carrier-type results into one temporary file.
* Preserve the full estimation dataset while we temporarily load
* the posted lincom results for manual LaTeX writing.
preserve
use `type_base_results', clear
rename b base_b
rename se base_se
rename p base_p

merge 1:1 type_id using `type_inf_results', nogen
rename b inf_b
rename se inf_se
rename p inf_p

merge 1:1 type_id using `type_hhi_results', nogen
rename b hhi_b
rename se hhi_se
rename p hhi_p

tempfile type_all
save `type_all', replace

* Format estimates for the LaTeX table.
foreach x in base inf hhi {
    gen str10 `x'_stars = ""
    replace `x'_stars = "\sym{***}" if `x'_p < 0.01
    replace `x'_stars = "\sym{**}"  if `x'_p >= 0.01 & `x'_p < 0.05
    replace `x'_stars = "\sym{*}"   if `x'_p >= 0.05 & `x'_p < 0.10

    gen str20 `x'_bstr  = strtrim(string(`x'_b,  "%9.3f")) + `x'_stars
    gen str20 `x'_sestr = "(" + strtrim(string(`x'_se, "%9.3f")) + ")"
}

local N1 : display %9.0fc `N_type_base'
local N2 : display %9.0fc `N_type_inf'
local N3 : display %9.0fc `N_type_hhi'
local N1 = strtrim("`N1'")
local N2 = strtrim("`N2'")
local N3 = strtrim("`N3'")

local F1 : display %9.2f `kpF_type_base'
local F2 : display %9.2f `kpF_type_inf'
local F3 : display %9.2f `kpF_type_hhi'
local F1 = strtrim("`F1'")
local F2 = strtrim("`F2'")
local F3 = strtrim("`F3'")

local R1 : display %9.3f `r2_type_base'
local R2 : display %9.3f `r2_type_inf'
local R3 : display %9.3f `r2_type_hhi'
local R1 = strtrim("`R1'")
local R2 = strtrim("`R2'")
local R3 = strtrim("`R3'")

file open tfh using "$tabs/table4.tex", write replace
file write tfh "\begin{table}[p]" _n
file write tfh "\centering" _n
file write tfh "\caption{Heterogeneity in Fuel Cost Pass-Through by Carrier and Carrier Type}" _n
file write tfh "\label{tab:carrier_heterogeneity}" _n
file write tfh "\scriptsize" _n
file write tfh "\setlength{\tabcolsep}{2pt}" _n
file write tfh "\renewcommand{\arraystretch}{0.9}" _n
file write tfh "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write tfh "\begin{tabular}{l*{3}{c}}" _n
file write tfh "\\[-1.8ex]\hline" _n
file write tfh "\hline \\[-1.8ex]" _n
file write tfh "            &\multicolumn{1}{c}{(1)}&\multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}\\" _n
file write tfh "            &\multicolumn{1}{c}{Baseline Pass-Through}&\multicolumn{1}{c}{High-Inflation Increment}&\multicolumn{1}{c}{High-HHI Increment}\\" _n
file write tfh "\hline \\[-1.8ex]" _n

forvalues i = 1/`=_N' {
    local row = type_name[`i']
    local b1  = base_bstr[`i']
    local b2  = inf_bstr[`i']
    local b3  = hhi_bstr[`i']
    local se1 = base_sestr[`i']
    local se2 = inf_sestr[`i']
    local se3 = hhi_sestr[`i']

    file write tfh "`row' & `b1' & `b2' & `b3' \\" _n
    file write tfh "            & `se1' & `se2' & `se3' \\" _n
}

file write tfh "\hline \\[-1.8ex]" _n
file write tfh "Observations & `N1' & `N2' & `N3' \\" _n
file write tfh "Controls & Yes & Yes & Yes \\" _n
file write tfh "Route FE & Yes & Yes & Yes \\" _n
file write tfh "Carrier FE & Yes & Yes & Yes \\" _n
file write tfh "Kleibergen-Paap F & `F1' & `F2' & `F3' \\" _n
file write tfh "R-squared & `R1' & `R2' & `R3' \\" _n
file write tfh "\hline \\[-1.8ex]" _n
file write tfh "\end{tabular}" _n
file write tfh "\begin{tablenotes}[Note]" _n
file write tfh "All specifications are estimated via 2SLS. Fuel growth and its interactions are instrumented with rivals' fuel growth and matching interactions. Column (1) reports baseline fuel-cost pass-through. Column (2) reports high-inflation minus low-inflation pass-through. Column (3) reports high-HHI minus low-HHI pass-through. High inflation is defined as inflation \$>3\%\$; high HHI is defined as HHI \$>2500\$. Controls are income growth and population growth. Route and carrier fixed effects are absorbed. Robust standard errors are in parentheses. Kleibergen-Paap F reports the Kleibergen-Paap rk Wald F statistic when available.\sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." _n
file write tfh "\end{tablenotes}" _n
file write tfh "\end{table}" _n
file close tfh

* Restore the full estimation dataset for later tables.
restore


*=========================================================
* TABLE 5: Dominance and Concentrated Market
*=========================================================

eststo clear

* (1) Share Split -- Dominant (>50%)
ivreghdfe price_growth high_inf ///
    (fuel_growth c.high_inf#c.fuel_growth = ///
     us_jetfuel_growth c.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_share == 1, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store t5_share_hi

* (2) Share Split -- Not Dominant (<=50%)
ivreghdfe price_growth high_inf ///
    (fuel_growth c.high_inf#c.fuel_growth = ///
     us_jetfuel_growth c.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_share == 0, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store t5_share_lo

* (3) Low-share, High HHI
ivreghdfe price_growth high_inf ///
    (fuel_growth c.high_inf#c.fuel_growth = ///
     us_jetfuel_growth c.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_share == 0 & high_hhi == 1, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store t5_losh_hihhi

* (4) Low-share, Low HHI
ivreghdfe price_growth high_inf ///
    (fuel_growth c.high_inf#c.fuel_growth = ///
     us_jetfuel_growth c.high_inf#c.us_jetfuel_growth) ///
    income_growth population_growth ///
    if high_share == 0 & high_hhi == 0, ///
    absorb(route carrier_id) vce(robust) first
add_bottom_panel
estimates store t5_losh_lohhi

esttab t5_share_hi t5_share_lo t5_losh_hihhi t5_losh_lohhi ///
    using "$tabs/table5.tex", replace ///
    fragment label noobs nonotes ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    keep(fuel_growth high_inf c.high_inf#c.fuel_growth) ///
    order(fuel_growth high_inf c.high_inf#c.fuel_growth) ///
    varlabels(fuel_growth "Fuel Growth" ///
              high_inf "High Inflation" ///
              c.high_inf#c.fuel_growth "Fuel Growth \$\times\$ High Inflation") ///
    mgroups("Share Split" "Lo-Share \$\times\$ HHI", ///
            pattern(1 0 1 0) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            span erepeat(\cline{@span})) ///
    mtitles("Hi-Share" "Lo-Share" "Lo-Sh/Hi-HHI" "Lo-Sh/Lo-HHI") ///
    prehead("\begin{table}[p]" ///
            "\centering" ///
            "\caption{Fuel Cost Pass-Through by Market Share and Concentration}" ///
            "\label{tab:dominance_concentration}" ///
            "\scriptsize" ///
            "\setlength{\tabcolsep}{2pt}" ///
            "\renewcommand{\arraystretch}{0.9}" ///
            "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
            "\begin{tabular}{l*{4}{c}}" ///
            "\\[-1.8ex]\hline" ///
            "\hline \\[-1.8ex]") ///
    posthead("\hline \\[-1.8ex]") ///
    prefoot("\hline \\[-1.8ex]") ///
    stats(N controls route_fe carrier_fe firststage r2stat, ///
          labels("Observations" "Controls" "Route FE" "Carrier FE" "Kleibergen-Paap F" "R-squared") ///
          fmt(%9.0fc %9s %9s %9s %9.2f %9.3f)) ///
    postfoot("\hline \\[-1.8ex]" ///
             "\end{tabular}" ///
             "\begin{tablenotes}[Note]" ///
             "All specifications are estimated via 2SLS. Fuel growth and its interaction with high inflation are instrumented with rivals' fuel growth and the corresponding interaction. Columns (1) and (2) split the sample by market-share dominance. Columns (3) and (4) split low-share observations by concentration. High Inflation is defined as inflation \$>3\%\$; High HHI is defined as HHI \$>2500\$; High Share is defined as share \$>50\%\$. HHI is divided by 1000 in the estimation dataset. Controls are income growth and population growth. Route and carrier fixed effects are absorbed. Robust standard errors are in parentheses. Kleibergen-Paap F reports the Kleibergen-Paap rk Wald F statistic when available.\sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
             "\end{tablenotes}" ///
             "\end{table}")

*=========================================================
* WRAP UP
*=========================================================

di _n "============================================================"
di "OUTPUT SAVED TO: $tabs"
di "  table02.tex"
di "  table03.tex"
di "  table04.tex"
di "  table05.tex"
di "Log with first-stage output saved to: $logs/baseline_passthrough.log"
di "============================================================"

log close
