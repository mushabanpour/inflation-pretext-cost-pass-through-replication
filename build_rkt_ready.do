/********************************************************************
BUILD rkt_ready.dta  -- single input for Baseline.do, Event_Study.do,
and the integrated Descriptive do-file.

Sources (all in $raw):
  rkt.dta     route x carrier x quarter panel  (price, price_growth, fuel_carrier, fuel_growth, share, hhi, ...)
  macro.dta   quarter (national)               (inflation, us_jetfuel_growth, ppi, jetfuel price)  key: qaurter_date
  market.dta  metro x year                     (income/population levels)    key: met2013 year

What this does:
  - merges fuel cost and national macro onto the route-carrier-quarter panel
  - builds route income/population (geo-mean of endpoint metros) + YoY growth
  - consolidates the three carrier identifiers to carrier_id only
  - pre-builds regression transforms (high_inf, high_hhi[>2500], high_share,
    carrier_type); hhi kept on native 0-10000 scale
  - keeps LEVELS alongside growth vars (price, fuel_carrier, us_jetfuel_price,
    income, population) plus n_carriers/passengers/revenue so the descriptive
    table can report both levels and growth. Baseline/Event_Study ignore extras.
********************************************************************/

clear all
set more off

*----------------------------
* 0) Paths  -- point $raw at the folder that holds the four .dta files
*----------------------------
global raw  "`c(pwd)'"
global out  "$raw/rkt_ready.dta"

*----------------------------
* 1) Base panel
*----------------------------
use "$raw/rkt.dta", clear
xtset panel_id quarter_date


*----------------------------
* 2) Quarterly national macro  (rename key qaurter_date -> quarter_date)
*----------------------------
preserve
    use "$raw/macro.dta", clear
    rename qaurter_date quarter_date
    rename ppi_transportation ppi_transport      // used by Event_Study shock model
    rename MJFUELUSGULF us_jetfuel_price          // national jet-fuel price level (USD/gal)
    keep quarter_date inflation us_jetfuel_growth ppi_transport us_jetfuel_price
    tempfile macro
    save `macro'
restore
merge m:1 quarter_date using `macro', keep(match master) nogen

*----------------------------
* 3) income_growth & population_growth  (from market.dta = met2013 x year)
*    Method (per your spec):
*      income     = ipums_hhincome ;  population = acs_population
*      route value = geometric mean of the two endpoint metros: sqrt(left*right)
*      growth     = YoY, ((x - L4.x)/L4.x)*100  (L4 = 4 quarters; quarter_date is %tq)
*    Airports are mapped to CBSA codes, so the merge is on numeric (met2013, year).
*----------------------------
* 3a) Split route "ORIG-DEST" into endpoint airports
gen str3 left_ap  = substr(route, 1, strpos(route, "-") - 1)
gen str3 right_ap = substr(route, strpos(route, "-") + 1, .)

* 3b) Airport -> CBSA (met2013) crosswalk  [28 airports -> 24 metros]
tempfile xwalk
preserve
    clear
    input str3 ap long cbsa
    "ATL" 12060
    "AUS" 12420
    "BOS" 14460
    "BWI" 12580
    "CLE" 17460
    "DCA" 47900
    "DEN" 19740
    "DFW" 19100
    "DTW" 19820
    "EWR" 35620
    "FLL" 33100
    "JFK" 35620
    "LAS" 29820
    "LAX" 31080
    "LGA" 35620
    "MCO" 36740
    "MDW" 16980
    "MIA" 33100
    "MSP" 33460
    "ORD" 16980
    "PHL" 37980
    "PHX" 38060
    "SAN" 41740
    "SEA" 42660
    "SFO" 41860
    "SLC" 41620
    "SMF" 40900
    "TPA" 45300
    end
    save `xwalk'
restore

gen ap = left_ap
merge m:1 ap using `xwalk', keep(master match) nogen
rename cbsa left_met
drop ap

