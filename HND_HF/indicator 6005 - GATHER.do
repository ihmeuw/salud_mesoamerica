************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Honduras Performance Indicator 6005
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// CERVICAL CANCER SCREENING RECORDS (6005)
	use "IHME_SMI_HND_HFS_2022_CACX_Y2023M08D17.dta", clear
	
****************************************************************************************************
//  Indicator 6005 - Quality screening for early detection of cervical cancer
****************************************************************************************************

// Ambulatory facilities only
	keep if cone == 1
	
{ //Date restrictions 
	gen record_date = date(cacx_visit_date, "YMD")
	replace record_date = date(pap_screen_date_1, "YMD") if date(pap_screen_date_1, "YMD") > date(cacx_visit_date, "YMD") & date(cacx_visit_date, "YMD") !=. & date(pap_screen_date_1, "YMD") !=.
	cap gen time =""
	
	//*Evaluation* period date range (4/1/2022	- 6/30/2022) - past year
	replace time = "evaluation" if record_date >= date("2021-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//Keep only eligible records
	drop if time != "evaluation"
}

//Denominator: Expedientes de mujeres de 24 a 64 años en la muestra en el último año
	tab age_final,m
	keep if age_final >= 24 & age_final <= 64 & age_final !=.
	
//Check screening type
	tab cacx_screen_type,m
	drop if cacx_screen_type == "PAP" & pap_screen_num ==.	
	
	
// PAP: 2 negative cytologies in the previous 3 years OR ( positive result within past year + notification within 8 weeks + evidence result was received )
	//Create a variable to determine if the PAP result is positive/negative
	/* Se considera un resultado positivo
		•	a.	Koilocitos (células atípicas) [NOT INCLUDED IN RESPONSE OPTIONS]
		•	b.	ASCUS (Atypical Squamous Cells of Undetermined Significance) Cambios atípicos en las células escamosas del cuello uterino. 
		•	c.	AGUS (Atypical Glandular Cells of Undetermined Significance)  cambios en las células glandulares. 
		•	d.	LEIBG (NIC-I) Lesión escamosa Intra-epitelial de bajo grado
		•	e.	LEIAG (NIC-II / NIC-III) Lesión escamosa Intra-epitelial de alto grado
		•	f.	Ca in Situ (NIC-III)
		•	g.	Ca. Invasor
		•	h.	Ca. Epidermoide  
		•   i. 'Carcinoma de Células Escamosas invasor' [added per email request] */
		
	//Any PAP?
	gen any_pap = 0 if cacx_screen_type != ""
	replace any_pap = 1 if cacx_screen_type_pap == 1
	
	// Loop through all pap visits
	tab pap_screen_num,m	
	forvalues x = 1/6{
		//Date of screening
		gen pap_date_`x' = date(pap_screen_date_`x', "YMD")
	
		// Result of PAP screening
		gen pap_result_`x' = -1 if pap_screen_anomaly_noreg_`x' == 1
		replace pap_result_`x' = 0 if pap_screen_anomaly_nomal_`x' !=.
		replace pap_result_`x' = 1 if  pap_screen_anomaly_ascus_`x' == 1 | pap_screen_anomaly_agus_`x' == 1 | pap_screen_anomaly_leibg_`x' == 1 | pap_screen_anomaly_leiag_`x' == 1 |pap_screen_anomaly_ais_`x' == 1 | pap_screen_anomaly_ainv_`x' == 1 | pap_screen_anomaly_aepi_`x' == 1 | pap_screen_anomaly_carcin_`x' == 1
		
		// At least one positive/negative result in the past year?
		cap gen alo_pos_neg_pap_past_year = 0 if any_pap == 1
		replace alo_pos_neg_pap_past_year = 1 if ( pap_result_`x' == 0 | pap_result_`x' == 1 ) & pap_date_`x' >= record_date - 365.25 & pap_date_`x' !=. & record_date !=.
		
		//Negative in past year
		cap gen neg_pap_past_year = 0 if any_pap == 1
		replace neg_pap_past_year = 1 if pap_result_`x' == 0 & pap_date_`x' >= record_date - 365.25 & pap_date_`x' !=. & record_date !=.
		
		//Positive in past year
		cap gen pos_pap_past_year = 0 if any_pap == 1
		replace pos_pap_past_year = 1 if pap_result_`x' == 1 & pap_date_`x' >= record_date - 365.25 & pap_date_`x' !=. & record_date !=.
		
		//Positive at given visit
		gen pos_result_`x' = 1 if pap_result_`x' == 1 & pap_date_`x' >= record_date - 365.25 & pap_date_`x' !=. & record_date !=.
		
		//If result positive, notification date within 8 weeks
		//Notification date
		gen pap_notify_date_`x' = date(pap_screen_res_notify_date_`x', "YMD")
		
		//Within 8 weeks
		cap gen pap_notify_within_8_weeks =.
		replace pap_notify_within_8_weeks = 0 if pos_result_`x' == 1
		replace pap_notify_within_8_weeks = 1 if pos_result_`x' == 1 & pap_notify_date_`x' <= pap_date_`x' + 56 & pap_date_`x' !=. & pap_notify_date_`x' !=.
		
		//If result positive, evidence woman received result		
		cap gen pap_notify_received =.
		replace pap_notify_received = 0 if pos_result_`x' == 1
		replace pap_notify_received = 1 if pos_result_`x' == 1 & pap_screen_res_notify_`x' == 1
	}	
	
	// Number of positive results in past year
	egen num_pos_past_year = anycount(pos_result_*), value(1) 
	
	// Overall requirements for positive result in past year met
	gen pap_positive_pass = 0 if  num_pos_past_year == 1 
	replace pap_positive_pass = 1 if num_pos_past_year == 1 & pap_notify_within_8_weeks == 1 & pap_notify_received == 1
	

	// If nothing in past year, at least 2 negative reults in the past 3 years
	//Loop over each pap visit
	forvalues x = 1/6{
	//Negative result at given visit
		gen neg_result_`x' = 1 if pap_result_`x' == 0 & pap_date_`x' >= record_date - 365.25 * 3 & pap_date_`x' !=. & record_date !=.
	}
	// Use date and result of previous visit if given visit date is missing
	forvalues x = 5 (-1) 1 {
		local y = `x' + 1
		replace neg_result_`x' = 1 if neg_result_`y' == 1 & pap_date_`x' == .

	}
	// Total number of negative visits in past three years
	egen num_neg_past_3_years = anycount(neg_result_*), value(1) 
	
	// Two or more negative pap results in past three years
	gen two_neg_pap_past_3_year = 0 if alo_pos_neg_pap_past_year == 0
	replace two_neg_pap_past_3_year = 1 if alo_pos_neg_pap_past_year == 0 & num_neg_past_3_years >= 2 & num_neg_past_3_years !=.
	
	//Overall pap pass?
	gen pap_pass = 0 if any_pap == 1 
	replace pap_pass = 1 if neg_pap_past_year == 1 | pap_positive_pass == 1	| two_neg_pap_past_3_year == 1
	
	
//IVAA: Negative result within last 3 years OR ( positive result within past year + notification on same day + evidence result was received )
	//Any IVAA?
	gen any_ivaa = 0 if cacx_screen_type != ""
	replace any_ivaa = 1 if cacx_screen_type_ivaa == 1

	//Format date
	tostring ivaa_screen_date_1, replace
	gen ivaa_date = date(ivaa_screen_date_1, "YMD")
	
	//Screening data registered
	gen ivaa_date_reg = 0 if any_ivaa == 1
	replace ivaa_date_reg = 1 if any_ivaa == 1 & ivaa_date !=.
	
	//NOTE: Only one record contained evidence of an IVAA screening, and the date of the screening was not recorded. This means that the IVAA screening cannot pass the indicator as the date is required to evaluate subsequent requirements.
	
//VPH: Negative result within last 5 years OR ( positive result within past year + notification within 8 weeks + evidence result was received )
	//Any VPH?
	gen any_vph = 0 if cacx_screen_type != ""
	replace any_vph = 1 if cacx_screen_type_vph == 1 //NONE!
	
	//NOTE: No evidence of VPH screenings present in any observations of the data.
	
	
// No evidence of screening - these fail (for tables)
	gen no_screening = 0 if cacx_screen_type !=""
	replace no_screening = 1 if cacx_screen_type_none == 1

	
// INDICATOR CALCULATION ************************************************************
	gen I6005 = 0 if cacx_screen_type !=""
	replace I6005 = 1 if pap_pass == 1 //| ivaa_pass == 1 | vph_pass == 1
	
	//NOTE: Because there was only 1 IVAA screening that failed on the grounds of the date not being recorded, and because no VPH screenings were captured, only PAP screenings can pass the indicator.

	// Indicator value
	prop I6005 if time == "evaluation" & tx_area == 1	
	
	