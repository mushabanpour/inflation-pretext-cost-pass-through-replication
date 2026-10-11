* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

cd "$PROJ"
global censuskey "$CENSUSKEY"
set more off
clear
quietly infix                ///
  int     year      1-4      ///
  long    sample    5-10     ///
  double  serial    11-18    ///
  double  cbserial  19-31    ///
  double  hhwt      32-41    ///
  double  cluster   42-54    ///
  long    met2013   55-59    ///
  double  strata    60-71    ///
  byte    gq        72-72    ///
  long    hhincome  73-79    ///
  int     pernum    80-83    ///
  double  perwt     84-93    ///
  long    inctot    94-100   ///
  using `"IPUMS_market.dat"'

replace hhwt     = hhwt     / 100
replace perwt    = perwt    / 100

format serial   %8.0f
format cbserial %13.0f
format hhwt     %10.2f
format cluster  %13.0f
format strata   %12.0f
format perwt    %10.2f

label var year     `"Census year"'
label var sample   `"IPUMS sample identifier"'
label var serial   `"Household serial number"'
label var cbserial `"Original Census Bureau household serial number"'
label var hhwt     `"Household weight"'
label var cluster  `"Household cluster for variance estimation"'
label var met2013  `"Metropolitan area (2013 delineations, identifiable areas only)"'
label var strata   `"Household strata for variance estimation"'
label var gq       `"Group quarters status"'
label var hhincome `"Total household income "'
label var pernum   `"Person number in sample unit"'
label var perwt    `"Person weight"'
label var inctot   `"Total personal income"'

label define year_lbl 1850 `"1850"'
label define year_lbl 1860 `"1860"', add
label define year_lbl 1870 `"1870"', add
label define year_lbl 1880 `"1880"', add
label define year_lbl 1900 `"1900"', add
label define year_lbl 1910 `"1910"', add
label define year_lbl 1920 `"1920"', add
label define year_lbl 1930 `"1930"', add
label define year_lbl 1940 `"1940"', add
label define year_lbl 1950 `"1950"', add
label define year_lbl 1960 `"1960"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label define year_lbl 2012 `"2012"', add
label define year_lbl 2013 `"2013"', add
label define year_lbl 2014 `"2014"', add
label define year_lbl 2015 `"2015"', add
label define year_lbl 2016 `"2016"', add
label define year_lbl 2017 `"2017"', add
label define year_lbl 2018 `"2018"', add
label define year_lbl 2019 `"2019"', add
label define year_lbl 2020 `"2020"', add
label define year_lbl 2021 `"2021"', add
label define year_lbl 2022 `"2022"', add
label define year_lbl 2023 `"2023"', add
label define year_lbl 2024 `"2024"', add
label values year year_lbl

