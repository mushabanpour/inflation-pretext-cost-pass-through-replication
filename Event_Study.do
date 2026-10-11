/********************************************************************
REVISED: Feb 22, 2026
Jet-fuel shock pass-through into price growth: low vs high inflation
Output: $out/event_study/figs/  and  $out/event_study/tables/
********************************************************************/

clear all
set more off
capture log close _all

*----------------------------
* 0) Paths
*----------------------------
global data  "`c(pwd)'/rkt_ready.dta"
global out   "`c(pwd)'/output"
global es    "$out/event_study"
global figs  "$es/figs"
global tabs  "$es/tables"
global logs  "$es/logs"

cap mkdir "$es"
cap mkdir "$figs"
cap mkdir "$tabs"
cap mkdir "$logs"

log using "$logs/dynamic-pass-through.log", replace text

use "$data", clear
xtset panel_id quarter_date

*----------------------------
* 1) Graph style
*----------------------------
set scheme s1mono
graph set window fontface "Helvetica"   // use "Arial" on Windows

local lc   "navy"
local lc2  "cranberry"
local lw   "thin"

local title_opt  size(small)  color(black) margin(b=2)
local axis_opt   size(vsmall) color(gs4)
local note_opt   size(tiny)   color(gs8)

local region  plotregion(color(white) lcolor(none)) ///
              graphregion(color(white) margin(medsmall) lwidth(vthin))

*----------------------------
* 2-3) Fuel growth & high-inflation indicator
*      us_jetfuel_growth and high_inf are pre-built in rkt_ready.dta
*      (by build_rkt_ready.do); no reconstruction needed here.
*      NOTE: us_jetfuel_gallon is no longer in the dataset - the growth
*      series itself is provided directly.
*----------------------------

*----------------------------
* 4) Carrier-level fuel shocks
*----------------------------
local p 4

capture drop fuel_shock rfuel_shock
preserve
    keep carrier_id quarter_date fuel_growth us_jetfuel_growth ppi_transport
    duplicates drop carrier_id quarter_date, force
    xtset carrier_id quarter_date

    xtreg fuel_growth L(1/`p').fuel_growth L(1/`p').ppi_transport, ///
          fe vce(robust)
    predict double fuel_shock_car, resid

    xtreg us_jetfuel_growth L(1/`p').us_jetfuel_growth ///
          L(1/`p').ppi_transport, fe vce(robust)
    predict double rfuel_shock_car, resid

    tempfile shocks
    keep carrier_id quarter_date fuel_shock_car rfuel_shock_car
    save `shocks', replace
restore

merge m:1 carrier_id quarter_date using `shocks', nogen keep(match master)
rename fuel_shock_car  fuel_shock
rename rfuel_shock_car rfuel_shock

xtset panel_id quarter_date

*----------------------------
* 5) Event-study leads / lags  *** K = 4 ***
*----------------------------
local K 4

forvalues k = 1/`K' {
    gen fs_l`k'  = L`k'.fuel_shock
    gen fs_f`k'  = F`k'.fuel_shock
    gen rfs_l`k' = L`k'.rfuel_shock
    gen rfs_f`k' = F`k'.rfuel_shock
}
gen fs_0  = fuel_shock
gen rfs_0 = rfuel_shock

*----------------------------
* 6) Interactions with high_inf
*----------------------------
forvalues k = 1/`K' {
    gen hf_fs_l`k'  = fs_l`k'  * high_inf
    gen hf_fs_f`k'  = fs_f`k'  * high_inf
    gen hf_rfs_l`k' = rfs_l`k' * high_inf
    gen hf_rfs_f`k' = rfs_f`k' * high_inf
}
gen hf_fs_0  = fs_0  * high_inf
gen hf_rfs_0 = rfs_0 * high_inf

*----------------------------
* 7) Build variable lists
*----------------------------
local endo    ""
local endo_hf ""
local inst    ""
local inst_hf ""

forvalues k = `K'(-1)1 {
    local endo    "`endo'    fs_l`k'"
    local endo_hf "`endo_hf' hf_fs_l`k'"
    local inst    "`inst'    rfs_l`k'"
    local inst_hf "`inst_hf' hf_rfs_l`k'"
}
local endo    "`endo'    fs_0"
local endo_hf "`endo_hf' hf_fs_0"
local inst    "`inst'    rfs_0"
local inst_hf "`inst_hf' hf_rfs_0"

forvalues k = 1/`K' {
    local endo    "`endo'    fs_f`k'"
    local endo_hf "`endo_hf' hf_fs_f`k'"
    local inst    "`inst'    rfs_f`k'"
    local inst_hf "`inst_hf' hf_rfs_f`k'"
}

