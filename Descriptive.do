/********************************************************************
AER-style Summary Statistics Table Only
Data: route-carrier-quarter panel

Output:
 - tables/descriptives_table1.tex

Definitions:
 - High inflation = inflation > 3
 - High HHI       = HHI > 2500
 - Dominance      = carrier route share > 50%
********************************************************************/

clear all
set more off
capture log close _all

*----------------------------
* 0) Paths
*----------------------------
global directory "`c(pwd)'"
global data  "$directory/rkt_ready.dta"
global csv   "$directory/T_F41SCHEDULE_P6.csv"  
global out   "$directory/output/descriptives"
global tabs  "$out/tables"
global figs  "$out/figs"

cap mkdir "$directory/output"
cap mkdir "$out"
cap mkdir "$tabs"
cap mkdir "$figs"

use "$data", clear

*----------------------------
* 1) Panel setup
*----------------------------
drop if quarter_date > tq(2024q4)
xtset panel_id quarter_date

*----------------------------
* 2) Core definitions
*----------------------------
assert !missing(price)
assert !missing(fuel_carrier)

capture drop high_inf low_inf
*gen byte high_inf = inflation > 3 if !missing(inflation)
gen byte low_inf  = inflation <= 3 if !missing(inflation)

label var high_inf "High inflation (>3%)"
label var low_inf  "Low inflation (<=3%)"

*----------------------------
* 3) Variable transforms
*----------------------------
capture drop ln_price
gen ln_price = ln(price)

* Share displayed in percentage points
capture drop share_pct
quietly summarize share, meanonly
if r(max) <= 1 {
    gen share_pct = 100 * share
}
else {
    gen share_pct = share
}

* HHI displayed on 0–10,000 scale
capture drop hhi_10000
quietly summarize hhi, meanonly
if r(max) <= 1 {
    gen hhi_10000 = 10000 * hhi
}
else if r(max) <= 100 {
    gen hhi_10000 = 100 * hhi
}
else {
    gen hhi_10000 = hhi
}

* High HHI = HHI > 2500
capture drop high_hhi
gen byte high_hhi = hhi_10000 > 2500 if !missing(hhi_10000)

* Dominance = share > 50%
capture drop dominance
gen byte dominance = share_pct > 50 if !missing(share_pct)

* Revenue in thousands
capture drop revenue_k
gen revenue_k = revenue / 1000

* Population in thousands, robust to whether already scaled
capture drop population_k
quietly summarize population, meanonly
if r(max) > 100000 {
    gen population_k = population / 1000
}
else {
    gen population_k = population
}

* Labels
label var price             "Ticket price (USD)"
label var ln_price          "Log price"
label var price_growth      "Price growth (\%)"
label var fuel_carrier      "Fuel cost (USD/gal)"
label var fuel_growth       "Fuel growth (\%)"
label var inflation         "Inflation"
label var us_jetfuel_price  "Jet fuel price (USD/gal)"
label var us_jetfuel_growth "Jet fuel growth (\%)"
label var ppi_transport     "PPI air transport"

label var share_pct         "Route share (\%)"
label var hhi_10000         "HHI"
label var n_carriers        "No.\ carriers"
label var high_hhi          "High HHI (HHI $>$ 2500)"
label var dominance         "Dominance: share $>$ 50\%"

label var passengers        "Passengers"
label var revenue_k         "Revenue (\$000s)"
label var income            "Median income (\$)"
label var population_k      "Population (000s)"
label var income_growth     "Income growth"
label var population_growth "Population growth"

