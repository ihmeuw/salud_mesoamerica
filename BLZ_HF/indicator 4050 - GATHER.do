************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 4050
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
***************************************

// UNCOMPLICATED DELIVERY RECORDS (4050)
	use "IHME_SMI_BLZ_HFS_2022_NOCOMP_Y2023M08D17.dta", clear

******************************************************************************************
// Indicator 4050: Postpartum care with quality
******************************************************************************************	

// Denominator : Medical record review (no complications record which include immediate postpartum care)
	keep if mrr_records_ppm==1 
	
	// Basic/complete facilities only
	cap drop cone 
	cap gen cone = "amb" if fac_type == 1
	replace cone = "basic" if fac_type == 2
	replace cone = "comp" if fac_type == 3
	
	keep if cone == "basic" | cone == "comp" 

{ //Date restrictions
	gen record_date = date(mrr_del_adm_date_spec, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/16/2020 - 7/15/2022)
	replace time = "evaluation" if record_date >= date("2020-7-16", "YMD") & record_date <= date("2022-7-15", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 7/15/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-7-15", "YMD")

	//Keep only eligible records
	drop if time == ""
}		
	
// Denominator: restrict to only in-facility births, excluding referrals
	keep if mrr_pos_birth_where == 1 // in-facility delivery 
	drop if mrr_pos_reffrom == 1 // exclude referrals
	

// Numerator: (BP + temperature + respiratory rate + pulse/HR): 4+ times in first hour, 2+ times in second hour, once at discharge
	
	// BP
	gen bppass = 0 if mrr_pos3_check_bp_4x1 !=. & mrr_pos3_check_bp_2x2 !=. & mrr_dis_check_bp_reg !=.
	replace bppass = 1 if mrr_pos3_check_bp_4x1 >=4 &  mrr_pos3_check_bp_4x1 !=. & mrr_pos3_check_bp_2x2 >=2  & mrr_pos3_check_bp_2x2 !=. & mrr_dis_check_bp_reg == 1

	// Temperature
	gen temppass = 0 if mrr_pos3_check_temp_4x1 !=. & mrr_pos3_check_temp_2x2 !=. & mrr_dis_check_temp_reg != .
	replace temppass = 1 if mrr_pos3_check_temp_4x1 >=4 & mrr_pos3_check_temp_4x1 !=. & mrr_pos3_check_temp_2x2 >=2 & mrr_pos3_check_temp_2x2 !=. & mrr_dis_check_temp_reg == 1 
	
	// Respiratory rate
	gen resppass = 0 if mrr_pos3_check_resp_4x1 !=. & mrr_pos3_check_resp_2x2 !=. & mrr_dis_check_resp_reg != .
	replace resppass = 1 if mrr_pos3_check_resp_4x1 >=4 & mrr_pos3_check_resp_4x1 !=. & mrr_pos3_check_resp_2x2 >=2 & mrr_pos3_check_resp_2x2 !=. & mrr_dis_check_resp_reg == 1 
	
	// Pulse / Heartrate
	gen hppass = 0 if mrr_pos3_check_puls_4x1 !=. & mrr_pos3_check_puls_2x2 !=. & mrr_pos3_check_hr_4x1 !=. & mrr_pos3_check_hr_2x2 !=. & mrr_dis_check_hr_reg !=. & mrr_dis_check_puls_reg !=.
	replace hppass = 1 if mrr_pos3_check_puls_4x1 + mrr_pos3_check_hr_4x1 >=4 & mrr_pos3_check_puls_4x1 !=. & mrr_pos3_check_hr_4x1 !=. & mrr_pos3_check_puls_2x2 + mrr_pos3_check_hr_2x2 >=2 & mrr_pos3_check_puls_2x2 !=. & mrr_pos3_check_hr_2x2 !=. & ( mrr_dis_check_puls_reg == 1 | mrr_dis_check_hr_reg == 1 )

	
 // INDICATOR CALCULATION ************************************************************
 	gen I4050 = 0 if bppass !=. & temppass !=. & resppass !=. & hppass !=.
	replace I4050 = 1 if bppass == 1 & temppass == 1 & resppass == 1 & hppass == 1 
	
	// Indicator value
	prop I4050 if time == "evaluation"
	prop I4050 if time == "pre-evaluation"