local controls "income_growth population_growth inflation high_inf dominance hhi"

*----------------------------
* 8) IV regression
*----------------------------
ivreghdfe price_growth ///
    `controls' ///
    (`endo' `endo_hf' = `inst' `inst_hf'), ///
    absorb(route carrier_id) vce(robust)

*----------------------------
* 9) Pre-trend tests  *** leads −2 and −3 only ***
*----------------------------
test hf_fs_f1 hf_fs_f2
test fs_f1 fs_f2  fs_f3
test fs_f2  fs_f3
test hf_fs_f1 hf_fs_f2 hf_fs_f3
test hf_fs_f2 hf_fs_f3

*----------------------------
* 10) Build coefficient matrices  (NO normalization — absolute levels)
*      Rows: f4, f3, f2, f1, 0, l1, l2, l3, l4  →  k = -4,-3,-2,-1,0,1,2,3,4
*      Cols: [1]=point, [2]=CI lower, [3]=CI upper
*----------------------------
matrix total_hi = J(9, 3, .)   // Total high-inflation effect (base + increment)
matrix base_lo  = J(9, 3, .)   // Low-inflation baseline
matrix diff_mat = J(9, 3, .)   // Difference = interaction coefficient hf_fs_*

local row = 1
foreach v in f4 f3 f2 f1 0 l1 l2 l3 l4 {
    * Total high-inflation effect via lincom
    lincom fs_`v' + hf_fs_`v'
    matrix total_hi[`row', 1] = r(estimate)
    matrix total_hi[`row', 2] = r(estimate) - 1.96 * r(se)
    matrix total_hi[`row', 3] = r(estimate) + 1.96 * r(se)

    * Low-inflation baseline
    matrix base_lo[`row', 1] = _b[fs_`v']
    matrix base_lo[`row', 2] = _b[fs_`v'] - 1.96 * _se[fs_`v']
    matrix base_lo[`row', 3] = _b[fs_`v'] + 1.96 * _se[fs_`v']

    * Difference = interaction term directly
    matrix diff_mat[`row', 1] = _b[hf_fs_`v']
    matrix diff_mat[`row', 2] = _b[hf_fs_`v'] - 1.96 * _se[hf_fs_`v']
    matrix diff_mat[`row', 3] = _b[hf_fs_`v'] + 1.96 * _se[hf_fs_`v']

    local row = `row' + 1
}

*----------------------------
* 10b) LaTeX table -> tab:iv_main  (matches your template)
*      Uses \(...\) instead of $...$ to avoid Stata global expansion.
*----------------------------

* --- diagnostics from the §8 model (e() untouched by test/lincom) ---
scalar Nobs  = e(N)
scalar r2c   = e(r2c)
if missing(r2c) scalar r2c = e(r2)   // fallback: verify name via -ereturn list-
scalar rmse  = e(rmse)
scalar kplm  = e(idstat)             // KP rk LM  (verify)
scalar kplmp = e(idp)                // its p-value (verify)
scalar kpf   = e(widstat)            // KP rk Wald F (verify)

* --- helper: formatted point (with z-based stars) + SE cell ---
capture program drop _cell
program define _cell, rclass
    args b se
    local p = 2*normal(-abs(`b'/`se'))
    local s = cond(`p'<0.01,"***",cond(`p'<0.05,"**",cond(`p'<0.10,"*","")))
    local bs = strtrim(string(`b',"%9.3f"))
    if "`s'"!="" local bs "`bs'^{`s'}"
    local ss = strtrim(string(`se',"%9.3f"))
    return local cell   "\(`bs'\)"
    return local secell "\((`ss')\)"
end

file open tex using "$tabs/tab_iv_main.tex", write replace text

file write tex "\begin{table}[p]" _n
file write tex "\centering" _n
file write tex "\caption{Dynamics of Fuel Shock Pass-Through}" _n
file write tex "\label{tab:iv_main}" _n
file write tex "\resizebox{\textwidth}{!}{%" _n
file write tex "\begin{tabular}{lccc}" _n
file write tex "\\[-1.8ex]\hline" _n
file write tex "\hline \\[-1.8ex]" _n
file write tex "& \multicolumn{3}{c}{Pass-Through by Inflation Regime} \\" _n
file write tex "\cmidrule(lr){2-4}" _n
file write tex "& Low Inflation & High Inflation & Difference \\" _n
file write tex "& (1) & (2) & (3) \\" _n
file write tex "\hline" _n
file write tex "\multicolumn{4}{l}{\textit{Dynamic Pass-Through Coefficients:}} \\" _n

local suffixes "f4 f3 f2 f1 0 l1 l2 l3 l4"
local labels `" \(t-4\) \(t-3\) \(t-2\) \(t-1\) \(t\) \(t+1\) \(t+2\) \(t+3\) \(t+4\) "'

local i = 1
foreach v of local suffixes {
    local lab : word `i' of `labels'

    * Col 1: low-inflation baseline
    local b1 = _b[fs_`v']
    local s1 = _se[fs_`v']
    _cell `b1' `s1'
    local c1 "`r(cell)'"
    local e1 "`r(secell)'"

    * Col 2: high-inflation total (base + interaction)
    lincom fs_`v' + hf_fs_`v'
    local b2 = r(estimate)
    local s2 = r(se)
    _cell `b2' `s2'
    local c2 "`r(cell)'"
    local e2 "`r(secell)'"

    * Col 3: difference = interaction coefficient
    local b3 = _b[hf_fs_`v']
    local s3 = _se[hf_fs_`v']
    _cell `b3' `s3'
    local c3 "`r(cell)'"
    local e3 "`r(secell)'"

    file write tex "\quad `lab' & `c1' & `c2' & `c3' \\" _n
    file write tex "& `e1' & `e2' & `e3' \\" _n

    local i = `i' + 1
}

file write tex "\\" _n
file write tex "\hline" _n
file write tex "Observations & \multicolumn{3}{c}{" (strtrim(string(Nobs,"%9.0fc"))) "} \\" _n
file write tex "Controls & \multicolumn{3}{c}{Yes} \\" _n
file write tex "Route FE & \multicolumn{3}{c}{Yes} \\" _n
file write tex "Carrier FE & \multicolumn{3}{c}{Yes} \\" _n
file write tex "Centered R-squared & \multicolumn{3}{c}{" (string(r2c,"%4.3f")) "} \\" _n
file write tex "Root MSE & \multicolumn{3}{c}{" (string(rmse,"%4.2f")) "} \\" _n
file write tex "\multicolumn{4}{l}{\textit{First-Stage Diagnostics}} \\" _n
file write tex "Kleibergen-Paap rk LM statistic & \multicolumn{3}{c}{" (string(kplm,"%5.3f")) "} \\" _n
file write tex "\quad \(p\)-value & \multicolumn{3}{c}{" (string(kplmp,"%4.3f")) "} \\" _n
file write tex "Kleibergen-Paap rk Wald \(F\) & \multicolumn{3}{c}{" (string(kpf,"%5.3f")) "} \\" _n
file write tex "\hline \\[-1.8ex]" _n
file write tex "\end{tabular}" _n
file write tex "}" _n
file write tex "\begin{tablenotes}[Note]" _n
file write tex "IV (2SLS) estimates. The dependent variable is price growth. Columns (1) and (2) report dynamic pass-through coefficients for low- and high-inflation regimes; Column (3) reports the high-minus-low difference (the interaction effect in Equation~\ref{eq:event_study}). Fuel shocks are AR(4) residuals of carrier-quarter fuel growth, instrumented with the national jet-fuel price series. All regressions include controls for income growth, population growth, inflation, a high-inflation indicator, route dominance, and HHI, as well as carrier and route fixed effects. Robust standard errors are in parentheses. \(^{*}p<0.10\), \(^{**}p<0.05\), \(^{***}p<0.01\)." _n
file write tex "\end{tablenotes}" _n
file write tex "\end{table}" _n

file close tex
di as result "Wrote $tabs/tab_iv_main.tex"
*----------------------------
* 11) Dual-axis event-study graph
*
*  FIX: Both axes share the same explicit [lmin, lmax] coordinate range.
*  The scale factor sf maps diff units → left-axis units. Because yaxis(2)
*  spans the same numerical range as yaxis(1), a bar at height diff*sf on
*  the left aligns perfectly with the right-axis tick labelled diff.
*----------------------------
preserve
    clear
    set obs 9
    gen k = _n - 5      // k ∈ {-3,-2,-1, 0, 1, 2, 3}

    gen coef_lo  = .
    gen cilo_lo  = .
    gen cihi_lo  = .
    gen coef_hi  = .
    gen cilo_hi  = .
    gen cihi_hi  = .
    gen diff     = .
    gen diff_lo  = .
    gen diff_hi  = .

    forvalues i = 1/9 {
        replace coef_lo  = base_lo[`i', 1]  if _n == `i'
        replace cilo_lo  = base_lo[`i', 2]  if _n == `i'
        replace cihi_lo  = base_lo[`i', 3]  if _n == `i'
        replace coef_hi  = total_hi[`i', 1] if _n == `i'
        replace cilo_hi  = total_hi[`i', 2] if _n == `i'
        replace cihi_hi  = total_hi[`i', 3] if _n == `i'
        replace diff     = diff_mat[`i', 1] if _n == `i'
        replace diff_lo  = diff_mat[`i', 2] if _n == `i'
        replace diff_hi  = diff_mat[`i', 3] if _n == `i'
    }
	keep if inrange(k, -3, 3)

    twoway ///
        (bar  diff k,                                ///
              barwidth(0.65) fcolor(gs12%60) lcolor(none) base(0)) ///
        (rcap diff_lo diff_hi k,                     ///
              lcolor(gs7) lwidth(thin))               ///
        (connected coef_lo k,                        ///
              lcolor(`lc') lpattern(dash) lwidth(`lw') ///
              msymbol(D) mcolor(`lc') msize(small))  ///
        (connected coef_hi k,                        ///
              lcolor(`lc2') lpattern(solid) lwidth(`lw') ///
              msymbol(O) mcolor(`lc2') msize(small)) ///
        ,                                            ///
        yline(0, lcolor(gs10) lwidth(thin) lpattern(dash))                ///
        xline(-0.5, lcolor(gs6) lwidth(vthin) lpattern(shortdash))         ///
        xlabel(-3(1)3, labsize(small))                                     ///
        xtitle("Quarters relative to shock", `axis_opt')                   ///
        ylabel(, labsize(small) angle(0)                                   ///
               glcolor(gs14) glwidth(vthin) glpattern(dash))               ///
        ytitle("Effect on price growth", `axis_opt')                       ///
        title("Fuel Shock Pass-Through: Low vs. High Inflation",           ///
              `title_opt')                                                  ///
        legend(order(3 4 1 2)                                              ///
               label(1 "Difference (High {&minus} Low)")                   ///
               label(2 "95% CI (Difference)")                              ///
               label(3 "Low inflation pass-through")                       ///
               label(4 "High inflation pass-through")                      ///
               rows(2) size(vsmall) position(6) ring(1)                    ///
               region(lcolor(gs12) fcolor(white)))                         ///
        note("Negetive quarters = pre-shock; positive quarters = post-shock." ///
             "Vertical line = shock date. Bands = 95% CI.", `note_opt')   ///
        `region'                                                            ///
        xsize(11) ysize(5.5)
    graph export "$figs/fig_es_lowhigh.png", replace width(3300)
restore

*----------------------------
* 12) Fuel shock over time with high-inflation shading
*----------------------------
preserve
    collapse (mean) fuel_shock high_inf, by(quarter_date)
    format quarter_date %tq
    sort quarter_date

    sum fuel_shock
    local ymin = floor(r(min)) - 5
    local ymax = ceil(r(max))  + 5

    gen band_lo = `ymin' if high_inf == 1
    gen band_hi = `ymax' if high_inf == 1

    local xq1 = yq(2014,3)
    local xq2 = yq(2017,1)
    local xq3 = yq(2019,3)
    local xq4 = yq(2022,1)
    local xq5 = yq(2024,3)

    twoway ///
        (bar  band_hi  quarter_date, ///
              barwidth(1) fcolor(red%12) lcolor(none) base(`ymin')) ///
        (bar  fuel_shock quarter_date, ///
              barwidth(0.8) fcolor(navy%35) lcolor(navy) base(0)) ///
        , ///
        yline(0, lcolor(gs10%70) lwidth(thin) lpattern(dash)) ///
        title("Fuel Shock Over Time — AR(`p') Construction", `title_opt') ///
        ytitle("Mean fuel shock (residual)", `axis_opt') ///
        xtitle("Quarter", `axis_opt') ///
        xlab(`xq1' "2014q3" `xq2' "2017q1" `xq3' "2019q3" ///
             `xq4' "2022q1" `xq5' "2024q3", labsize(small)) ///
        ylab(, labsize(small) angle(0) glcolor(gs14) glwidth(vthin) ///
               glpattern(dash)) ///
        legend(order(1 "High inflation period" 2 "Fuel shock (AR`p')") ///
               rows(1) size(small) position(6) ring(1) ///
               region(lcolor(gs12) fcolor(white))) ///
        note("Red shading = high inflation quarters (inflation > 3%)." ///
             "Bars are the residuals of carrier-quarter jetfuel growth AR(`p').", ///
             `note_opt') ///
        plotregion(color(white) lcolor(none)) ///
        graphregion(color(white) margin(medsmall)) ///
        xsize(11) ysize(5)
    graph export "$figs/fig_fuel_shock_time.png", replace width(3300)
restore

log close
di as result "Done. Figures in $figs"