*----------------------------
* 4) Helper program for one row
*----------------------------
capture program drop write_sum_row
program define write_sum_row
    syntax varname, Label(string) Fmt(string)

    tempname N mean sd p10 p50 p90

    * Full sample
    quietly summarize `varlist', detail
    local N0    : display %12.0fc r(N)
    local mean0 : display `fmt' r(mean)
    local sd0   : display `fmt' r(sd)
    local p100  : display `fmt' r(p10)
    local p500  : display `fmt' r(p50)
    local p900  : display `fmt' r(p90)

    * Low inflation
    quietly summarize `varlist' if high_inf == 0, detail
    local N1    : display %12.0fc r(N)
    local mean1 : display `fmt' r(mean)
    local sd1   : display `fmt' r(sd)
    local p101  : display `fmt' r(p10)
    local p501  : display `fmt' r(p50)
    local p901  : display `fmt' r(p90)

    * High inflation
    quietly summarize `varlist' if high_inf == 1, detail
    local N2    : display %12.0fc r(N)
    local mean2 : display `fmt' r(mean)
    local sd2   : display `fmt' r(sd)
    local p102  : display `fmt' r(p10)
    local p502  : display `fmt' r(p50)
    local p902  : display `fmt' r(p90)

    file write texfile "`label'" ///
        " & `N0' & `mean0' & `sd0' & `p100' & `p500' & `p900'" ///
        " & `N1' & `mean1' & `sd1' & `p101' & `p501' & `p901'" ///
        " & `N2' & `mean2' & `sd2' & `p102' & `p502' & `p902' \\" _n
end

*----------------------------
* 5) Write LaTeX table
*----------------------------
file open texfile using "$tabs/descriptives_table1.tex", write replace text

file write texfile "% Required packages: booktabs, rotating, threeparttable, graphicx" _n
file write texfile "% \usepackage{booktabs,rotating,threeparttable,graphicx}" _n _n

file write texfile "\begin{sidewaystable}[p]" _n
file write texfile "\centering" _n
file write texfile "\begin{threeparttable}" _n
file write texfile "\caption{Summary statistics}" _n
file write texfile "\label{tab:descriptives}" _n
file write texfile "\resizebox{\textwidth}{!}{%" _n
file write texfile "\begin{tabular}{l *{3}{rrrrrr}}" _n
file write texfile "\toprule" _n

file write texfile " & \multicolumn{6}{c}{Full Sample}" ///
                   " & \multicolumn{6}{c}{Low Inflation}" ///
                   " & \multicolumn{6}{c}{High Inflation} \\" _n

file write texfile "\cmidrule(lr){2-7}\cmidrule(lr){8-13}\cmidrule(lr){14-19}" _n

file write texfile " & $N$ & Mean & SD & p10 & p50 & p90" ///
                   " & $N$ & Mean & SD & p10 & p50 & p90" ///
                   " & $N$ & Mean & SD & p10 & p50 & p90 \\" _n

file write texfile "\midrule" _n

* Panel A
file write texfile "\multicolumn{19}{l}{\textit{Panel A: Prices and Costs}} \\" _n
write_sum_row price,        label("Ticket price (USD)")     fmt("%9.2f")
write_sum_row ln_price,     label("Log price")              fmt("%9.2f")
write_sum_row price_growth, label("Price growth (\%)")      fmt("%9.2f")
write_sum_row fuel_carrier, label("Fuel cost (USD/gal)")    fmt("%9.2f")
write_sum_row fuel_growth,  label("Fuel growth (\%)")       fmt("%9.2f")
write_sum_row us_jetfuel_price,  label("Jet fuel price (USD/gal)") fmt("%9.2f")
write_sum_row us_jetfuel_growth, label("Jet fuel growth (\%)")     fmt("%9.2f")
write_sum_row inflation,    label("Inflation")              fmt("%9.2f")
write_sum_row ppi_transport, label("PPI air transport")        fmt("%9.1f")

file write texfile "\midrule" _n

* Panel B
file write texfile "\multicolumn{19}{l}{\textit{Panel B: Market Structure}} \\" _n
write_sum_row share_pct,   label("Route share (\%)")              fmt("%9.2f")
write_sum_row hhi_10000,   label("HHI")                           fmt("%9.1f")
write_sum_row n_carriers,  label("No.\ carriers")                 fmt("%9.2f")
write_sum_row high_hhi,    label("High HHI (HHI $>$ 2500)")       fmt("%9.2f")
write_sum_row dominance,   label("Dominance: share $>$ 50\%")     fmt("%9.2f")

file write texfile "\midrule" _n

