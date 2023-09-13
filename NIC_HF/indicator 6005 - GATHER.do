************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Nicaragua Performance Indicator 6005
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// CERVICAL CANCER SCREENING RECORDS (6005)
	use "IHME_SMI_NIC_HFS_2022_CACX_Y2023M08D17.dta", clear
	
****************************************************************************************************
//  Indicator 6005 - Women aged 25-49 who underwent quality screening for early detection of cervical cancer
****************************************************************************************************

// Ambulatory facilities only
	keep if cone == 1
	
{ //Date restrictions 
	gen record_date = date(cacx_visit_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (4/1/2022	- 6/30/2022)
	replace time = "evaluation" if record_date >= date("2022-4-1", "YMD") & record_date <= date("2022-6-30", "YMD")

	//Keep only eligible records
	drop if time != "evaluation"
}

//Denominator: Total de expedientes de mujeres seleccionados entre 25 a 49 años en el último año en la muestra
	tab age_final,m
	keep if age_final >= 25 & age_final <= 49 & age_final !=.
	
//Screening type?
	tab cacx_screen_type,m
	
// No evidence of screening - these fail
	gen no_screening = 0 if cacx_screen_type !=""
	replace no_screening = 1 if cacx_screen_type_none == 1
	
	
//VPH: Negative result within last 5 years OR ( positive result within past year + notification within 30 days + evidence result was received )
	//Any VPH?
	gen any_vph = 0 if cacx_screen_type != ""
	replace any_vph = 1 if cacx_screen_type_vph == 1

	//Format date
	gen vph_date = date(vph_screen_date_1, "YMD")

	//Screening data registered
	gen vph_date_reg = 0 if any_vph == 1
	replace vph_date_reg = 1 if any_vph == 1 & vph_date !=.

	//Within 5 years
	gen vph_date_within_5year = 0 if vph_date_reg !=.
	replace vph_date_within_5year = 1 if vph_date >= record_date - ( 365.25 * 5 ) & vph_date !=.
	//Within 1 year
	gen vph_date_within_1year = 0 if vph_date_reg !=.
	replace vph_date_within_1year = 1 if vph_date >= record_date - 365 & vph_date !=. & record_date !=.
	
	//Negative within 5 years
	gen vph_negative_5_years = 0 if vph_date_within_5year == 1 & vph_screen_lab !=.
	replace vph_negative_5_years = 1 if vph_date_within_5year == 1 & vph_screen_res == 0
	
	//Positive within 1 year
	gen vph_positive_1_year = 0 if vph_date_within_1year == 1 & vph_screen_lab !=.
	replace vph_positive_1_year = 1 if vph_date_within_1year == 1 & vph_screen_res == 1
	
	//Result not registered
	gen vph_result_nr = 0 if vph_screen_lab !=.
	replace vph_result_nr = 1 if vph_screen_res == -1

	//If result positive, notification date within 30 days of date result received from lab
	tostring vph_screen_lab_rep_date, replace
	gen vph_result_date = date(vph_screen_lab_rep_date, "YMD")
	replace vph_result_date = vph_date if vph_result_date ==.
	
	tostring vph_screen_res_notify_when, replace
	gen vph_notify_date = date(vph_screen_res_notify_when, "YMD")
	
	gen vph_notify_within_30days = 0 if vph_positive_1_year == 1
	replace vph_notify_within_30days = 1 if vph_positive_1_year == 1 & vph_notify_date >= vph_result_date - 30 & vph_result_date !=. & vph_notify_date !=.
	
	//Notification date registered? for table
	gen vph_notify_date_reg = 0 if vph_positive_1_year == 1 & vph_screen_res_notify !=.
	replace vph_notify_date_reg = 1 if vph_positive_1_year == 1 & vph_screen_res_notify_when != ""
	
	//If result positive, evidence woman received result		
	gen vph_notify_received = 0 if vph_positive_1_year == 1 & vph_screen_res_notify !=.
	replace vph_notify_received = 1 if vph_positive_1_year == 1 & vph_screen_res_notify_conf == 1
	
	// All requirements for positive result in past year met?
	gen vph_positive_pass = 0 if  vph_positive_1_year == 1 & vph_notify_within_30days !=. & vph_notify_received !=.
	replace vph_positive_pass = 1 if vph_positive_1_year == 1 & vph_notify_within_30days == 1 & vph_notify_received == 1
	
	//Overall VPH pass?
	gen vph_pass = 0 if any_vph == 1
	replace vph_pass = 1 if vph_negative_5_years == 1 | vph_positive_pass == 1
	
	
//IVAA: Negative result within last 3 years OR ( positive result within past year + notification within 30 days + evidence result was received )
	//Any IVAA?
	gen any_ivaa = 0 if cacx_screen_type != ""
	replace any_ivaa = 1 if cacx_screen_type_ivaa == 1

	//Format date
	gen ivaa_date = date(ivaa_screen_date_1, "YMD")
	
	//Screening data registered
	gen ivaa_date_reg = 0 if any_ivaa == 1
	replace ivaa_date_reg = 1 if any_ivaa == 1 & ivaa_date !=.

	//Within 3 years
	gen ivaa_date_within_3year = 0 if ivaa_date_reg !=.
	replace ivaa_date_within_3year = 1 if ivaa_date >= record_date - ( 365.25 * 3 ) & ivaa_date !=.
	//Within 1 year
	gen ivaa_date_within_1year = 0 if ivaa_date_reg !=.
	replace ivaa_date_within_1year = 1 if ivaa_date >= record_date - 365 & ivaa_date !=. & record_date !=.
	
	//Negative within 3 years
	gen ivaa_negative_3_years = 0 if ivaa_date_within_3year == 1 & ivaa_screen_lab !=.
	replace ivaa_negative_3_years = 1 if ivaa_date_within_3year == 1 & ivaa_screen_res == 0
	
	//Positive within 1 year
	gen ivaa_positive_1_year = 0 if ivaa_date_within_1year == 1 & ivaa_screen_lab !=.
	replace ivaa_positive_1_year = 1 if ivaa_date_within_1year == 1 & ivaa_screen_res == 1
	
	//Result not registered
	gen ivaa_result_nr = 0 if ivaa_screen_lab !=.
	replace ivaa_result_nr = 1 if ivaa_screen_res == -1 | ivaa_screen_lab == 0


	//If result positive, notification date within 30 days of screening
	tostring ivaa_screen_res_notify_when, replace
	gen ivaa_notify_date = date(ivaa_screen_res_notify_when, "YMD")
	gen ivaa_notify_within_30days = 0 if ivaa_positive_1_year == 1
	replace ivaa_notify_within_30days = 1 if ivaa_positive_1_year == 1 & ivaa_notify_date >= ivaa_date - 30 & ivaa_date !=. & ivaa_notify_date !=.
	
	//Notification date registered? for table
	gen ivaa_notify_date_reg = 0 if ivaa_positive_1_year == 1 & ivaa_screen_res_notify !=.
	replace ivaa_notify_date_reg = 1 if ivaa_positive_1_year == 1 & ivaa_screen_res_notify_when != ""
	
	//If result positive, evidence woman received result		
	gen ivaa_notify_received = 0 if ivaa_positive_1_year == 1 & ivaa_screen_res_notify !=.
	replace ivaa_notify_received = 1 if ivaa_positive_1_year == 1 & ivaa_screen_res_notify_conf == 1
	
	// All requirements for positive result in past year met?
	gen ivaa_positive_pass = 0 if  ivaa_positive_1_year == 1 & ivaa_notify_within_30days !=. & ivaa_notify_received !=.
	replace ivaa_positive_pass = 1 if ivaa_positive_1_year == 1 & ivaa_notify_within_30days == 1 & ivaa_notify_received == 1

	//Overall ivaa pass?
	gen ivaa_pass = 0 if any_ivaa == 1
	replace ivaa_pass = 1 if ivaa_negative_3_years == 1 | ivaa_positive_pass == 1	

// PAP: three negative cytologies in the previous 4 years OR ( positive result within past year + notification within 30 days + evidence result was received )

	//Create a variable to determine if the PAP result is positive/negative
	/* Se considera un resultado positivo
		•	Lesión Escamosa intraepitelial de Bajo Grado (LEIBG) 
		•	Lesión escamosa intraepitelial de Alto Grado (LEIAG)
		•	Lesión intraepitelial de Alto Grado con sospecha de invasión 
		•	Carcinoma de Células Escamosas invasor 
		•	Atipia glandular sin otra especificación (NICS) 
		•	Atipia glandular no se descarta neoplasia endocervical 
		•	Atipia glandurlar no se descarta neoplasia endometrial 
		•	Adenocarcinoma in situ (AIS) 
		•	Adenocarcinoma invasor  */
		
	replace pap_screen_anomaly_nomal = 1 if pap_screen_res == 1	
	gen pap_result = 0 if pap_screen_anomaly_nomal == 1
	replace pap_result = 1 if pap_screen_anomaly_leibg == 1 | pap_screen_anomaly_leiag == 1 | pap_screen_anomaly_leisos == 1 | pap_screen_anomaly_carcin == 1 | pap_screen_anomaly_nos == 1 | pap_screen_anomaly_atcerv == 1 | pap_screen_anomaly_atmetr == 1 | pap_screen_anomaly_ais == 1 | pap_screen_anomaly_ainv == 1 | pap_screen_anomaly_otro == 1

	//Any PAP?
	gen any_pap = 0 if cacx_screen_type != ""
	replace any_pap = 1 if cacx_screen_type_pap == 1

	// Format Date (for most recent visit only)
	gen pap_date = date(pap_screen_date_1, "YMD")
	
	//Screening data registered
	gen pap_date_reg = 0 if any_pap == 1
	replace pap_date_reg = 1 if any_pap == 1 & pap_date !=.
	
	//Within 4 years
	gen pap_date_within_4year = 0 if pap_date_reg !=.
	replace pap_date_within_4year = 1 if pap_date >= record_date - ( 365.25 * 4 ) & pap_date !=.
	//Within 1 year
	gen pap_date_within_1year = 0 if pap_date_reg !=.
	replace pap_date_within_1year = 1 if pap_date >= record_date - 365 & pap_date !=. & record_date !=.
	
	//Negative within 1 years
	gen pap_negative_1_year = 0 if pap_date_within_1year == 1 & pap_screen_lab !=.
	replace pap_negative_1_year = 1 if pap_date_within_1year == 1 & pap_result == 0
	
	//Negative within 4 years
	gen pap_negative_4_years = 0 if pap_date_within_4year == 1 & pap_screen_lab !=.
	replace pap_negative_4_years = 1 if pap_date_within_4year == 1 & pap_result == 0
	
	// 3 or more results (cannot verify what results were except for most recent)
	gen three_or_more_pap = 0 if  pap_negative_4_years == 1 & pap_date_within_1year == 0 & pap_screen_lab !=.
	replace three_or_more_pap = 1 if  pap_negative_4_years == 1 & pap_date_within_1year == 0 & pap_screen_lab_num_text >= 3 & pap_screen_lab_num_text !=.
	
	// All requirements for negative result in past 4 years met?
	gen pap_negative_pass = 0 if pap_negative_4_years == 1
	replace pap_negative_pass = 1 if three_or_more_pap == 1 | pap_negative_1_year == 1
	
	//Positive within 1 year
	gen pap_positive_1_year = 0 if pap_date_within_1year == 1 & pap_screen_lab !=.
	replace pap_positive_1_year = 1 if pap_date_within_1year == 1 & pap_result == 1
	
	//Result not registered
	gen pap_result_nr = 0 if pap_screen_lab !=.
	replace pap_result_nr = 1 if pap_screen_res == -1

	//If result positive, notification date within 30 days of date result received from lab
	tostring pap_screen_lab_rep_date, replace
	gen pap_result_date = date(pap_screen_lab_rep_date, "YMD")
	replace pap_result_date = pap_date if pap_result_date ==.
	
	tostring pap_screen_res_notify_when, replace
	gen pap_notify_date = date(pap_screen_res_notify_when, "YMD")
	
	gen pap_notify_within_30days = 0 if pap_positive_1_year == 1
	replace pap_notify_within_30days = 1 if pap_positive_1_year == 1 & pap_notify_date >= pap_result_date - 30 & pap_result_date !=. & pap_notify_date !=.
	
	//Notification date registered? for table
	gen pap_notify_date_reg = 0 if pap_positive_1_year == 1 & pap_screen_res_notify !=.
	replace pap_notify_date_reg = 1 if pap_positive_1_year == 1 & pap_screen_res_notify_when != ""
	
	//If result positive, evidence woman received result		
	gen pap_notify_received = 0 if pap_positive_1_year == 1 & pap_screen_res_notify !=.
	replace pap_notify_received = 1 if pap_positive_1_year == 1 & pap_screen_res_notify_conf == 1
	
	// All requirements for positive result in past year met?
	gen pap_positive_pass = 0 if  pap_positive_1_year == 1 & pap_notify_within_30days !=. & pap_notify_received !=.
	replace pap_positive_pass = 1 if pap_positive_1_year == 1 & pap_notify_within_30days == 1 & pap_notify_received == 1

	//Overall pap pass?
	gen pap_pass = 0 if any_pap == 1
	replace pap_pass = 1 if pap_negative_pass == 1 | pap_positive_pass == 1	
	
	
// INDICATOR CALCULATION ************************************************************
	gen I6005 = 0 if cacx_screen_type !=""
	replace I6005 = 1 if vph_pass == 1 | ivaa_pass == 1 | pap_pass == 1
	
	// Indicator value
	prop I6005 if time == "evaluation" & tx_area == 1	
