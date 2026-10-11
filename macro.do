cd "$PROJ"
set fredkey $FREDKEY, permanently
clear
import fred CPILFESL MJFUELUSGULF PCUATRANSATRANS
gen qaurter_date = qofd(daten)
format %tq qaurter_date
collapse (mean) CPILFESL MJFUELUSGULF PCUATRANSATRANS, by(qaurter_date)
keep if inrange(qaurter_date, tq(2014q1), tq(2025q1))
tsset qaurter_date
sort qaurter_date
gen inflation = 100*(CPILFESL/l4.CPILFESL - 1)
gen us_jetfuel_growth = 100*(MJFUELUSGULF/l4.MJFUELUSGULF - 1)
rename PCUATRANSATRANS ppi_transportation
save macro.dta, replace