* Panel C
file write texfile "\multicolumn{19}{l}{\textit{Panel C: Demand-Side Controls}} \\" _n
write_sum_row passengers,        label("Passengers")             fmt("%9.1f")
write_sum_row revenue_k,         label("Revenue (\$000s)")       fmt("%9.1f")
write_sum_row income,            label("Median income (\$)")     fmt("%9.1f")
write_sum_row population_k,      label("Population (000s)")      fmt("%9.1f")
write_sum_row income_growth,     label("Income growth")          fmt("%9.3f")
write_sum_row population_growth, label("Population growth")      fmt("%9.3f")

file write texfile "\bottomrule" _n
file write texfile "\end{tabular}%" _n
file write texfile "}" _n

file write texfile "\begin{tablenotes}[Note]" _n

file write texfile "Unit of observation is route--carrier--quarter. " ///
                   "High inflation equals one when inflation is greater than 3 percent. " ///
                   "Low inflation equals one when inflation is less than or equal to 3 percent. " ///
                   "High HHI equals one when HHI is greater than 2500. " ///
                   "Dominance equals one when the carrier's route share exceeds 50 percent. " ///
                   "Revenue is in thousands of USD; population is in thousands." _n
file write texfile "\end{tablenotes}" _n

file write texfile "\end{threeparttable}" _n
file write texfile "\end{sidewaystable}" _n

file close texfile

di as result "Done. Summary statistics table written to: $tabs/descriptives_table1.tex"

*----------------------------
* FIGURE: Price distribution by quarter (box-and-whisker)
* Red background band over high-inflation quarters
*----------------------------

preserve

keep price quarter_date inflation
*rename price_growth price
drop if missing(price)

* Per-quarter quartiles
bysort quarter_date: egen p25 = pctile(price), p(25)
bysort quarter_date: egen p50 = pctile(price), p(50)
bysort quarter_date: egen p75 = pctile(price), p(75)

* Tukey whiskers: extreme obs within 1.5*IQR of the box
gen iqr         = p75 - p25
gen upper_fence = p75 + 1.5*iqr
gen lower_fence = p25 - 1.5*iqr

gen tmp_up = price if price <= upper_fence
gen tmp_lo = price if price >= lower_fence
bysort quarter_date: egen upper_whisker = max(tmp_up)
bysort quarter_date: egen lower_whisker = min(tmp_lo)

gen byte high_inf = inflation > 3 if !missing(inflation)

collapse (mean) p25 p50 p75 upper_whisker lower_whisker (max) high_inf, ///
    by(quarter_date)

format quarter_date %tq
sort quarter_date

