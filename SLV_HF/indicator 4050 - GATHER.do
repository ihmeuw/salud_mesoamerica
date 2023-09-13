************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 4050
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// UNCOMPLICATED DELIVERY RECORDS (4050)
	use "IHME_SMI_SLV_HFS_2022_NOCOMP_Y2023M08D17.dta", clear

******************************************************************************************
// Indicator 4050: Postpartum care with quality
******************************************************************************************
	
// Denominator : Medical record review (no complications record which include immediate postpartum care)
	keep if mrr_records_ppm == 1 
	
	// Basic/complete facilities only
	keep if cone == 2 | cone == 3

{ //Date restrictions 
	gen record_date = date(mrr_del_adm_date_spec, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (admission date) (7/1/2020 - 9/26/2021)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (admission date) (1/1/2019 - 9/26/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}		
	
// Excluding referrals
	drop if mrr_disposition == 3
	drop if mrr_pos_reffrom == 1 
	

// Blood pressure - 4x in first hour, 2x in second hour, once at discharge
	gen bp4 = 0 if mrr_pos3_check_bp_4x1 !=.
	replace bp4 = 1 if mrr_pos3_check_bp_4x1 >=4 & mrr_pos3_check_bp_4x1 !=.
	
	gen bp2 = 0 if mrr_pos3_check_bp_2x2 !=.
	replace bp2 = 1 if mrr_pos3_check_bp_2x2 >=2 & mrr_pos3_check_bp_2x2 !=.
	
	gen bp_dis = 0 if mrr_dis_check_bp_reg !=.
	replace bp_dis = 1 if mrr_dis_check_bp_reg == 1 
	
	gen bppass = 0 if bp4 !=. & bp2 !=. & bp_dis !=. 
	replace bppass = 1 if bp4 == 1 & bp2 == 1 & bp_dis == 1

// Respiratory rate - 4x in first hour, 2x in second hour, once at discharge
	gen resp4 = 0 if mrr_pos3_check_resp_4x1 !=. 
	replace resp4 = 1 if mrr_pos3_check_resp_4x1 >=4 & mrr_pos3_check_resp_4x1 !=. 
	
	gen resp2 = 0 if mrr_pos3_check_resp_2x2 !=. 
	replace resp2 = 1 if mrr_pos3_check_resp_2x2 >=2 & mrr_pos3_check_resp_2x2 !=. 
	
	gen resp_dis = 0 if mrr_dis_check_resp_reg !=.
	replace resp_dis = 1 if mrr_dis_check_resp_reg == 1
	
	gen resppass = 0 if resp4 !=. & resp2 !=. & resp_dis !=.
	replace resppass = 1 if resp4 == 1 & resp2 == 1 & resp_dis == 1
		
// Pulse / Heart rate - 4x in first hour, 2x in second hour, once at discharge
	gen pulshr4 = 0 if mrr_pos3_check_puls_4x1 !=. & mrr_pos3_check_hr_4x1 !=.
	replace pulshr4 = 1 if mrr_pos3_check_puls_4x1 + mrr_pos3_check_hr_4x1 >=4 & mrr_pos3_check_puls_4x1 !=. & mrr_pos3_check_hr_4x1 !=.
		
	gen pulshr2 = 0 if mrr_pos3_check_puls_2x2 !=. & mrr_pos3_check_hr_2x2 !=.
	replace pulshr2 = 1 if mrr_pos3_check_puls_2x2 + mrr_pos3_check_hr_2x2 >=2 & mrr_pos3_check_puls_2x2 !=. & mrr_pos3_check_hr_2x2 !=.

	gen pulshr_dis = 0 if mrr_dis_check_puls_reg !=. & mrr_dis_check_hr_reg !=.
	replace pulshr_dis = 1 if mrr_dis_check_puls_reg == 1 | mrr_dis_check_hr_reg == 1

	gen pulshrpass = 0 if pulshr4 !=. & pulshr2 !=. & pulshr_dis !=.
	replace pulshrpass = 1 if pulshr4 == 1 & pulshr2 == 1 & pulshr_dis == 1

// Blood abnormalities - 4x in first hour, 2x in second hour, once at discharge
	gen abnorm4 = 0 if mrr_pos3_check_abnorm_4x1 !=. 
	replace abnorm4 = 1 if mrr_pos3_check_abnorm_4x1 >=4 & mrr_pos3_check_abnorm_4x1 !=.
	
	gen abnorm2 = 0 if mrr_pos3_check_abnorm_2x2 !=. 
	replace abnorm2 = 1 if mrr_pos3_check_abnorm_2x2 >=2 & mrr_pos3_check_abnorm_2x2 !=. 
	
	gen abnorm_dis = 0 if mrr_dis_check_abnorm_reg !=.
	replace abnorm_dis = 1 if mrr_dis_check_abnorm_reg == 1

	gen abnormpass = 0 if abnorm4 !=. & abnorm2 !=. & abnorm_dis !=.
	replace abnormpass = 1 if abnorm4 == 1 & abnorm2 == 1 & abnorm_dis == 1
	
// Temperature - only at discharge	
	gen temp_dis = 0 if mrr_dis_check_temp_reg !=.
	replace temp_dis = 1 if mrr_dis_check_temp_reg == 1
	
	gen temppass = 0 if temp_dis !=.
	replace temppass = 1 if temp_dis == 1

	
// INDICATOR CALCULATION ************************************************************
 	gen I4050 = 0 if bppass !=. & resppass !=. & pulshrpass !=. & abnormpass !=. & temppass !=.
	replace I4050 = 1 if bppass == 1 & resppass == 1 & pulshrpass == 1 & abnormpass == 1 & temppass == 1
	
	// Indicator value
	prop I4050 if time == "evaluation" & tx_area == 1
	prop I4050 if time == "pre-evaluation" & tx_area == 1
