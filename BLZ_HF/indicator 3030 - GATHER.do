************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 3030
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
************************************

// ANTENATAL CARE RECORDS (3030)
	use "IHME_SMI_BLZ_HFS_2022_NOCOMP_Y2023M08D17.dta", clear

*******************************************************************************************************
// Indicator 3030: 5 antenatal care visits with quality
*******************************************************************************************************

// Denominator : Medical record review (no complications record which include antenatal care)
	keep if mrr_records_anc==1 
	drop if mrr_anc_num_spec == .
	
	// Ambulatory facilities only
	keep if fac_type == 1

{ //Date restrictions
	gen record_date = date(lmp_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (date of last menstrual period) (7/16/2020 - 10/10/2021)
	replace time = "evaluation" if record_date >= date("2020-7-16", "YMD") & record_date <= date("2021-10-10", "YMD")
	
	//*Pre-evaluation* period date range (date of last menstrual period) (1/1/2019 - 10/10/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2019-10-10", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Drop if outside age range (<=13)
	drop if mrr_age_spec <=13 & mrr_age_spec !=.
	
// 1. Had at least 5 visits 
	gen anc_5 = 0 if mrr_anc_num_spec !=.
	replace anc_5 = 1 if mrr_anc_num_spec >= 5 & mrr_anc_num_spec!=.

// Create some descriptive variables to be used in the loop
	// Is the gestational age greater than or equal to 14 weeks at first visit?
	gen greaterequal_14_at_visit1 = 0 if mrr_anc_con_gestage_1 !=. & mrr_anc_con_gestage_1 != -1
	replace greaterequal_14_at_visit1 = 1 if mrr_anc_con_gestage_1 >= 14 & mrr_anc_con_gestage_1 !=.
	// Is the gestational age greater than 20 weeks at first visit?
	gen greater_20_at_visit1 = 0 if mrr_anc_con_gestage_1 !=. & mrr_anc_con_gestage_1 != -1
	replace greater_20_at_visit1 = 1 if mrr_anc_con_gestage_1 > 20 & mrr_anc_con_gestage_1 !=.
	// Loop over each visit
	su mrr_anc_num_spec, meanonly
	local max_loop = r(max)
	forvalues x = 2/`max_loop' {
		local y = `x' - 1
		// At a given visit, was the gestational age greater than or equal to 14 weeks? - this is also true if the gestational age at the previous visit was >= 14 weeks
		gen greaterequal_14_at_visit`x' = 0 if mrr_anc_con_gestage_`x' !=. & mrr_anc_con_gestage_`x' != -1
		replace greaterequal_14_at_visit`x' = 1 if ( mrr_anc_con_gestage_`x' >= 14 & mrr_anc_con_gestage_`x' !=. ) | ( greaterequal_14_at_visit`y' == 1 & mrr_anc_con_gestage_`x' == -1 )
		// At a given visit, was the gestational age greater than 20 weeks? - this is also true if the gestational age at the previous visit was > 20 weeks
		gen greater_20_at_visit`x' = 0 if mrr_anc_con_gestage_`x' !=. & mrr_anc_con_gestage_`x' != -1
		replace greater_20_at_visit`x' = 1 if ( mrr_anc_con_gestage_`x' > 20 & mrr_anc_con_gestage_`x' !=. ) | ( greater_20_at_visit`y' == 1 & mrr_anc_con_gestage_`x' == -1 )
	}
	su mrr_anc_num_spec, meanonly
	local max_loop = r(max)-1
	forvalues x = `max_loop'(-1) 1 {
		local y = `x' + 1
		//Conversely, if the gestational age at a visit *after* a given visit was *not* >= 14 weeks, the given visit was also not >= 14 weeks
		replace greaterequal_14_at_visit`x' = 0 if greaterequal_14_at_visit`y' == 0 & mrr_anc_con_gestage_`x' == -1 
		//Conversely, if the gestational age at a visit *after* a given visit was *not* > 20 weeks, the given visit was also not >= 14 weeks
		replace greater_20_at_visit`x' = 0 if greater_20_at_visit`y' == 0 & mrr_anc_con_gestage_`x' == -1
	}
	

// 2. First visit before 13 weeks - set up the variable
	gen  first_before_13 = 0 if mrr_anc_con_gestage_1 !=.