label define sample_lbl 202404 `"2020-2024, PRCS 5-year"'
label define sample_lbl 202403 `"2020-2024, ACS 5-year"', add
label define sample_lbl 202402 `"2024 PRCS"', add
label define sample_lbl 202401 `"2024 ACS"', add
label define sample_lbl 202304 `"2019-2023, PRCS 5-year"', add
label define sample_lbl 202303 `"2019-2023, ACS 5-year"', add
label define sample_lbl 202302 `"2023 PRCS"', add
label define sample_lbl 202301 `"2023 ACS"', add
label define sample_lbl 202204 `"2018-2022, PRCS 5-year"', add
label define sample_lbl 202203 `"2018-2022, ACS 5-year"', add
label define sample_lbl 202202 `"2022 PRCS"', add
label define sample_lbl 202201 `"2022 ACS"', add
label define sample_lbl 202104 `"2017-2021, PRCS 5-year"', add
label define sample_lbl 202103 `"2017-2021, ACS 5-year"', add
label define sample_lbl 202102 `"2021 PRCS"', add
label define sample_lbl 202101 `"2021 ACS"', add
label define sample_lbl 202004 `"2016-2020, PRCS 5-year"', add
label define sample_lbl 202003 `"2016-2020, ACS 5-year"', add
label define sample_lbl 202001 `"2020 ACS"', add
label define sample_lbl 201904 `"2015-2019, PRCS 5-year"', add
label define sample_lbl 201903 `"2015-2019, ACS 5-year"', add
label define sample_lbl 201902 `"2019 PRCS"', add
label define sample_lbl 201901 `"2019 ACS"', add
label define sample_lbl 201804 `"2014-2018, PRCS 5-year"', add
label define sample_lbl 201803 `"2014-2018, ACS 5-year"', add
label define sample_lbl 201802 `"2018 PRCS"', add
label define sample_lbl 201801 `"2018 ACS"', add
label define sample_lbl 201704 `"2013-2017, PRCS 5-year"', add
label define sample_lbl 201703 `"2013-2017, ACS 5-year"', add
label define sample_lbl 201702 `"2017 PRCS"', add
label define sample_lbl 201701 `"2017 ACS"', add
label define sample_lbl 201604 `"2012-2016, PRCS 5-year"', add
label define sample_lbl 201603 `"2012-2016, ACS 5-year"', add
label define sample_lbl 201602 `"2016 PRCS"', add
label define sample_lbl 201601 `"2016 ACS"', add
label define sample_lbl 201504 `"2011-2015, PRCS 5-year"', add
label define sample_lbl 201503 `"2011-2015, ACS 5-year"', add
label define sample_lbl 201502 `"2015 PRCS"', add
label define sample_lbl 201501 `"2015 ACS"', add
label define sample_lbl 201404 `"2010-2014, PRCS 5-year"', add
label define sample_lbl 201403 `"2010-2014, ACS 5-year"', add
label define sample_lbl 201402 `"2014 PRCS"', add
label define sample_lbl 201401 `"2014 ACS"', add
label define sample_lbl 201306 `"2009-2013, PRCS 5-year"', add
label define sample_lbl 201305 `"2009-2013, ACS 5-year"', add
label define sample_lbl 201304 `"2011-2013, PRCS 3-year"', add
label define sample_lbl 201303 `"2011-2013, ACS 3-year"', add
label define sample_lbl 201302 `"2013 PRCS"', add
label define sample_lbl 201301 `"2013 ACS"', add
label define sample_lbl 201206 `"2008-2012, PRCS 5-year"', add
label define sample_lbl 201205 `"2008-2012, ACS 5-year"', add
label define sample_lbl 201204 `"2010-2012, PRCS 3-year"', add
label define sample_lbl 201203 `"2010-2012, ACS 3-year"', add
label define sample_lbl 201202 `"2012 PRCS"', add
label define sample_lbl 201201 `"2012 ACS"', add
label define sample_lbl 201106 `"2007-2011, PRCS 5-year"', add
label define sample_lbl 201105 `"2007-2011, ACS 5-year"', add
label define sample_lbl 201104 `"2009-2011, PRCS 3-year"', add
label define sample_lbl 201103 `"2009-2011, ACS 3-year"', add
label define sample_lbl 201102 `"2011 PRCS"', add
label define sample_lbl 201101 `"2011 ACS"', add
label define sample_lbl 201008 `"2010 Puerto Rico 10%"', add
label define sample_lbl 201007 `"2010 10%"', add
label define sample_lbl 201006 `"2006-2010, PRCS 5-year"', add
label define sample_lbl 201005 `"2006-2010, ACS 5-year"', add
label define sample_lbl 201004 `"2008-2010, PRCS 3-year"', add
label define sample_lbl 201003 `"2008-2010, ACS 3-year"', add
label define sample_lbl 201002 `"2010 PRCS"', add
label define sample_lbl 201001 `"2010 ACS"', add
label define sample_lbl 200906 `"2005-2009, PRCS 5-year"', add
label define sample_lbl 200905 `"2005-2009, ACS 5-year"', add
label define sample_lbl 200904 `"2007-2009, PRCS 3-year"', add
label define sample_lbl 200903 `"2007-2009, ACS 3-year"', add
label define sample_lbl 200902 `"2009 PRCS"', add
label define sample_lbl 200901 `"2009 ACS"', add
label define sample_lbl 200804 `"2006-2008, PRCS 3-year"', add
label define sample_lbl 200803 `"2006-2008, ACS 3-year"', add
label define sample_lbl 200802 `"2008 PRCS"', add
label define sample_lbl 200801 `"2008 ACS"', add
label define sample_lbl 200704 `"2005-2007, PRCS 3-year"', add
label define sample_lbl 200703 `"2005-2007, ACS 3-year"', add
label define sample_lbl 200702 `"2007 PRCS"', add
label define sample_lbl 200701 `"2007 ACS"', add
label define sample_lbl 200602 `"2006 PRCS"', add
label define sample_lbl 200601 `"2006 ACS"', add
label define sample_lbl 200502 `"2005 PRCS"', add
label define sample_lbl 200501 `"2005 ACS"', add
label define sample_lbl 200401 `"2004 ACS"', add
label define sample_lbl 200301 `"2003 ACS"', add
label define sample_lbl 200201 `"2002 ACS"', add
label define sample_lbl 200101 `"2001 ACS"', add
label define sample_lbl 200008 `"2000 Puerto Rico 1%"', add
label define sample_lbl 200007 `"2000 1%"', add
label define sample_lbl 200006 `"2000 Puerto Rico 1% sample (old version)"', add
label define sample_lbl 200005 `"2000 Puerto Rico 5%"', add
label define sample_lbl 200004 `"2000 ACS"', add
label define sample_lbl 200003 `"2000 Unweighted 1%"', add
label define sample_lbl 200002 `"2000 1% sample (old version)"', add
label define sample_lbl 200001 `"2000 5%"', add
label define sample_lbl 199007 `"1990 Puerto Rico 1%"', add
label define sample_lbl 199006 `"1990 Puerto Rico 5%"', add
label define sample_lbl 199005 `"1990 Labor Market Area"', add
label define sample_lbl 199004 `"1990 Elderly"', add
label define sample_lbl 199003 `"1990 Unweighted 1%"', add
label define sample_lbl 199002 `"1990 1%"', add
label define sample_lbl 199001 `"1990 5%"', add
label define sample_lbl 198007 `"1980 Puerto Rico 1%"', add
label define sample_lbl 198006 `"1980 Puerto Rico 5%"', add
label define sample_lbl 198005 `"1980 Detailed metro/non-metro"', add
label define sample_lbl 198004 `"1980 Labor Market Area"', add
label define sample_lbl 198003 `"1980 Urban/Rural"', add
label define sample_lbl 198002 `"1980 1%"', add
label define sample_lbl 198001 `"1980 5%"', add
label define sample_lbl 197009 `"1970 Puerto Rico Neighborhood"', add
label define sample_lbl 197008 `"1970 Puerto Rico Municipio"', add
label define sample_lbl 197007 `"1970 Puerto Rico State"', add
label define sample_lbl 197006 `"1970 Form 2 Neighborhood"', add
label define sample_lbl 197005 `"1970 Form 1 Neighborhood"', add
label define sample_lbl 197004 `"1970 Form 2 Metro"', add
label define sample_lbl 197003 `"1970 Form 1 Metro"', add
label define sample_lbl 197002 `"1970 Form 2 State"', add
label define sample_lbl 197001 `"1970 Form 1 State"', add
label define sample_lbl 196002 `"1960 5%"', add
label define sample_lbl 196001 `"1960 1%"', add
label define sample_lbl 195002 `"1950 100% database"', add
label define sample_lbl 195001 `"1950 1%"', add
label define sample_lbl 194002 `"1940 100% database"', add
label define sample_lbl 194001 `"1940 1%"', add
label define sample_lbl 193004 `"1930 100% database"', add
label define sample_lbl 193003 `"1930 Puerto Rico"', add
label define sample_lbl 193002 `"1930 5%"', add
label define sample_lbl 193001 `"1930 1%"', add
label define sample_lbl 192003 `"1920 100% database"', add
label define sample_lbl 192002 `"1920 Puerto Rico sample"', add
label define sample_lbl 192001 `"1920 1%"', add
label define sample_lbl 191004 `"1910 100% database"', add
label define sample_lbl 191003 `"1910 1.4% sample with oversamples"', add
label define sample_lbl 191002 `"1910 1%"', add
label define sample_lbl 191001 `"1910 Puerto Rico"', add
label define sample_lbl 190004 `"1900 100% database"', add
label define sample_lbl 190003 `"1900 1% sample with oversamples"', add
label define sample_lbl 190002 `"1900 1%"', add
label define sample_lbl 190001 `"1900 5%"', add
label define sample_lbl 188003 `"1880 100% database"', add
label define sample_lbl 188002 `"1880 10%"', add
label define sample_lbl 188001 `"1880 1%"', add
label define sample_lbl 187003 `"1870 100% database"', add
label define sample_lbl 187002 `"1870 1% sample with black oversample"', add
label define sample_lbl 187001 `"1870 1%"', add
label define sample_lbl 186003 `"1860 100% database"', add
label define sample_lbl 186002 `"1860 1% sample with black oversample"', add
label define sample_lbl 186001 `"1860 1%"', add
label define sample_lbl 185002 `"1850 100% database"', add
label define sample_lbl 185001 `"1850 1%"', add
label values sample sample_lbl

