************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 3000
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
************************************

// UNCOMPLICATED DELIVERY RECORDS (3000)
	use "IHME_SMI_SLV_HFS_2022_NOCOMP_Y2023M08D17.dta", clear
	
*********************************************************************************************
//  Indicator 3000: Women in reproductive age (20-49 years) who received preconception care 
*********************************************************************************************

// Denominator : Medical record review (no complications record which include antenatal care)
	keep if mrr_records_anc==1 

	// Ambulatory facilities only
	keep if cone == 1 

// Date restriction: Last menstrual period within 20 weeks of the cutoff for evaluation timeframe (9/29/2021)
	gen record_date = date(lmp_date, "YMD")
	gen preg_within_last_20_weeks = 0 if record_date !=.
	replace preg_within_last_20_weeks = 1 if date("2021-9-29", "YMD") - record_date <= 20 * 7
	
//Age restriction: include only women age 20-49
	drop if mrr_age < 20 | mrr_age > 49
	
	
// Numerator: at least 1 preconception care visit (or health consultation) + height + weight + blood pressure + folic acid  + blood group + rh factor + HIV test + syphilis test + Hoja Filtro Preconcepcional + management of risk factors
	
//	Evidence of any preconception care?
	tab mrr_pre_exists time,m
	tab mrr_pre_num time,m
	
// At least one preconception care visit
	gen precon_visit = 0 if mrr_pre_exists !=.
	replace precon_visit = 1 if mrr_pre_num >= 1 & mrr_pre_num !=.

// Appropriate checks
	gen height =.
	gen weight =.
	gen bp =.
	gen folic =.
	// Loop over each visit
	su mrr_pre_num, meanonly
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
	//Blood group
	gen bg = 0 if mrr_pre_lab_bg !=.
	replace bg = 1 if mrr_pre_lab_bg == 1
	
	//Rh factor
	gen rh = 0 if mrr_pre_lab_rh !=.
	replace rh = 1 if mrr_pre_lab_rh == 1
	
	//HIV
	gen hiv = 0 if mrr_pre_lab_hiv !=.
	replace hiv = 1 if mrr_pre_lab_hiv == 1
	
	//Syph
	gen syph = 0 if mrr_pre_lab_syph !=.
	replace syph = 1 if mrr_pre_lab_syph == 1
	
//Management of risk factors
	
	//HIV
	gen manage_hiv = 0 if mrr_pre_lab_test_hiv_pos_neg == 1 & mrr_pre_hiv_ref !=.
	replace manage_hiv = 1 if mrr_pre_lab_test_hiv_pos_neg == 1 & mrr_pre_hiv_ref == 1
	
	//Syphilis
	gen manage_syph = 0 if mrr_pre_lab_test_syph_pos_neg == 1 & mrr_pre_syph_ref !=.
	replace manage_syph = 1 if mrr_pre_lab_test_syph_pos_neg == 1 & mrr_pre_syph_ref == 1
	
	//Biological risk factors
	gen manage_bio = 0 if mrr_pre_cond_reffor !=.
	replace manage_bio = 1 if mrr_pre_cond_reffor == 1
	
	//Social risk factors
	//(Se excluyen los siguientes factores de riesgo sociales: unión inestable, delincuencia, pobreza extrema, analfabetismo, baja escolaridad, inaccesibilidad a los servicios de salud. )
	gen manage_social = 0 if ( mrr_pre_cond_soc_alcohol == 1 | mrr_pre_cond_soc_add == 1 | mrr_pre_cond_soc_viosex == 1 | mrr_pre_cond_soc_vioint == 1 | mrr_pre_cond_soc_risksex == 1 ) & mrr_pre_cond_soc_reffor !=.
	replace manage_social = 1 if ( mrr_pre_cond_soc_alcohol == 1 | mrr_pre_cond_soc_add == 1 | mrr_pre_cond_soc_viosex == 1 | mrr_pre_cond_soc_vioint == 1 | mrr_pre_cond_soc_risksex == 1 ) & mrr_pre_cond_soc_reffor == 1
	
	//Overall risk factor management
	gen risk_manage = 1 if manage_hiv !=. | manage_syph !=. | manage_bio !=. | manage_social !=.
	replace risk_manage = 0 if manage_hiv == 0 | manage_syph == 0 | manage_bio == 0 | manage_social == 0
	
	
// INDICATOR CALCULATION ************************************************************
	gen I3000 = 0 if precon_visit !=.
	replace I3000 = 1  if precon_visit == 1 & height == 1 & weight == 1 & bp == 1 & folic == 1 & bg == 1 & rh == 1 & syph == 1 & risk_manage != 0
	
	//Indicator Value
	prop I3000 if preg_within_last_20_weeks == 1 & tx_area == 1

