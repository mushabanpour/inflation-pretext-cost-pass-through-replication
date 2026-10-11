cd "$PROJ"
import delimited "T_F41SCHEDULE_P12A.csv", clear 
keep if inrange(year, 2014, 2025)
gen quarter_date = yq(year, quarter)
format quarter_date %tq
rename unique_carrier tkcarrier
keep if inlist(tkcarrier, "UA", "AA", "DL", "WN", "B6", "AS", "F9", "NK")
collapse (sum) sdom_gallons sdom_cost, by(tkcarrier quarter_date)
gen fuel_carrier = sdom_cost / sdom_gallons
label variable fuel_carrier "Carrier-quarter specific jetfuel cost per gallon"
keep tkcarrier quarter_date fuel_carrier
tempfile carrier_fuel
save `carrier_fuel'

import delimited "T_F41SCHEDULE_P6.csv", clear 
keep if inrange(year, 2014, 2025)
gen quarter_date = yq(year, quarter)
format quarter_date %tq
rename unique_carrier tkcarrier
keep if inlist(tkcarrier, "UA", "AA", "DL", "WN", "B6", "AS", "F9", "NK")
keep if region=="D"
collapse (sum) aircraft_fuel op_expense, by(tkcarrier quarter_date)
gen fuelshare = 100 * aircraft_fuel / op_expense
label var fuelshare "Fuel as % of operating expense"
keep tkcarrier quarter_date fuelshare
merge 1:1 tkcarrier quarter_date using "`carrier_fuel'", nogen
egen id = group(tkcarrier)
xtset id quarter_date
gen fuel_growth = 100*(fuel_carrier/l4.fuel_carrier - 1)
save cost.dta, replace
