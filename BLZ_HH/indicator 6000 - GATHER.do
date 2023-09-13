************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 6000
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
***************************************

// CERVICAL CANCER SCREENING  (6000)
// bring in LQAS (household) data
use "IHME_SMI_HHS_BLZ_2022_LQAS_Y2023M08D17.dta", clear

cap rename *, lower


** ****************************
** ****************************
** Indicator 6000
** Cervical cancer screening
** ****************************
** ****************************	


// must have been screened with via or PAP within last 3 years (HPV test not captured,  restricted to married/partnered women)
gen screen_3yrs = .
replace screen_3yrs = 0 if pap_ever !=. | via_ever !=.
replace screen_3yrs = 1 if inlist(pap_last_when, 6, 7, 2, 3) | inlist(via_last_when, 6, 7, 2, 3)

gen screen_3yrs_via = .
replace screen_3yrs_via = 0 if via_ever !=. 
replace screen_3yrs_via = 1 if  inlist(via_last_when, 6, 7, 2, 3)

gen screen_3yrs_pap = .
replace screen_3yrs_pap = 0 if pap_ever !=. 
replace screen_3yrs_pap = 1 if inlist(pap_last_when, 6, 7, 2, 3) 


// must know the results, as long as the last screening was more than a month ago
gen screen_results = .
replace screen_results = 0 if (pap_ever !=. | via_ever !=.) 
replace screen_results = 1 if (inlist(pap_last_result, 1, 2, 3, 4) | inlist(via_last_result, 1, 2, 3, 4) | pap_last_when == 6 | via_last_when == 6) & (inlist(pap_last_when, 6, 7, 2, 3) | inlist(via_last_when, 6, 7, 2, 3)) //know results of only the screening THAT WAS IN THE LAST 3 YEARS

gen screen_results_via = .
replace screen_results_via = 0 if via_ever !=. & inlist(via_last_when, 6, 7, 2, 3)
replace screen_results_via = 1 if (inlist(via_last_result, 1, 2, 3, 4) | via_last_when == 6) & inlist(via_last_when, 6, 7, 2, 3)

gen screen_results_pap = .
replace screen_results_pap = 0 if pap_ever !=. & inlist(pap_last_when, 6, 7, 2, 3)
replace screen_results_pap = 1 if (inlist(pap_last_result, 1, 2, 3, 4) | pap_last_when == 6) & inlist(pap_last_when, 6, 7, 2, 3)

// must meet the above criteria and be 28-49
gen ccscreen_compliant = . 	
replace ccscreen_compliant = 0 if age_woman_spec >=28 & age_woman_spec <=49 & screen_3yrs != . & screen_results != .
replace ccscreen_compliant = 1 if age_woman_spec >=28 & age_woman_spec <=49 & screen_3yrs == 1 & screen_results == 1 

ci prop ccscreen_compliant


// Adjust original LQAS results to reflect the increase we saw in the indicator performance for recollected data after field revisits. 
// In the recollected data, 4 women out of 97 switched from having no screening to having a screening based on newly collected HPV screening data (44 had Pap or VIAA, and 48 had Pap, VIAA, OR HPV). 

// Adjust the original result: 108/222 women had a screening at initial data collection. Adjust this upward based on the change we observed during the recollection: with a ratio of (44/97):(48/97)
// apply the ratio that changed i.e. about 9% (from 44/97 to 48/97, or (48/97-44/97)/(44/97))
// x/222 = 108/222 * (48/97)/(44/97)
di 108/222 * (48/97)/(44/97) * 222
// x == 118 (117.81818), so change 10 results at random from 0 to 1

*Change 10 random results from 0 to 1
set seed 2022 
gen num = runiform() if ccscreen_compliant != .
sort ccscreen_compliant num
replace ccscreen_compliant = 1 in 1/10
drop num

// INDICATOR CALCULATION ************************************************************
prop ccscreen_compliant 


