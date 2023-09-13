************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Nicaragua Performance Indicator 3040
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// ANTENATAL CARE RECORDS (3040)
	use "IHME_SMI_NIC_HFS_2022_NOCOMP_Y2023M08D17.dta", clear
	
***********************************************************************************
// Indicator 3040: Women of reproductive age who received their first prenatal visit before 12 weeks gestation in in the last two years
***********************************************************************************

// Denominator : Medical record review (no complications record which include antenatal care)
	keep if mrr_records_anc==1 
	drop if mrr_anc_num_spec == .
	
	// Ambulatory facilities only
	keep if cone == 1

{ //Date restrictions
	gen record_date = date(lmp_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (date of last menstrual period) (7/1/2020 - 9/26/2021)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2021-9-26", "YMD")
	
	//*Pre-evaluation* period date range (date of last menstrual period) (1/1/2019 - 9/26/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2019-9-26", "YMD")

	//Keep only eligible records
	drop if time == ""
}		

// Drop if outside age range
	drop if ( mrr_age_spec <=13 | mrr_age_spec > 49 ) & mrr_age_spec !=.
		
// Numerator: Number of women who received their first prenatal visit before 12 weeks gestation in the last two years

// INDICATOR CALCULATION *****************************************************************************************************	
	gen I3040 = 0 if mrr_anc_con_gestage_spec_1 != .
	replace I3040 = 1 if mrr_anc_con_gestage_spec_1 <=12 & mrr_anc_con_gestage_spec_1 !=.
	
	*// Indicator value
	prop I3040 if time == "evaluation" & tx_area == 1
	prop I3040 if time == "pre-evaluation" & tx_area == 1
	