* Full-height y-range for the shaded band (5% padding)
quietly summarize lower_whisker
local ylo = r(min)
quietly summarize upper_whisker
local yhi = r(max)
local pad = 0.05*(`yhi' - `ylo')
gen ymin = `ylo' - `pad'
gen ymax = `yhi' + `pad'

set scheme s1mono
graph set window fontface "Helvetica"

twoway ///
    (rbar ymin ymax quarter_date if high_inf==1, ///
        barwidth(1) fcolor(red%12) lcolor(none)) ///
    (rcap lower_whisker upper_whisker quarter_date, ///
        lcolor(navy) lwidth(vthin) msize(small)) ///
    (rbar p25 p50 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    (rbar p50 p75 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    , ///
    title("Ticket Price Distribution by Quarter", size(small) color(black)) ///
    ytitle("Ticket price (USD)", size(vsmall) color(gs4)) ///
    xtitle("Quarter", size(vsmall) color(gs4)) ///
    ylabel(, labsize(vsmall) angle(0) glcolor(gs14) glwidth(vthin) glpattern(dash)) ///
    xlabel(, angle(90) labsize(tiny)) ///
    legend(order(1 "High inflation (>3%)") pos(6) rows(1) ///
        region(lcolor(none)) size(vsmall)) ///
    plotregion(color(white) lcolor(none)) ///
    graphregion(color(white) margin(small)) ///
    xsize(11) ysize(4.5) ///
    name(g_box_price, replace) nodraw


restore

*----------------------------
* FIGURE: Jet fuel cost distribution by quarter (box-and-whisker)
* Red background band over high-inflation quarters
*----------------------------

preserve

keep fuel_carrier quarter_date inflation
*rename fuel_growth fuel_carrier
drop if missing(fuel_carrier)
 

* Per-quarter quartiles
bysort quarter_date: egen p25 = pctile(fuel_carrier), p(25)
bysort quarter_date: egen p50 = pctile(fuel_carrier), p(50)
bysort quarter_date: egen p75 = pctile(fuel_carrier), p(75)

* Tukey whiskers: extreme obs within 1.5*IQR of the box
gen iqr         = p75 - p25
gen upper_fence = p75 + 1.5*iqr
gen lower_fence = p25 - 1.5*iqr

gen tmp_up = fuel_carrier if fuel_carrier <= upper_fence
gen tmp_lo = fuel_carrier if fuel_carrier >= lower_fence
bysort quarter_date: egen upper_whisker = max(tmp_up)
bysort quarter_date: egen lower_whisker = min(tmp_lo)

gen byte high_inf = inflation > 3 if !missing(inflation)

collapse (mean) p25 p50 p75 upper_whisker lower_whisker (max) high_inf, ///
    by(quarter_date)

format quarter_date %tq
sort quarter_date

* Full-height y-range for the shaded band (5% padding)
quietly summarize lower_whisker
local ylo = r(min)
quietly summarize upper_whisker
local yhi = r(max)
local pad = 0.05*(`yhi' - `ylo')
gen ymin = `ylo' - `pad'
gen ymax = `yhi' + `pad'

set scheme s1mono
graph set window fontface "Helvetica"

twoway ///
    (rbar ymin ymax quarter_date if high_inf==1, ///
        barwidth(1) fcolor(red%12) lcolor(none)) ///
    (rcap lower_whisker upper_whisker quarter_date, ///
        lcolor(navy) lwidth(vthin) msize(small)) ///
    (rbar p25 p50 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    (rbar p50 p75 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    , ///
    title("Jet Fuel Cost Distribution by Quarter", size(small) color(black)) ///
    ytitle("Fuel cost (USD/gal)", size(vsmall) color(gs4)) ///
    xtitle("Quarter", size(vsmall) color(gs4)) ///
    ylabel(, labsize(vsmall) angle(0) glcolor(gs14) glwidth(vthin) glpattern(dash)) ///
    xlabel(, angle(90) labsize(tiny)) ///
    legend(order(1 "High inflation (>3%)") pos(6) rows(1) ///
        region(lcolor(none)) size(vsmall)) ///
    plotregion(color(white) lcolor(none)) ///
    graphregion(color(white) margin(small)) ///
    xsize(11) ysize(4.5) ///
    name(g_box_fuel, replace) nodraw



*----------------------------
* COMBINE: ticket price (L) + jet fuel (R), side by side
*----------------------------

graph combine g_box_price g_box_fuel, ///
    cols(2) rows(1) iscale(0.85) ///
    graphregion(color(white)) ///
    xsize(6.5) ysize(3.25) ///
    name(g_box_combined, replace)

graph export "$figs/fig_box_combined_price_fuel.png", replace width(2000)

restore

*====================================================================
* FIGURE (appended from fig_box_fuelshare_bycarrier.do):
* Cross-carrier fuel-cost-SHARE distribution by quarter.
* NOTE: this reads the raw BTS P-6 CSV ($csv), not rkt_ready.dta,
* because carrier operating-expense shares are not in the panel.
* Inflation for the shading band is pulled from rkt_ready.dta ($data).
*====================================================================

local show_band 1          // 1 = draw red high-inflation band, 0 = no band

*----------------------------
* 1) Inflation-by-quarter crosswalk (from the panel)
*----------------------------
if `show_band' {
    use "$data", clear
    * inflation is macro -> constant within quarter; mean is safe either way
    collapse (mean) inflation, by(quarter_date)
    tempfile inf_q
    save `inf_q'
}

*----------------------------
* 2) Carrier-quarter fuel share from P-6
*----------------------------
import delimited "$csv", clear varnames(1) case(lower)
destring aircraft_fuel op_expense year quarter, replace force

keep if inlist(unique_carrier,"AA","DL","UA","WN","B6","F9","NK","AS")
keep if inrange(year, 2014, 2024)

* --- Region choice ---------------------------------------------------
* Default = all regions (matches the line-chart pooling).
* For domestic only, UNCOMMENT:
* keep if region == "D"
* --------------------------------------------------------------------

keep if inrange(year,2014,2025)
drop if missing(aircraft_fuel) | missing(op_expense)

* Aggregate across regions FIRST, then form the ratio (one row per carrier-quarter)
collapse (sum) aircraft_fuel op_expense, by(unique_carrier year quarter)
gen fuelshare = 100 * aircraft_fuel / op_expense
label var fuelshare "Fuel as % of operating expense"

gen quarter_date = yq(year, quarter)
format quarter_date %tq

*----------------------------
* 3) Cross-carrier quartiles per quarter + Tukey whiskers
*----------------------------
bysort quarter_date: egen p25 = pctile(fuelshare), p(25)
bysort quarter_date: egen p50 = pctile(fuelshare), p(50)
bysort quarter_date: egen p75 = pctile(fuelshare), p(75)

gen iqr         = p75 - p25
gen upper_fence = p75 + 1.5*iqr
gen lower_fence = p25 - 1.5*iqr

gen tmp_up = fuelshare if fuelshare <= upper_fence
gen tmp_lo = fuelshare if fuelshare >= lower_fence
bysort quarter_date: egen upper_whisker = max(tmp_up)
bysort quarter_date: egen lower_whisker = min(tmp_lo)

*----------------------------
* 4) Attach inflation, define high_inf, collapse to one row per quarter
*----------------------------
if `show_band' {
    merge m:1 quarter_date using `inf_q', keep(master match) nogen
    gen byte high_inf = inflation > 3 if !missing(inflation)
    replace high_inf = 0 if missing(high_inf)
}
else {
    gen byte high_inf = 0
}

