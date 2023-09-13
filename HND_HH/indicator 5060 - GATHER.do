************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// February 2023 - IHME
// Honduras Performance Indicator 5060
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// DIARRHEA TREATMENT (5060)
// bring in module 2C data
	use "IHME_SMI_HND_HHS_2022_MOD2C_Y2023M08D17.dta", clear

// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"
	
***********************************************************************************
**  Indicator 5060: Diarrhea treatment with ORS/zinc
***********************************************************************************
	
	gen diarrhea_2w_=.
	replace diarrhea_2w=1 if diarrhea1==1|diarrhea1==2 // presence of diarrhea with or without blood
	replace diarrhea_2w=0 if diarrhea1==0

	gen ors_any_=.
	replace ors_any=1 if diarrhea_drink1==1|diarrhea_drink2==1|diarrhea_drink3==1 // use of ORS
	replace ors_any=0 if diarrhea_drink1==0&diarrhea_drink2==0&diarrhea_drink3==0
		
		
	gen zinc_=.
	replace zinc=1 if diarrhea_rx3==1|diarrhea_rx13==1 // use of zinc
	replace zinc=0 if diarrhea_rx3==0&diarrhea_rx13==0
		
	gen zinc_ors_=.
	replace zinc_ors=1 if ors_any==1&zinc_==1
	replace zinc_ors=0 if ors_any==0|zinc_==0

// INDICATOR CALCULATION ************************************************************
	svyset wtSEG [pweight=weight_child], strata(tx_area)  
	di in red _newline "Indicator: Proportion of children 0mo+ receiving ORS & zinc for the most recent bout of diarrhea in the past 2 weeks"
	tab tx_area zinc_ors if diarrhea1==1|diarrhea1==2
	svy, subpop(if diarrhea1==1|diarrhea1==2): prop zinc_ors, over(tx_area)	
******************	
