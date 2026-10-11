
// Loop over years from 2014 to 2025
forvalues year = 2014/2025 {
    
    // Loop over the four quarters for Coupon files
    forvalues q = 1/4 {
        import delimited "$DB1B_RAW/Coupon/Origin_and_Destination_Survey_DB1BCoupon_`year'_`q'/Origin_and_Destination_Survey_DB1BCoupon_`year'_`q'.csv", stringcols(1 2)
        keep if inlist(coupons, 1, 2)
        drop if inlist(originstate, "AK", "PR", "TT", "VI", "HI")
		drop if inlist(deststate, "AK", "PR", "TT", "VI", "HI")
        keep if coupontype == "A"
        save "$DB1B_RAW/Coupon/`year'_`q'_coupon.dta", replace
        clear
    }
    
    // Loop over the four quarters for Ticket files
    forvalues q = 1/4 {
        import delimited "$DB1B_RAW/Ticket/Origin_and_Destination_Survey_DB1BTicket_`year'_`q'/Origin_and_Destination_Survey_DB1BTicket_`year'_`q'.csv", stringcols(1)
		drop if inlist(originstate, "AK", "PR", "TT", "VI", "HI")
        drop if bulkfare == 1
		drop if dollarcred == 0
		drop if farepermile > 3.00
		drop if farepermile < 0.013
		drop if itinfare < 25 & roundtrip==0
        keep if inlist(coupons, 1, 2)
        drop if coupons == 2 & roundtrip == 0
        save "$DB1B_RAW/Ticket/`year'_`q'_ticket.dta", replace
        clear
    }
    
    // Append Coupon files for the current year
    use "$DB1B_RAW/Coupon/`year'_1_coupon.dta"
    append using "$DB1B_RAW/Coupon/`year'_2_coupon.dta" "$DB1B_RAW/Coupon/`year'_3_coupon.dta" "$DB1B_RAW/Coupon/`year'_4_coupon.dta"
    preserve
    save "$DB1B_RAW/Coupon/`year'_coupon.dta", replace
    clear
    
    // Append Ticket files for the current year
    use "$DB1B_RAW/Ticket/`year'_1_ticket.dta"
    append using "$DB1B_RAW/Ticket/`year'_2_ticket.dta" "$DB1B_RAW/Ticket/`year'_3_ticket.dta" "$DB1B_RAW/Ticket/`year'_4_ticket.dta"
    save "$DB1B_RAW/Ticket/`year'_ticket.dta", replace
    clear
    restore
    
    // Join Coupon and Ticket data for the current year
    joinby itinid using "$DB1B_RAW/Ticket/`year'_ticket.dta"
    gen price = itinfare / (roundtrip + 1)
    save "$DB1B_RAW/`year'.dta", replace
    clear
}

cd "$DB1B_RAW"

//Loop over years from 2014Q1 to 2025Q1
forvalues year = 2014/2025 {
use `year'.dta, clear
keep if tkcarrier == opcarrier & opcarrier == rpcarrier
gen route = cond(origin < dest, origin + "-" + dest, dest + "-" + origin)
gen quarter_date = yq(year, quarter)
format quarter_date %tq
gen revenue= price * passengers
collapse (sum) passengers revenue, by(route tkcarrier quarter_date)
gen price = revenue / passengers
label variable price "Passenger weighted avg. price"
label variable revenue "Carrier's total revenue in each route-quarter"
label variable passengers "Carrier's total passangers in each route-quarter"
keep if inlist(tkcarrier, "UA", "AA", "DL", "WN", "B6", "AS", "F9", "NK")
drop if passengers < 100
bysort route quarter_date (tkcarrier): egen total_passengers = total(passengers)
label variable total_passengers "Total passengers in each route-carrier-quarter"
drop if total_passengers < 2000
save `year'_rkt.dta, replace
}

* stack them all
use 2014_rkt.dta, clear
forvalues year = 2015/2025 {
    append using `year'_rkt.dta
}
cd "$PROJ"
save db1b.dta, replace






