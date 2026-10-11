/*====================================================================
  run_all.do
  Master pipeline for the airline cost pass-through project.

  Runs the nine component do-files in dependency order:

    RAW      DB1B.do            -> db1b.dta
    SOURCES  macro.do           -> macro.dta
             market.do          -> market.dta
             rkt.do             -> rkt.dta        (needs db1b.dta)
             cost.do            -> cost.dta       (AUXILIARY - see note 4)
    BUILD    build_rkt_ready.do -> rkt_ready.dta  (needs rkt/macro/market)
    ANALYSIS Descriptive.do     -> output/descriptives/...
             Baseline.do        -> output/baseline/...
             Event_Study.do     -> output/event_study/...

  --------------------------------------------------------------------
  HOW TO USE
  --------------------------------------------------------------------
  1. Keep this file, the nine component do-files and the data together
     in one folder.
  2. Set PROJ below to that folder (and DB1B_RAW, FREDKEY, CENSUSKEY
     only if you rebuild those stages).
  3. Use the stage toggles to skip stages you do not need to rebuild
     (e.g. set run_raw = 0 to reuse an existing db1b.dta).
  4. In Stata:  do "run_all.do"

  --------------------------------------------------------------------
  NOTES  
  --------------------------------------------------------------------
  1. PROJ is the only path to set (and DB1B_RAW, for DB1B.do). The
     sub-files read it, or, after a `clear all`, the working directory
     PROJ sets. Run them through this master, not on their own.

  2. Several sub-files run `clear all`, which wipes global macros. That
     is why this master relies on the WORKING DIRECTORY (set once by cd,
     which survives clear all) plus LOCAL toggles, rather than globals,
     to sequence the run.

  3. External requirements (see README for detail):
       - user commands: ivreghdfe, reghdfe, ftools, ivreg2, ranktest,
         estout (esttab/estadd/eststo), getcensus
       - a valid FRED API key (used in macro.do)
       - a valid Census API key (used in market.do via getcensus)
       - the raw DB1B survey files on the external drive (for DB1B.do)
       - internet access (FRED + Census pulls)

====================================================================*/

clear all
set more off
capture log close _all

* If you want to pin a Stata version, uncomment and set to YOUR version:
* version 17

*--------------------------------------------------------------------
* EDIT THIS: folder holding the do-files and the project data
*--------------------------------------------------------------------
global PROJ "/path/to/github_replication"

* raw DB1B Origin and Destination Survey files (only for DB1B.do)
global DB1B_RAW "/path/to/DB1B"

* your own API keys (only for macro.do and market.do)
global FREDKEY   "YOUR_FRED_KEY"
global CENSUSKEY "YOUR_CENSUS_KEY"
cd "$PROJ"

* Master log for the whole run
capture mkdir "$PROJ/output"
capture mkdir "$PROJ/output/logs"
log using "$PROJ/output/logs/run_all_master.log", replace text

*--------------------------------------------------------------------
* STAGE TOGGLES  (1 = run, 0 = skip)
*--------------------------------------------------------------------
local run_raw      0    // DB1B.do   (slow; needs raw O&D tickets and coupons files)
local run_macro    0    // macro.do  (needs FRED key + internet)
local run_market   0    // market.do (needs IPUMS_market.dat, Census key + internet)
local run_rkt      1    // rkt.do    (needs db1b.dta from DB1B.do)
local run_cost     0    // cost.do   (auxiliary; nothing downstream reads cost.dta)
local run_build    1    // build_rkt_ready.do (needs rkt/macro/market .dta)
local run_analysis 1    // Descriptive.do, Baseline.do, Event_Study.do

*--------------------------------------------------------------------
* small helper: announce + time each step
*--------------------------------------------------------------------
capture program drop _runstep
program define _runstep
    args label file
    di as txt _n "{hline 70}"
    di as txt ">>> `label'  (`file')   " c(current_time) " " c(current_date)
    di as txt "{hline 70}"
    do "`file'"
    di as res ">>> DONE: `file'"
end

*====================================================================
* RAW
*====================================================================
if `run_raw' {
    _runstep "RAW: build DB1B panel" "DB1B.do"
}

*====================================================================
* SOURCES
*====================================================================
if `run_macro'  _runstep "SOURCES: national macro" "macro.do"
if `run_market' _runstep "SOURCES: metro income/population" "market.do"
if `run_rkt'    _runstep "SOURCES: route-carrier-quarter panel" "rkt.do"
if `run_cost'   _runstep "SOURCES: carrier fuel-share (auxiliary)" "cost.do"

*====================================================================
* BUILD analysis dataset
*====================================================================
if `run_build' _runstep "BUILD: rkt_ready.dta" "build_rkt_ready.do"

*====================================================================
* ANALYSIS
*====================================================================
if `run_analysis' {
    _runstep "ANALYSIS: descriptives"  "Descriptive.do"
    _runstep "ANALYSIS: baseline IV"   "Baseline.do"
    _runstep "ANALYSIS: event study"   "Event_Study.do"
}

di as res _n "{hline 70}"
di as res "PIPELINE COMPLETE  " c(current_time) " " c(current_date)
di as res "Outputs under: $PROJ/output"
di as res "{hline 70}"

log close _all
