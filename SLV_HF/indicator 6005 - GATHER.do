************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 6005
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// CERVICAL CANCER SCREENING RECORDS (6005)
	use "IHME_SMI_SLV_HFS_2022_CACX_Y2023M08D17.dta", clear
	
****************************************************************************************************
// Indicator 6005: Women who underwent quality screening for early detection of cervical cancer
****************************************************************************************************

// Ambulatory facilities, excluding 'ECOS especializadas'
	keep if cone == 1
	keep if fac_type == 5 | fac_type == 6	
	
{ //Date restrictions 
	gen record_date = date(cacx_visit_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/1/2021	- 6/30/2022)
	replace time = "evaluation" if record_date >= date("2021-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//Keep only eligible records
	drop if time != "evaluation"
}

//Denominator:  Número total de expedientes de mujeres de 20 a 59 años en nuestra muestra: survey automatically excludes women outside the appropriate age range
	
// Exclude if the woman rejected screening and the record contains reason and signature/fingerprint
	drop if no_screen_reject == 1 & no_screen_reject_why == 1
	
// Exclude if there is written evidence that the woman has not initiated sexual intercourse (IRS)
	drop if no_screen_reject_irs == 1
	

//Numerator:

//Negative HPV test in the past 5 years
	//Any VPH?
	gen any_vph = 0 if cacx_screen_type != ""
	replace any_vph = 1 if cacx_screen_type_vph == 1

	//Within 5 years
	gen vph_date = date(vph_screen_date_1, "YMD")
	gen vph_date_within_5year = 0 if any_vph !=.
	replace vph_date_within_5year = 1 if vph_date >= record_date - ( 365.25 * 5 ) & vph_date !=.
	
	//Negative within 5 years
	gen vph_negative_5_years = 0 if any_vph !=.
	replace vph_negative_5_years = 1 if vph_date_within_5year == 1 & vph_screen_res == 0

// OR - At least one cervical cancer screening in the last two years
	//Any screening?
	gen any_cacx = 0 if cacx_screen_type != ""
	replace any_cacx = 1 if cacx_screen_type != "" & cacx_screen_type_no != 1
	
	//Within past 2 years
	gen any_cacx_date = date(cacx_recent_date, "YMD")
	gen cacx_date_within_2year = 0 if any_cacx !=.
	replace cacx_date_within_2year = 1 if any_cacx_date >= record_date - ( 365.25 * 2 ) & any_cacx_date !=.

	//If positive, evidence of delivery of results to the woman within 8 weeks and referral
	//Positive within 2 year
	gen cacx_positive_2_year = 0 if cacx_date_within_2year == 1 & (pap_screen_res !=. | vph_screen_res !=.)
	replace cacx_positive_2_year = 1 if cacx_date_within_2year == 1 & (pap_screen_res == 0 | vph_screen_res == 1 )
	
	//Evidence of result delivery within 8 weeks
	tostring vph_screen_res_notify_when pap_screen_res_notify_when, replace
	gen vph_notify_date = date(vph_screen_res_notify_when, "YMD")
	gen pap_notify_date = date(pap_screen_res_notify_when, "YMD")
	
	//Notification date
	gen cacx_notify_date = vph_notify_date if vph_notify_date !=. & ( pap_notify_date ==. | pap_notify_date <= vph_notify_date )
	replace cacx_notify_date = pap_notify_date if pap_notify_date !=. & ( vph_notify_date ==. | vph_notify_date <= pap_notify_date )
	
	//Within 8 weeks
	gen cacx_notify_within_8_weeks = 0 if cacx_positive_2_year == 1
	replace cacx_notify_within_8_weeks = 1 if cacx_positive_2_year == 1 & cacx_notify_date - any_cacx_date <= 56 & cacx_notify_date !=. & any_cacx_date !=.

	//Referral if positive
	gen cacx_ref = 0 if cacx_positive_2_year == 1 & (pap_screen_ref !=. | vph_screen_ref !=.)
	replace cacx_ref = 1 if cacx_positive_2_year == 1 & ( pap_screen_ref == 1 | vph_screen_ref == 1 )
	
// If the tests were performed in another facility, a copy of the result or a note of the result signed by a doctor must be part of the file (in case of a positive test, the management provided must be documented)	
	gen test_elsewhere_note = 0 if cacx_recent_where == 1 & cacx_recent_where_note !=.
	replace test_elsewhere_note = 1 if cacx_recent_where == 1 & ( cacx_recent_where_note == 1 | cacx_recent_where_note == 2 | cacx_recent_where_note == 4 )
	
	
// INDICATOR CALCULATION ************************************************************
	gen I6005 = 0 if cacx_screen_type !=""
	replace I6005 = 1 if ( vph_negative_5_years == 1 | cacx_date_within_2year == 1 ) & cacx_notify_within_8_weeks != 0 & cacx_ref != 0 & test_elsewhere_note != 0

	// Indicator value
	prop I6005 if time == "evaluation" & tx_area == 1
