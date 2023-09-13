************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 3000
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
************************************

// UNCOMPLICATED DELIVERY RECORDS (3000)
	use "IHME_SMI_BLZ_HFS_2022_NOCOMP_Y2023M08D17.dta", clear
	
*********************************************************************************************
//  Indicator 3000: Preconception care with quality
*********************************************************************************************

// Denominator : Medical record review (no complications record which include antenatal care)
	keep if mrr_records_anc==1 

	// Ambulatory facilities only
	keep if fac_type == 1

// Date restriction: Last menstrual period within 3 months of the cutoff for evaluation time frame (10/10/2021)
	gen record_date = date(lmp_date, "YMD")
	gen preg_within_last_3_months = 0 if record_date !=.
	replace preg_within_last_3_months = 1 if record_date >= date("2021-7-10", "YMD") & record_date <= date("2021-10-10", "YMD")	


// Numerator: at least 1 preconception care visit (or health consultation) + height + weight + blood pressure + folic acid supplementation + Hemoglobin level + HIV test 
	
//	Evidence of any preconception care?
	tab mrr_pre_exists time,m
	tab mrr_pre_num_spec time,m
	
// At least one preconception care visit
	gen precon_visit = 0 if mrr_pre_exists !=.
	replace precon_visit = 1 if mrr_pre_num_spec >= 1 & mrr_pre_num_spec !=.

// Appropriate checks
	gen height =.
	gen weight =.
	gen bp =.
	gen folic =.
	// Loop over each visit
	su mrr_pre_num_spec, meanonly
	local max_loop = r(max)
	forvalues x = 1/`max_loop' {
		//Height
		replace height = 0 if height ==. & mrr_pre_check_ht_`x' !=.
		replace height = 1 if mrr_pre_check_ht_`x' == 1
		
		//Weight
		replace weight = 0 if weight ==. & mrr_pre_check_wt_`x' !=.
		replace weight = 1 if mrr_pre_check_wt_`x' == 1
	
		//BP
		replace bp = 0 if bp ==. & mrr_pre_check_bp_`x' !=.
		replace bp = 1 if mrr_pre_check_bp_`x' == 1
		
		//Folic
		replace folic = 0 if folic ==. & mrr_pre_check_folic_`x' !=.
		replace folic = 1 if mrr_pre_check_folic_`x' == 1
}		
	//Hemoglobin
	gen hemo = 0 if mrr_pre_lab_hb !=.
	replace hemo = 1 if mrr_pre_lab_hb == 1
	
	//HIV
	gen hiv = 0 if mrr_pre_lab_hiv !=.
	replace hiv = 1 if mrr_pre_lab_hiv == 1
	
	
// INDICATOR CALCULATION ************************************************************
	gen I3000 = 0 if precon_visit !=.
	replace I3000 = 1  if precon_visit == 1 & height == 1 & weight == 1 & bp == 1 & folic == 1 & hemo == 1 & hiv == 1
	
	// Indicator value
	prop I3000 if preg_within_last_3_months == 1