label define met2013_lbl 00000 `"Not in identifiable area"'
label define met2013_lbl 10420 `"Akron, OH"', add
label define met2013_lbl 10540 `"Albany, OR"', add
label define met2013_lbl 10580 `"Albany-Schenectady-Troy, NY"', add
label define met2013_lbl 10740 `"Albuquerque, NM"', add
label define met2013_lbl 10780 `"Alexandria, LA"', add
label define met2013_lbl 10900 `"Allentown-Bethlehem-Easton, PA-NJ"', add
label define met2013_lbl 11020 `"Altoona, PA"', add
label define met2013_lbl 11100 `"Amarillo, TX"', add
label define met2013_lbl 11260 `"Anchorage, AK"', add
label define met2013_lbl 11460 `"Ann Arbor, MI"', add
label define met2013_lbl 11500 `"Anniston-Oxford-Jacksonville, AL"', add
label define met2013_lbl 11700 `"Asheville, NC"', add
label define met2013_lbl 12020 `"Athens-Clarke County, GA"', add
label define met2013_lbl 12060 `"Atlanta-Sandy Springs-Roswell, GA"', add
label define met2013_lbl 12100 `"Atlantic City-Hammonton, NJ"', add
label define met2013_lbl 12220 `"Auburn-Opelika, AL"', add
label define met2013_lbl 12260 `"Augusta-Richmond County, GA-SC"', add
label define met2013_lbl 12420 `"Austin-Round Rock, TX"', add
label define met2013_lbl 12540 `"Bakersfield, CA"', add
label define met2013_lbl 12580 `"Baltimore-Columbia-Towson, MD"', add
label define met2013_lbl 12620 `"Bangor, ME"', add
label define met2013_lbl 12700 `"Barnstable Town, MA"', add
label define met2013_lbl 12940 `"Baton Rouge, LA"', add
label define met2013_lbl 12980 `"Battle Creek, MI"', add
label define met2013_lbl 13140 `"Beaumont-Port Arthur, TX"', add
label define met2013_lbl 13220 `"Beckley, WV"', add
label define met2013_lbl 13380 `"Bellingham, WA"', add
label define met2013_lbl 13460 `"Bend-Redmond, OR"', add
label define met2013_lbl 13740 `"Billings, MT"', add
label define met2013_lbl 13780 `"Binghamton, NY"', add
label define met2013_lbl 13820 `"Birmingham-Hoover, AL"', add
label define met2013_lbl 13900 `"Bismarck, ND"', add
label define met2013_lbl 13980 `"Blacksburg-Christiansburg-Radford, VA"', add
label define met2013_lbl 14010 `"Bloomington, IL"', add
label define met2013_lbl 14020 `"Bloomington, IN"', add
label define met2013_lbl 14260 `"Boise City, ID"', add
label define met2013_lbl 14460 `"Boston-Cambridge-Newton, MA-NH"', add
label define met2013_lbl 14740 `"Bremerton-Silverdale, WA"', add
label define met2013_lbl 14860 `"Bridgeport-Stamford-Norwalk, CT"', add
label define met2013_lbl 15180 `"Brownsville-Harlingen, TX"', add
label define met2013_lbl 15380 `"Buffalo-Cheektowaga-Niagara Falls, NY"', add
label define met2013_lbl 15500 `"Burlington, NC"', add
label define met2013_lbl 15540 `"Burlington-South Burlington, VT"', add
label define met2013_lbl 15680 `"California-Lexington Park, MD"', add
label define met2013_lbl 15940 `"Canton-Massillon, OH"', add
label define met2013_lbl 15980 `"Cape Coral-Fort Myers, FL"', add
label define met2013_lbl 16580 `"Champaign-Urbana, IL"', add
label define met2013_lbl 16620 `"Charleston, WV"', add
label define met2013_lbl 16700 `"Charleston-North Charleston, SC"', add
label define met2013_lbl 16740 `"Charlotte-Concord-Gastonia, NC-SC"', add
label define met2013_lbl 16820 `"Charlottesville, VA"', add
label define met2013_lbl 16860 `"Chattanooga, TN-GA"', add
label define met2013_lbl 16940 `"Cheyenne, WY"', add
label define met2013_lbl 16980 `"Chicago-Naperville-Elgin, IL-IN-WI"', add
label define met2013_lbl 17020 `"Chico, CA"', add
label define met2013_lbl 17140 `"Cincinnati, OH-KY-IN"', add
label define met2013_lbl 17300 `"Clarksville, TN-KY"', add
label define met2013_lbl 17420 `"Cleveland, TN"', add
label define met2013_lbl 17460 `"Cleveland-Elyria, OH"', add
label define met2013_lbl 17660 `"Coeur d'Alene, ID"', add
label define met2013_lbl 17780 `"College Station-Bryan, TX"', add
label define met2013_lbl 17820 `"Colorado Springs, CO"', add
label define met2013_lbl 17860 `"Columbia, MO"', add
label define met2013_lbl 17900 `"Columbia, SC"', add
label define met2013_lbl 18140 `"Columbus, OH"', add
label define met2013_lbl 18580 `"Corpus Christi, TX"', add
label define met2013_lbl 18700 `"Corvallis, OR"', add
label define met2013_lbl 18880 `"Crestview-Fort Walton Beach-Destin, FL"', add
label define met2013_lbl 19100 `"Dallas-Fort Worth-Arlington, TX"', add
label define met2013_lbl 19300 `"Daphne-Fairhope-Foley, AL"', add
label define met2013_lbl 19340 `"Davenport-Moline-Rock Island, IA-IL"', add
label define met2013_lbl 19380 `"Dayton, OH"', add
label define met2013_lbl 19460 `"Decatur, AL"', add
label define met2013_lbl 19500 `"Decatur, IL"', add
label define met2013_lbl 19660 `"Deltona-Daytona Beach-Ormond Beach, FL"', add
label define met2013_lbl 19740 `"Denver-Aurora-Lakewood, CO"', add
label define met2013_lbl 19780 `"Des Moines-West Des Moines, IA"', add
label define met2013_lbl 19820 `"Detroit-Warren-Dearborn, MI"', add
label define met2013_lbl 20020 `"Dothan, AL"', add
label define met2013_lbl 20100 `"Dover, DE"', add
label define met2013_lbl 20500 `"Durham-Chapel Hill, NC"', add
label define met2013_lbl 20700 `"East Stroudsburg, PA"', add
label define met2013_lbl 20740 `"Eau Claire, WI"', add
label define met2013_lbl 20940 `"El Centro, CA"', add
label define met2013_lbl 21060 `"Elizabethtown-Fort Knox, KY"', add
label define met2013_lbl 21140 `"Elkhart-Goshen, IN"', add
label define met2013_lbl 21340 `"El Paso, TX"', add
label define met2013_lbl 21500 `"Erie, PA"', add
label define met2013_lbl 21660 `"Eugene, OR"', add
label define met2013_lbl 21780 `"Evansville, IN-KY"', add
label define met2013_lbl 22140 `"Farmington, NM"', add
label define met2013_lbl 22180 `"Fayetteville, NC"', add
label define met2013_lbl 22220 `"Fayetteville-Springdale-Rogers, AR-MO"', add
label define met2013_lbl 22380 `"Flagstaff, AZ"', add
label define met2013_lbl 22420 `"Flint, MI"', add
label define met2013_lbl 22500 `"Florence, SC"', add
label define met2013_lbl 22520 `"Florence-Muscle Shoals, AL"', add
label define met2013_lbl 22660 `"Fort Collins, CO"', add
label define met2013_lbl 23060 `"Fort Wayne, IN"', add
label define met2013_lbl 23420 `"Fresno, CA"', add
label define met2013_lbl 23460 `"Gadsden, AL"', add
label define met2013_lbl 23540 `"Gainesville, FL"', add
label define met2013_lbl 23580 `"Gainesville, GA"', add
label define met2013_lbl 24020 `"Glens Falls, NY"', add
label define met2013_lbl 24140 `"Goldsboro, NC"', add
label define met2013_lbl 24300 `"Grand Junction, CO"', add
label define met2013_lbl 24340 `"Grand Rapids-Wyoming, MI"', add
label define met2013_lbl 24540 `"Greeley, CO"', add
label define met2013_lbl 24660 `"Greensboro-High Point, NC"', add
label define met2013_lbl 24780 `"Greenville, NC"', add
label define met2013_lbl 24860 `"Greenville-Anderson-Mauldin, SC"', add
label define met2013_lbl 25060 `"Gulfport-Biloxi-Pascagoula, MS"', add
label define met2013_lbl 25220 `"Hammond, LA"', add
label define met2013_lbl 25260 `"Hanford-Corcoran, CA"', add
label define met2013_lbl 25420 `"Harrisburg-Carlisle, PA"', add
label define met2013_lbl 25500 `"Harrisonburg, VA"', add
label define met2013_lbl 25540 `"Hartford-West Hartford-East Hartford, CT"', add
label define met2013_lbl 25620 `"Hattiesburg, MS"', add
label define met2013_lbl 25860 `"Hickory-Lenoir-Morganton, NC"', add
label define met2013_lbl 25940 `"Hilton Head Island-Bluffton-Beaufort, SC"', add
label define met2013_lbl 26140 `"Homosassa Springs, FL"', add
label define met2013_lbl 26380 `"Houma-Thibodaux, LA"', add
label define met2013_lbl 26420 `"Houston-The Woodlands-Sugar Land, TX"', add
label define met2013_lbl 26620 `"Huntsville, AL"', add
label define met2013_lbl 26900 `"Indianapolis-Carmel-Anderson, IN"', add
label define met2013_lbl 26980 `"Iowa City, IA"', add
label define met2013_lbl 27060 `"Ithaca, NY"', add
label define met2013_lbl 27100 `"Jackson, MI"', add
label define met2013_lbl 27140 `"Jackson, MS"', add
label define met2013_lbl 27180 `"Jackson, TN"', add
label define met2013_lbl 27260 `"Jacksonville, FL"', add
label define met2013_lbl 27340 `"Jacksonville, NC"', add
label define met2013_lbl 27500 `"Janesville-Beloit, WI"', add
label define met2013_lbl 27620 `"Jefferson City, MO"', add
label define met2013_lbl 27740 `"Johnson City, TN"', add
label define met2013_lbl 27780 `"Johnstown, PA"', add
label define met2013_lbl 27860 `"Jonesboro, AR"', add
label define met2013_lbl 27900 `"Joplin, MO"', add
label define met2013_lbl 28020 `"Kalamazoo-Portage, MI"', add
label define met2013_lbl 28100 `"Kankakee, IL"', add
label define met2013_lbl 28140 `"Kansas City, MO-KS"', add
label define met2013_lbl 28420 `"Kennewick-Richland, WA"', add
label define met2013_lbl 28660 `"Killeen-Temple, TX"', add
label define met2013_lbl 28700 `"Kingsport-Bristol-Bristol, TN-VA"', add
label define met2013_lbl 28940 `"Knoxville, TN"', add
label define met2013_lbl 29100 `"La Crosse-Onalaska, WI-MN"', add
label define met2013_lbl 29180 `"Lafayette, LA"', add
label define met2013_lbl 29200 `"Lafayette-West Lafayette, IN"', add
label define met2013_lbl 29340 `"Lake Charles, LA"', add
label define met2013_lbl 29420 `"Lake Havasu City-Kingman, AZ"', add
label define met2013_lbl 29460 `"Lakeland-Winter Haven, FL"', add
label define met2013_lbl 29540 `"Lancaster, PA"', add
label define met2013_lbl 29620 `"Lansing-East Lansing, MI"', add
label define met2013_lbl 29700 `"Laredo, TX"', add
label define met2013_lbl 29740 `"Las Cruces, NM"', add
label define met2013_lbl 29820 `"Las Vegas-Henderson-Paradise, NV"', add
label define met2013_lbl 29940 `"Lawrence, KS"', add
label define met2013_lbl 30020 `"Lawton, OK"', add
label define met2013_lbl 30140 `"Lebanon, PA"', add
label define met2013_lbl 30340 `"Lewiston-Auburn, ME"', add
label define met2013_lbl 30620 `"Lima, OH"', add
label define met2013_lbl 30700 `"Lincoln, NE"', add
label define met2013_lbl 30780 `"Little Rock-North Little Rock-Conway, AR"', add
label define met2013_lbl 31080 `"Los Angeles-Long Beach-Anaheim, CA"', add
label define met2013_lbl 31140 `"Louisville/Jefferson County, KY-IN"', add
label define met2013_lbl 31180 `"Lubbock, TX"', add
label define met2013_lbl 31340 `"Lynchburg, VA"', add
label define met2013_lbl 31460 `"Madera, CA"', add
label define met2013_lbl 31700 `"Manchester-Nashua, NH"', add
label define met2013_lbl 31860 `"Mankato-North Mankato, MN"', add
label define met2013_lbl 31900 `"Mansfield, OH"', add
label define met2013_lbl 32420 `"Mayagüez, PR"', add
label define met2013_lbl 32580 `"McAllen-Edinburg-Mission, TX"', add
label define met2013_lbl 32780 `"Medford, OR"', add
label define met2013_lbl 32820 `"Memphis, TN-MS-AR"', add
label define met2013_lbl 32900 `"Merced, CA"', add
label define met2013_lbl 33100 `"Miami-Fort Lauderdale-West Palm Beach, FL"', add
label define met2013_lbl 33140 `"Michigan City-La Porte, IN"', add
label define met2013_lbl 33260 `"Midland, TX"', add
label define met2013_lbl 33340 `"Milwaukee-Waukesha-West Allis, WI"', add
label define met2013_lbl 33460 `"Minneapolis-St. Paul-Bloomington, MN-WI"', add
label define met2013_lbl 33660 `"Mobile, AL"', add
label define met2013_lbl 33700 `"Modesto, CA"', add
label define met2013_lbl 33740 `"Monroe, LA"', add
label define met2013_lbl 33780 `"Monroe, MI"', add
label define met2013_lbl 33860 `"Montgomery, AL"', add
label define met2013_lbl 34060 `"Morgantown, WV"', add
label define met2013_lbl 34580 `"Mount Vernon-Anacortes, WA"', add
label define met2013_lbl 34620 `"Muncie, IN"', add
label define met2013_lbl 34740 `"Muskegon, MI"', add
label define met2013_lbl 34820 `"Myrtle Beach-Conway-North Myrtle Beach, SC-NC"', add
label define met2013_lbl 34900 `"Napa, CA"', add
label define met2013_lbl 34940 `"Naples-Immokalee-Marco Island, FL"', add
label define met2013_lbl 34980 `"Nashville-Davidson--Murfreesboro--Franklin, TN"', add
label define met2013_lbl 35300 `"New Haven-Milford, CT"', add
label define met2013_lbl 35380 `"New Orleans-Metairie, LA"', add
label define met2013_lbl 35620 `"New York-Newark-Jersey City, NY-NJ-PA"', add
label define met2013_lbl 35660 `"Niles-Benton Harbor, MI"', add
label define met2013_lbl 35840 `"North Port-Sarasota-Bradenton, FL"', add
label define met2013_lbl 35980 `"Norwich-New London, CT"', add
label define met2013_lbl 36100 `"Ocala, FL"', add
label define met2013_lbl 36140 `"Ocean City, NJ"', add
label define met2013_lbl 36220 `"Odessa, TX"', add
label define met2013_lbl 36260 `"Ogden-Clearfield, UT"', add
label define met2013_lbl 36420 `"Oklahoma City, OK"', add
label define met2013_lbl 36500 `"Olympia-Tumwater, WA"', add
label define met2013_lbl 36540 `"Omaha-Council Bluffs, NE-IA"', add
label define met2013_lbl 36740 `"Orlando-Kissimmee-Sanford, FL"', add
label define met2013_lbl 36780 `"Oshkosh-Neenah, WI"', add
label define met2013_lbl 36980 `"Owensboro, KY"', add
label define met2013_lbl 37100 `"Oxnard-Thousand Oaks-Ventura, CA"', add
label define met2013_lbl 37340 `"Palm Bay-Melbourne-Titusville, FL"', add
label define met2013_lbl 37460 `"Panama City, FL"', add
label define met2013_lbl 37620 `"Parkersburg-Vienna, WV"', add
label define met2013_lbl 37860 `"Pensacola-Ferry Pass-Brent, FL"', add
label define met2013_lbl 37900 `"Peoria, IL"', add
label define met2013_lbl 37980 `"Philadelphia-Camden-Wilmington, PA-NJ-DE-MD"', add
label define met2013_lbl 38060 `"Phoenix-Mesa-Scottsdale, AZ"', add
label define met2013_lbl 38300 `"Pittsburgh, PA"', add
label define met2013_lbl 38340 `"Pittsfield, MA"', add
label define met2013_lbl 38660 `"Ponce, PR"', add
label define met2013_lbl 38860 `"Portland-South Portland, ME"', add
label define met2013_lbl 38900 `"Portland-Vancouver-Hillsboro, OR-WA"', add
label define met2013_lbl 38940 `"Port St. Lucie, FL"', add
label define met2013_lbl 39140 `"Prescott, AZ"', add
label define met2013_lbl 39300 `"Providence-Warwick, RI-MA"', add
label define met2013_lbl 39340 `"Provo-Orem, UT"', add
label define met2013_lbl 39380 `"Pueblo, CO"', add
label define met2013_lbl 39460 `"Punta Gorda, FL"', add
label define met2013_lbl 39540 `"Racine, WI"', add
label define met2013_lbl 39580 `"Raleigh, NC"', add
label define met2013_lbl 39740 `"Reading, PA"', add
label define met2013_lbl 39820 `"Redding, CA"', add
label define met2013_lbl 39900 `"Reno, NV"', add
label define met2013_lbl 40060 `"Richmond, VA"', add
label define met2013_lbl 40140 `"Riverside-San Bernardino-Ontario, CA"', add
label define met2013_lbl 40220 `"Roanoke, VA"', add
label define met2013_lbl 40380 `"Rochester, NY"', add
label define met2013_lbl 40420 `"Rockford, IL"', add
label define met2013_lbl 40580 `"Rocky Mount, NC"', add
label define met2013_lbl 40900 `"Sacramento--Roseville--Arden-Arcade, CA"', add
label define met2013_lbl 40980 `"Saginaw, MI"', add
label define met2013_lbl 41060 `"St. Cloud, MN"', add
label define met2013_lbl 41100 `"St. George, UT"', add
label define met2013_lbl 41140 `"St. Joseph, MO-KS"', add
label define met2013_lbl 41180 `"St. Louis, MO-IL"', add
label define met2013_lbl 41420 `"Salem, OR"', add
label define met2013_lbl 41500 `"Salinas, CA"', add
label define met2013_lbl 41540 `"Salisbury, MD-DE"', add
label define met2013_lbl 41620 `"Salt Lake City, UT"', add
label define met2013_lbl 41660 `"San Angelo, TX"', add
label define met2013_lbl 41700 `"San Antonio-New Braunfels, TX"', add
label define met2013_lbl 41740 `"San Diego-Carlsbad, CA"', add
label define met2013_lbl 41860 `"San Francisco-Oakland-Hayward, CA"', add
label define met2013_lbl 41900 `"San Germán, PR"', add
label define met2013_lbl 41940 `"San Jose-Sunnyvale-Santa Clara, CA"', add
label define met2013_lbl 41980 `"San Juan-Carolina-Caguas, PR"', add
label define met2013_lbl 42020 `"San Luis Obispo-Paso Robles-Arroyo Grande, CA"', add
label define met2013_lbl 42100 `"Santa Cruz-Watsonville, CA"', add
label define met2013_lbl 42140 `"Santa Fe, NM"', add
label define met2013_lbl 42200 `"Santa Maria-Santa Barbara, CA"', add
label define met2013_lbl 42220 `"Santa Rosa, CA"', add
label define met2013_lbl 42540 `"Scranton--Wilkes-Barre--Hazleton, PA"', add
label define met2013_lbl 42660 `"Seattle-Tacoma-Bellevue, WA"', add
label define met2013_lbl 42680 `"Sebastian-Vero Beach, FL"', add
label define met2013_lbl 43100 `"Sheboygan, WI"', add
label define met2013_lbl 43340 `"Shreveport-Bossier City, LA"', add
label define met2013_lbl 43900 `"Spartanburg, SC"', add
label define met2013_lbl 44060 `"Spokane-Spokane Valley, WA"', add
label define met2013_lbl 44100 `"Springfield, IL"', add
label define met2013_lbl 44140 `"Springfield, MA"', add
label define met2013_lbl 44180 `"Springfield, MO"', add
label define met2013_lbl 44220 `"Springfield, OH"', add
label define met2013_lbl 44300 `"State College, PA"', add
label define met2013_lbl 44700 `"Stockton-Lodi, CA"', add
label define met2013_lbl 44940 `"Sumter, SC"', add
label define met2013_lbl 45060 `"Syracuse, NY"', add
label define met2013_lbl 45220 `"Tallahassee, FL"', add
label define met2013_lbl 45300 `"Tampa-St. Petersburg-Clearwater, FL"', add
label define met2013_lbl 45460 `"Terre Haute, IN"', add
label define met2013_lbl 45540 `"The Villages, FL"', add
label define met2013_lbl 45780 `"Toledo, OH"', add
label define met2013_lbl 45820 `"Topeka, KS"', add
label define met2013_lbl 45940 `"Trenton, NJ"', add
label define met2013_lbl 46060 `"Tucson, AZ"', add
label define met2013_lbl 46140 `"Tulsa, OK"', add
label define met2013_lbl 46220 `"Tuscaloosa, AL"', add
label define met2013_lbl 46340 `"Tyler, TX"', add
label define met2013_lbl 46520 `"Urban Honolulu, HI"', add
label define met2013_lbl 46540 `"Utica-Rome, NY"', add
label define met2013_lbl 46660 `"Valdosta, GA"', add
label define met2013_lbl 46700 `"Vallejo-Fairfield, CA"', add
label define met2013_lbl 47220 `"Vineland-Bridgeton, NJ"', add
label define met2013_lbl 47260 `"Virginia Beach-Norfolk-Newport News, VA-NC"', add
label define met2013_lbl 47300 `"Visalia-Porterville, CA"', add
label define met2013_lbl 47380 `"Waco, TX"', add
label define met2013_lbl 47580 `"Warner Robins, GA"', add
label define met2013_lbl 47900 `"Washington-Arlington-Alexandria, DC-VA-MD-WV"', add
label define met2013_lbl 48140 `"Wausau, WI"', add
label define met2013_lbl 48300 `"Wenatchee, WA"', add
label define met2013_lbl 48620 `"Wichita, KS"', add
label define met2013_lbl 48660 `"Wichita Falls, TX"', add
label define met2013_lbl 48700 `"Williamsport, PA"', add
label define met2013_lbl 48900 `"Wilmington, NC"', add
label define met2013_lbl 49180 `"Winston-Salem, NC"', add
label define met2013_lbl 49340 `"Worcester, MA-CT"', add
label define met2013_lbl 49420 `"Yakima, WA"', add
label define met2013_lbl 49620 `"York-Hanover, PA"', add
label define met2013_lbl 49660 `"Youngstown-Warren-Boardman, OH-PA"', add
label define met2013_lbl 49700 `"Yuba City, CA"', add
label define met2013_lbl 49740 `"Yuma, AZ"', add
label values met2013 met2013_lbl