gen ap = right_ap
merge m:1 ap using `xwalk', keep(master match) nogen
rename cbsa right_met
drop ap

* Fail loudly if any airport did not map
assert !missing(left_met) & !missing(right_met)

* 3c) Calendar year from the quarterly date (for the metro-year merge)
gen int year = year(dofq(quarter_date))

* 3d) Endpoint metro income (ipums_hhincome) and population (acs_population)
*     market.dta is met2013 x year; merge once per endpoint.
preserve
    use "$raw/market.dta", clear
    keep met2013 year ipums_hhincome acs_population
    * The 2020 ACS 1-year has no acs_population. Interpolate it within each metro
    * from 2019 and 2021 so YoY (L4) growth is defined for BOTH 2020 and 2021 -
    * otherwise the single 2020 hole also knocks out 2021 (its L4 base).
    tsset met2013 year
    replace acs_population = (L.acs_population + F.acs_population)/2 ///
        if year == 2020 & missing(acs_population)
    tempfile mkt
    save `mkt'
restore

* left endpoint
rename (left_met) (met2013)
merge m:1 met2013 year using `mkt', keep(master match) nogen
rename (met2013 ipums_hhincome acs_population) (left_met left_income left_pop)

* right endpoint
rename (right_met) (met2013)
merge m:1 met2013 year using `mkt', keep(master match) nogen
rename (met2013 ipums_hhincome acs_population) (right_met right_income right_pop)

* 3e) Geometric mean of the two endpoints, then YoY (L4) growth
gen double income     = sqrt(left_income * right_income)
gen double population = sqrt(left_pop    * right_pop)

xtset panel_id quarter_date
gen income_growth     = ((income     - L4.income)     / L4.income)     * 100
gen population_growth = ((population - L4.population) / L4.population) * 100
label var income_growth     "Route income growth (geo-mean endpoints, YoY %)"
label var population_growth "Route population growth (geo-mean endpoints, YoY %)"

drop left_ap right_ap left_met right_met left_income right_income ///
     left_pop right_pop year
label var income     "Route income level (geo-mean of endpoint ipums_hhincome, USD)"
label var population "Route population level (geo-mean of endpoint acs_population)"


*----------------------------
* 4) Regression-ready transforms
*----------------------------
xtset panel_id quarter_date

* High inflation (>3%)
gen byte high_inf = (inflation > 3) if !missing(inflation)
label var high_inf "High Inflation (>3%)"

* HHI: keep the native 0-10000 scale (Descriptive reconstructs on this scale,
* Event_Study uses it as a continuous control). Indicator at 2500 is identical
* to the old (hhi/1000 > 2.5) split, so Baseline's high_hhi is unchanged.
label var hhi "HHI (0-10000)"
gen byte high_hhi = (hhi > 2500) if !missing(hhi)
label var high_hhi "High HHI (>2500)"

* High market share (>50%)
gen byte high_share = (share > 50) if !missing(share)
label var high_share "High Market Share (>50%)"

* Carrier technology type from carrier_id
*   1 Alaska  2 American  3 Delta  4 Frontier  5 JetBlue  6 Southwest  7 Spirit  8 United
gen byte LCC    = inlist(carrier_id, 5, 6)
gen byte ULCC   = inlist(carrier_id, 4, 7)
gen byte Legacy = (LCC == 0 & ULCC == 0)
gen byte carrier_type = cond(Legacy==1, 1, cond(LCC==1, 2, 3))
label define carrier_type_lbl 1 "Legacy" 2 "LCC" 3 "ULCC", replace
label values carrier_type carrier_type_lbl
label var carrier_type "Carrier technology type"
drop LCC ULCC Legacy

*----------------------------
* 5) union of what Baseline, Event_Study, and Descriptive use
*    (regression vars + levels for descriptives); drop everything else
*----------------------------
keep  panel_id tkcarrier route carrier_id quarter_date ///
      price price_growth ///
      fuel_carrier fuel_growth us_jetfuel_price us_jetfuel_growth ///
      income income_growth population population_growth ///
      inflation high_inf hhi high_hhi share high_share dominance ///
      n_carriers passengers revenue carrier_type ppi_transport

order panel_id route carrier_id quarter_date ///
      price price_growth ///
      fuel_carrier fuel_growth us_jetfuel_price us_jetfuel_growth ///
      income income_growth population population_growth ///
      inflation high_inf hhi high_hhi share high_share dominance ///
      n_carriers passengers revenue carrier_type ppi_transport

*----------------------------
* 6) Save
*----------------------------
xtset panel_id quarter_date
compress
save "$out", replace

di as result "Saved: $out"
describe
