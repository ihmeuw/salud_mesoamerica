************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Honduras Performance Indicator 4103
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// POSTPARTUM CARE RECORDS (4103)
	use "IHME_SMI_HND_HFS_2022_NOCOMP_Y2023M08D17.dta", clear

****************************************************************************************************
//  Indicator 4103: Routine newborn care with quality
****************************************************************************************************

// Denominator : Medical record review (no complications record which include immediate postpartum care)
	keep if mrr_records_ppm==1 
	
	// Basic/complete facilities only
	keep if cone == 2 | cone == 3 

{ //Date restrictions
	gen record_date = date(mrr_del_adm_date_spec, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/1/2020 - 6/30/2022)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 6/30/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}		

	//Exclude infant deaths 
	drop if mrr_pos_out == 3 | mrr_pos_out ==.
	
	
// BASIC and COMPLETE: Vitamina K + Administración de profilaxis oftálmica + Evaluación de malformaciones congénitas + BCG si el peso reportado es mayor a 2500 g + Apgar al primer minuto y Apgar 5 minutos. + Frecuencia respiratoria + Peso + Talla o longitud + Perímetro cefálico + Temperatura
 
	** Vitamina K   									MRR_NEW_CHECK_VITK_REG
	** Administración de profilaxis oftálmica			MRR_NEW_CHECK_CHL_REG	
	** Evaluación de malformaciones congénitas			MRR_NEW_CHECK_MALF_REG
	** BCG si el peso reportado es mayor a 2500 g 		MRR_NEW_CHECK_BCG_REG
	** Apgar al primer minuto y Apgar 5 minutos			MRR_NEW_CHECK_APG1_REG & MRR_NEW_CHECK_APG5_REG
	** Frecuencia respiratoria							MRR_NEW_CHECK_RESP_REG
	** Peso												MRR_NEW_CHECK_WT_REG
	** Talla o longitud									MRR_NEW_CHECK_HT_REG
	** Perímetro cefálico								MRR_NEW_CHECK_CIRC_REG
	** Temperatura										MRR_NEW_CHECK_TEMP_REG
	
//If there are multiple births (twins, etc), we need to evaluate for each.
	tab mrr_pos_type,m	
	
// Rename and format variables for each check	
	foreach var in vitk chl malf bcg apg1 apg5 resp wt ht circ temp {
		rename mrr_new_check_`var'_reg_1 `var'
		tostring mrr_new_check_`var'_date_1, replace
		replace `var' = 1 if mrr_new_check_`var'_date_1 !="" 
	}

	foreach var in vitk chl malf bcg apg1 apg5 resp wt ht circ temp {
		rename mrr_new_check_`var'_reg_2 `var'_2
		tostring mrr_new_check_`var'_date_2, replace
		replace `var'_2 = 1 if mrr_new_check_`var'_date_2 !="" 
	}

//BCG vaccine only required if weight > 2500 g
	tab1 mrr_new_check_wt_num_*, m

	gen bcg_if_weight = 0 if bcg !=. & mrr_new_check_wt_num_1 !=. & mrr_new_check_wt_num_1 > 2500
	replace bcg_if_weight = 1 if bcg == 1 & mrr_new_check_wt_num_1 !=. & mrr_new_check_wt_num_1 > 2500
	
	gen bcg_if_weight_2 = 0 if bcg !=. & mrr_new_check_wt_num_2 !=. & mrr_new_check_wt_num_2 > 2500
	replace bcg_if_weight_2 = 1 if bcg == 1 & mrr_new_check_wt_num_2 !=. & mrr_new_check_wt_num_2 > 2500


// INDICATOR CALCULATION ************************************************************
	// For only 1 birth	
	gen I4103 = 0 if vitk !=. & chl !=.  & malf !=. & bcg !=. & apg1 !=. & apg5 !=. & resp !=. & wt !=. & ht !=. & circ !=. & temp !=. & mrr_pos_type == 1
	replace I4103 = 1 if vitk == 1 & chl == 1 & malf == 1 & bcg_if_weight != 0 & apg1 == 1 & apg5 == 1 & resp == 1  & wt == 1 & ht == 1 & circ == 1 & temp == 1 & mrr_pos_type == 1
	// For 2 births
	replace I4103 = 0 if vitk !=. & chl !=. & malf !=. & bcg !=. & apg1 !=. & apg5 !=. & resp !=. & wt !=. & ht !=. & circ !=.  & temp !=. & vitk_2 !=. & chl_2 !=. & malf_2 !=. & bcg_2 !=. & apg1_2 !=. & apg5_2 !=. & resp_2 !=. & wt_2 !=. & ht_2 !=. & circ_2 !=.  & temp_2 !=. & mrr_pos_type == 2
	replace I4103 = 1 if vitk == 1 & chl == 1 & malf == 1 & bcg_if_weight != 0 & apg1 == 1 & apg5 == 1 & resp == 1  & wt == 1 & ht == 1 & circ == 1 & temp == 1 & vitk_2 == 1 & chl_2 == 1 & malf_2 == 1 & bcg_if_weight_2 != 0 & apg1_2 == 1 & apg5_2 == 1 & resp_2 == 1  & wt_2 == 1 & ht_2 == 1 & circ_2 == 1 & temp_2 == 1 & mrr_pos_type == 2	

	// Indicator value
	prop I4103 if time == "evaluation" & tx_area == 1
	prop I4103 if time == "pre-evaluation" & tx_area == 1