label define gq_lbl 0 `"Vacant unit"'
label define gq_lbl 1 `"Households under 1970 definition"', add
label define gq_lbl 2 `"Additional households under 1990 definition"', add
label define gq_lbl 3 `"Group quarters--Institutions"', add
label define gq_lbl 4 `"Other group quarters"', add
label define gq_lbl 5 `"Additional households under 2000 definition"', add
label define gq_lbl 6 `"Fragment"', add
label values gq gq_lbl

label define hhincome_lbl 9999998 `"9999998"'
label define hhincome_lbl 9999999 `"9999999"', add
label values hhincome hhincome_lbl


keep if ///
    inlist(met2013, 12060, 12420, 12580, 14460, 16980, 17460, 19100, 19740, 19820, 29820) | ///
    inlist(met2013, 31080, 33100, 33460, 35620, 36740, 37980, 38060, 40900, 41620, 41740) | ///
    inlist(met2013, 41860, 42660, 45300, 47900)
	


* Hold the full person-level, 24-metro subset
tempfile persons
save `persons'

* (1) Mean HOUSEHOLD income: one row per household, valid income, HH weight
use `persons', clear
keep if pernum == 1
drop if inlist(hhincome, 9999998, 9999999)
collapse (mean) ipums_hhincome = hhincome, by(met2013 year)
tempfile hh
save `hh'

