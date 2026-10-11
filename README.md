# Inflation as a Pretext for Raising Prices: A Test of State-Dependent Cost Pass-Through

Replication package. Muhammad Shabanpour, Northeastern University.

Stata code, the analysis dataset, the intermediate datasets built from public sources, and the
logs and output of the runs behind the article.

## Running it

1. Install the user-written commands: `ssc install ftools`, `reghdfe`, `ivreg2`, `ranktest`,
   `ivreghdfe`, `estout`, and `getcensus`.
2. Open `run_all.do` and set `PROJ` to this folder.
3. In Stata: `do run_all.do`.

With the default stage toggles, `run_all.do` builds the route-carrier-quarter panel from the
included `db1b.dta`, `macro.dta` and `market.dta`, assembles `rkt_ready.dta`, and writes every
table and figure to `output/`. Run the stages through `run_all.do`, not on their own: it sets the
working directory and the globals the sub-files read.

| Stage | Do-file | Output | Default |
|---|---|---|---|
| Raw | `DB1B.do` | `db1b.dta` | off (needs the raw DB1B files) |
| Sources | `macro.do` | `macro.dta` | off (needs a FRED API key) |
| | `market.do` | `market.dta` | off (needs the IPUMS extract and a Census API key) |
| | `rkt.do` | `rkt.dta` | on |
| | `cost.do` | `cost.dta` | off (auxiliary; nothing downstream reads it) |
| Build | `build_rkt_ready.do` | `rkt_ready.dta` | on |
| Analysis | `Descriptive.do`, `Baseline.do`, `Event_Study.do` | `output/` | on |

To rebuild a source stage, switch it on in `run_all.do` and set what it needs there:
`DB1B_RAW` (the folder holding the raw DB1B Coupon and Ticket files), `FREDKEY` or `CENSUSKEY`
(your own keys, from fred.stlouisfed.org and api.census.gov).

## Data

All sources are public.

| Source | Used for | In this package |
|---|---|---|
| Bureau of Transportation Statistics, Airline Origin and Destination Survey (DB1B), Coupon and Ticket, 2014–2025 | fares and passengers by route, carrier and quarter | `db1b.dta` (the collapsed panel); raw files from BTS |
| Bureau of Transportation Statistics, Form 41, Schedules P-6 and P-12A | carrier operating expenses and fuel | `T_F41SCHEDULE_P6.csv`, `T_F41SCHEDULE_P12A.csv` |
| FRED: CPILFESL, MJFUELUSGULF, PCUATRANSATRANS | core inflation, jet fuel prices, air transportation PPI | `macro.dta` |
| American Community Survey, through IPUMS USA and the Census API | metro income and population | `market.dta` (metro-year aggregates) |

`market.do` reads an IPUMS USA extract, `IPUMS_market.dat`, which IPUMS terms do not allow
redistributing. To rebuild it, request an ACS extract from usa.ipums.org with the variables
listed at the top of `market.do` (year, sample, serial, cbserial, hhwt, cluster, met2013,
strata, gq, hhincome, pernum, perwt, inctot).

## Contents

| Path | |
|---|---|
| `run_all.do` | the pipeline, with the stage toggles |
| `DB1B.do`, `macro.do`, `market.do`, `rkt.do`, `cost.do`, `build_rkt_ready.do` | building the data |
| `Descriptive.do`, `Baseline.do`, `Event_Study.do` | the analysis |
| `rkt_ready.dta` | the analysis dataset |
| `output/` | the tables (`.tex`), figures (`.png`) and the log of the full run |
| `logs/` | the logs of the baseline and dynamic pass-through runs |