collapse (mean) p25 p50 p75 upper_whisker lower_whisker (max) high_inf, ///
    by(quarter_date)

format quarter_date %tq
sort quarter_date

* Full-height band range (5% padding)
quietly summarize lower_whisker
local ylo = r(min)
quietly summarize upper_whisker
local yhi = r(max)
local pad = 0.05*(`yhi' - `ylo')
gen ymin = `ylo' - `pad'
gen ymax = `yhi' + `pad'

*----------------------------
* 5) Plot
*----------------------------
set scheme s1mono
graph set window fontface "Helvetica"

twoway ///
    (rbar ymin ymax quarter_date if high_inf==1, ///
        barwidth(1) fcolor(red%12) lcolor(none)) ///
    (rcap lower_whisker upper_whisker quarter_date, ///
        lcolor(navy) lwidth(vthin) msize(small)) ///
    (rbar p25 p50 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    (rbar p50 p75 quarter_date, ///
        barwidth(0.6) fcolor(navy%35) lcolor(navy) lwidth(vthin)) ///
    , ///
    title("Fuel Cost Share Distribution Across Carriers, by Quarter", ///
        size(small) color(black)) ///
    ytitle("Fuel share of operating expense (%)", size(vsmall) color(gs4)) ///
    xtitle("Quarter", size(vsmall) color(gs4)) ///
    ylabel(, labsize(vsmall) angle(0) glcolor(gs14) glwidth(vthin) glpattern(dash)) ///
    xlabel(, angle(90) labsize(tiny)) ///
    legend(order(1 "High inflation (>3%)") pos(6) rows(1) ///
        region(lcolor(none)) size(vsmall)) ///
    plotregion(color(white) lcolor(none)) ///
    graphregion(color(white) margin(small)) ///
    xsize(11) ysize(4.5) ///
    name(g_box_fuelshare, replace)

graph export "$figs/fig_box_fuelshare_bycarrier.png", replace width(2000)

di as result "Done -> $figs/fig_box_fuelshare_bycarrier.png"