* (2) Mean PERSONAL income: all persons, valid income, person weight
use `persons', clear
drop if inctot == 9999999
collapse (mean) ipums_inctot = inctot [pweight=perwt], by(met2013 year)
tempfile pi
save `pi'

* (3) POPULATION: sum of person weights over ALL persons (no drops)
use `persons', clear
collapse (sum) ipums_population = perwt, by(met2013 year)
tempfile pop
save `pop'

* Combine the three IPUMS measures into one metro-year file
use `hh', clear
merge 1:1 met2013 year using `pi', nogenerate
merge 1:1 met2013 year using `pop', nogenerate

save IPUMS_market.dta, replace


local metros ///
 12060 12420 12580 14460 16980 17460 17410 19100 19740 19820 29820 31080 41860 ///
 33100 33460 35620 36740 37980 38060 40900 41620 41740 42660 45300 47900

tempfile acs
local first = 1
foreach y of numlist 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 {
    getcensus B19013_001 B01003_001, year(`y') sample(1) geography(metro) geoids(`metros') clear
    if `first' == 1 {
        save `acs', replace
        local first = 0
    }
    else {
        append using `acs'
        save `acs', replace
    }
}

use `acs', clear
rename b19013_001e acs_income
rename b01003_001e acs_population
rename metropolitanstatisticalareamicro met2013
destring met2013, replace          
replace met2013 = 17460 if met2013 == 17410 & inlist(year, 2023, 2024)


keep met2013 year acs_income acs_population
tempfile acs_year
save `acs_year'

use IPUMS_market.dta, clear
merge 1:1 met2013 year using `acs_year'
tab _merge
tab year _merge
save market.dta, replace