// Loop over each visit
	su mrr_anc_num_spec, meanonly
	local max_loop = r(max)
	forvalues x = 1/`max_loop' {
		//The first n visits may not have the gestational age recorded, but if any visit is < 13 weeks, it stands to reason that the first one was also < 13 weeks.
		replace first_before_13 = 1 if mrr_anc_con_gestage_`x' < 13 

		// physical checkups (weight + blood pressure ) each visit
		gen vital_signs_`x' = 0 if mrr_anc_con_wt_`x' != . & mrr_anc_con_bp_`x' != .
		replace vital_signs_`x' = 1 if mrr_anc_con_wt_`x' == 1 & mrr_anc_con_bp_`x' == 1

		// uterine height if gestational age is >= 14 weeks
		gen gest_eligible_uterine_`x' = greaterequal_14_at_visit`x'
		replace gest_eligible_uterine_`x' = . if mrr_anc_con_gestage_`x' > 42 & mrr_anc_con_gestage_`x' !=.	
	
		gen uterine_height_`x' = 0 if gest_eligible_uterine_`x' == 1 & mrr_anc_con_fund_`x' !=.
		replace uterine_height_`x' = 1 if gest_eligible_uterine_`x'== 1 & mrr_anc_con_fund_`x' == 1

		// fetal checkups (fetal heart rate + fetal movement) if gestational age is > 20 weeks
		gen gest_eligible_fetal_`x' = greater_20_at_visit`x'
		replace gest_eligible_fetal_`x' = . if mrr_anc_con_gestage_`x' > 42 & mrr_anc_con_gestage_`x' !=.	
		
		gen fetal_checkup_`x' = 0 if gest_eligible_fetal_`x'==1 & mrr_anc_con_baby_fhr_`x' !=. & mrr_anc_con_baby_fm_`x' !=.
		replace fetal_checkup_`x' = 1 if gest_eligible_fetal_`x'==1 & mrr_anc_con_baby_fhr_`x' == 1 & mrr_anc_con_baby_fm_`x' == 1
	}
	
	
// Overall indicator for each visit 
	su mrr_anc_num_spec, meanonly
	local max_loop = r(max)
	forvalues x = 1/`max_loop' {
		gen m_visit`x'= 1 if vital_signs_`x'!=. 
		gen visit`x' = 0 if vital_signs_`x'!=. & (fetal_checkup_`x'!=. | gest_eligible_fetal_`x'==0) & (uterine_height_`x'!=. | gest_eligible_uterine_`x'==0)
		replace visit`x' = 1 if vital_signs_`x'==1 & ((fetal_checkup_`x'==1 & gest_eligible_fetal_`x'==1) | (gest_eligible_fetal_`x'==0)) & ((uterine_height_`x'==1 & gest_eligible_uterine_`x'==1) | (gest_eligible_uterine_`x'==0))	
	}
	
	// generate total number of positive visits
	egen tot_positive_visits = anycount(visit1 visit2 visit3 visit4 visit5 visit6 visit7 visit8 visit9 visit10 visit11), value(1) 
	
	// drop if more than 5 visits recorded but one or more have missing data and cannot be evaluated fully
	egen mvisits_tot = anycount(m_visit1 m_visit2 m_visit3 m_visit4 m_visit5 m_visit6 m_visit7 m_visit8 m_visit9 m_visit10 m_visit11 ), value(1) 
	drop if mrr_anc_num_spec >= 5 & mvisits_tot < 5
	
// Lab tests performed (Blood group +  Rh factor + Blood for glucose + HIV test + VDRL  + Hb level + Urinanalysis) at least once.
	gen lab_tests = 0 if mrr_anc_lab_test_bg !=. & mrr_anc_lab_test_rh !=. & mrr_anc_lab_test_glu != . &  mrr_anc_lab_test_hiv != . & mrr_anc_lab_test_vdrl !=. & mrr_anc_lab_test_rpr !=. & mrr_anc_lab_test_hb != . & mrr_anc_lab_test_urine != .
	replace lab_tests = 1 if mrr_anc_lab_test_bg == 1 & mrr_anc_lab_test_rh == 1 & mrr_anc_lab_test_glu == 1 &  mrr_anc_lab_test_hiv == 1 & (mrr_anc_lab_test_vdrl == 1 | mrr_anc_lab_test_rpr == 1 ) & mrr_anc_lab_test_hb == 1 & mrr_anc_lab_test_urine == 1

// INDICATOR CALCULATION ************************************************************
	gen I3030 = 0 if anc_5 !=. & tot_positive_visits !=. & lab_tests !=.
	replace I3030 = 1  if anc_5 == 1 & tot_positive_visits  >= 5 & tot_positive_visits !=. & lab_tests == 1
	
	// Indicator value
	prop I3030 if  time == "evaluation"
	prop I3030 if  time == "pre-evaluation"
