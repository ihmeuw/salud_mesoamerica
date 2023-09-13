************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 2500
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// POSTPARTUM RECORDS (2500)
	use "IHME_SMI_SLV_HFS_2022_NOCOMP_Y2023M08D17.csv", clear

******************************************************************************************
// Indicator 2500: Postpartum contraception administration
******************************************************************************************
	
// Denominator: Medical record review (no complications record which include immediate postpartum care)
	keep if mrr_records_ppm == 1 
	
// Basic/complete facilities only
	keep if cone == 2 | cone == 3

// Restrict to live births
	keep if mrr_pos_out == 1
	
// Exclude if patient was referred
	drop if mrr_app_fp == 3	
	

{ //Date restrictions: delivery in the past year 
	gen record_date = date(mrr_del_adm_date_spec, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (admission date) (7/1/2021 - 6/30/2022)
	replace time = "evaluation" if record_date >= date("2021-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (admission date) (1/1/2019 - 12/31/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2019-12-31", "YMD")

	//Keep only eligible records
	drop if time == ""
}		
	
// Acceptable contraceptives: esterilización quirúrgica, DIU, implante, anticonceptivo oral sólo de progestina o inyectable sólo de progestina
	foreach var in injprog ocpprog imp iud tub {
		rename mrr_name_fp_`var' `var'
	}

// INDICATOR CALCULATION ************************************************************		
	gen I2500 = 0 if mrr_app_fp !=.
	replace I2500 = 1 if injprog == 1 | ocpprog == 1 | imp == 1 | iud == 1 | tub == 1 
	
	// indicator value
	prop I2500 if time == "evaluation" & tx_area == 1
	prop I2500 if time == "pre-evaluation" & tx_area == 1
