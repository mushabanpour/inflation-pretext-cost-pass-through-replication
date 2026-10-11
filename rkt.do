cd "$PROJ"
* =====================================================================
* 1. Carrier-specific jet-fuel price  ->  fuel_carrier
* =====================================================================
import delimited "T_F41SCHEDULE_P12A.csv", clear
keep if inrange(year, 2014, 2025)
gen quarter_date = yq(year, quarter)
format quarter_date %tq
rename unique_carrier tkcarrier
keep if inlist(tkcarrier, "UA", "AA", "DL", "WN", "B6", "AS", "F9", "NK")
collapse (sum) sdom_gallons sdom_cost, by(tkcarrier quarter_date)
rename sdom_gallons carrier_fuel_consumption
rename sdom_cost    carrier_fuel_cost
merge 1:m tkcarrier quarter_date using db1b.dta
gen fuel_carrier = carrier_fuel_cost / carrier_fuel_consumption
drop _merge
label variable fuel_carrier "Carrier-quarter specific jetfuel cost per gallon"
la var route        "Market identifier"
la var tkcarrier    "Carrier identifier"
la var quarter_date "Time identifier"
gen share = passengers / total_passengers * 100
la var share "Carrier's market share in each route-quarter"
drop if share < 5
* intermediate fuel components no longer needed
drop carrier_fuel_cost carrier_fuel_consumption

* =====================================================================
* 2. Keep only routes present in every quarter (balanced routes)
* =====================================================================
preserve
    contract route quarter_date
    bysort route: gen n_quarters = _N
    sum n_quarters, meanonly
    local max_n = r(max)
    keep if n_quarters == `max_n'
    keep route
    duplicates drop
    tempfile complete_routes
    save `complete_routes'
restore
merge m:1 route using `complete_routes', keep(match) nogen

* =====================================================================
* 3. Competition and identifier variables
* =====================================================================
gen share_sq = share^2
la var share_sq "Share squared"

bysort route quarter_date: egen hhi = total(share_sq)
la var hhi "Herfindahl-Hirschman Index"

bysort route quarter_date: egen n_carriers = count(tkcarrier)
la var n_carriers "Number of carriers active in each route-quarter"

gen carrier = "."
replace carrier = "United"    if tkcarrier == "UA"
replace carrier = "American"  if tkcarrier == "AA"
replace carrier = "Delta"     if tkcarrier == "DL"
replace carrier = "Southwest" if tkcarrier == "WN"
replace carrier = "JetBlue"   if tkcarrier == "B6"
replace carrier = "Alaska"    if tkcarrier == "AS"
replace carrier = "Frontier"  if tkcarrier == "F9"
replace carrier = "Spirit"    if tkcarrier == "NK"
la var carrier "Carrier's full name"

encode carrier, gen(carrier_id)
la var carrier_id "Carrier's factor variable"

egen panel_id = group(tkcarrier route)
la var panel_id "Route-carrier panel identifier"

gen dominance = (share > 50)
label define dominance_lbl 0 "No Dominance" 1 "Dominance"
label values dominance dominance_lbl
la var dominance "Market share greater than 50%"

* =====================================================================
* 4. Growth variables
* =====================================================================
xtset panel_id quarter_date
gen fuel_growth  = 100 * (fuel_carrier/L4.fuel_carrier - 1) 
gen price_growth = 100 * (price/L4.price - 1)        
la var fuel_growth  "Y-o-Y % change in carrier jetfuel price"
la var price_growth "Y-o-Y % change in fare"

* =====================================================================
* 5. Restrict to the final variable set and save
* =====================================================================
keep  route tkcarrier quarter_date panel_id carrier carrier_id price ///
      share share_sq hhi n_carriers passengers revenue total_passengers ///
      dominance fuel_growth price_growth fuel_carrier
order route tkcarrier quarter_date panel_id carrier carrier_id price ///
      share share_sq hhi n_carriers passengers revenue total_passengers ///
      dominance fuel_growth price_growth fuel_carrier

save rkt.dta, replace
