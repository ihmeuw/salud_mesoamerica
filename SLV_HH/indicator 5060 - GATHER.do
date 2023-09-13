************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// January 2023 - IHME
// El Salvador Performance Indicator 5060
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// DIARRHEA TREATMENT (5060)
// bring in module 2C data
	use "IHME_SMI_SLV_HHS_2022_MOD2C_Y2023M08D17.dta", clear

// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"
	
***********************************************************************************
**  Indicator 5060: Diarrhea treatment with ORS/zinc, age 6-59mo
***********************************************************************************
	
	gen diarrhea_2w_=.
	replace diarrhea_2w=1 if diarrhea1==1|diarrhea1==2 // presence of diarrhea with or without blood
	replace diarrhea_2w=0 if diarrhea1==0

	gen ors_any_=.
	replace ors_any=1 if diarrhea_drink1==1|diarrhea_drink2==1|diarrhea_drink3==1 // use of ORS
	replace ors_any=0 if diarrhea_drink1==0&diarrhea_drink2==0&diarrhea_drink3==0
		
		
	gen zinc_=. //use of zinc
	replace zinc=1 if diarrhea_rx3==1 // for SLV, zinc pill/syrup are combined under rx3; in other countries one is a pill and the other is syrup. 
	replace zinc=0 if diarrhea_rx3==0 
		
	gen zinc_ors_=.
	replace zinc_ors=1 if ors_any==1&zinc_==1
	replace zinc_ors=0 if ors_any==0|zinc_==0

****************** Weighted indicator result
	svyset wtSEG [pweight=weight_child], strata(tx_area)  
	n di in red _newline "Indicator: Proportion of children 6mo+ receiving ORS & zinc for the most recent bout of diarrhea in the past 2 weeks"
	tab tx_area zinc_ors if (diarrhea1==1|diarrhea1==2 ) & kid_age_mo>=6 & kid_age_mo<60
	n svy, subpop(if (diarrhea1==1|diarrhea1==2 ) & kid_age_mo>=6 & kid_age_mo<60): prop zinc_ors, over(tx_area)	
******************	
