************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// October 2022 - IHME
// Nicaragua Performance Indicator 1060
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// ANEMIA PREVALENCE (1060)
// bring in module 3 data
	use "IHME_SMI_NIC_HHS_2022_MOD3_Y2023M08D17.dta", clear

// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"
	
***********************************************************************************
**  Indicator 1060: Hemoglobin <110g/L, children 6-23mo
***********************************************************************************

*5. Anemia
	destring kid_hgb, replace
	gen anemic_ = 0
	replace anemic_ = 1 if kid_hgb<11 & (altitud<1000 | altitud ==.)
    replace anemic_ = 1 if kid_hgb<11.2 & altitud>=1000 & altitud<1250
    replace anemic_ = 1 if kid_hgb<11.5 & altitud>=1250 & altitud<1750
    replace anemic_ = 1 if kid_hgb<11.8 & altitud>=1750 & altitud<2250
    replace anemic_ = 1 if kid_hgb<12.3 & altitud>=2250 & altitud<2750
    replace anemic_ = 1 if kid_hgb<12.9 & altitud>=2750 & altitud<3250
    replace anemic_ = 1 if kid_hgb<13.7 & altitud>=3250 & altitud<3750
    replace anemic_ = 1 if kid_hgb<14.5 & altitud>=3750 & altitud<4250
    replace anemic_ = 1 if kid_hgb<15.5 & altitud>=4250 & altitud<4750
    replace anemic_ = 1 if kid_hgb<16.5 & altitud>=4750 & altitud<5250
    replace anemic_ = 1 if kid_hgb<17.7 & altitud>=5250 & altitud !=.
    replace anemic_=. if kid_hgb==.

// INDICATOR CALCULATION ************************************************************
	svyset wtSEG [pweight=weight_child], strata(tx_area) 
	di in red _newline "Indicator: Prevalence of anemia (6-23 months)"
	tab anemic_ tx_area if kid_age_mo>=6 & kid_age_mo<24
	svy, subpop(if  kid_age_mo>=6 & kid_age_mo<24): prop anemic_, over(tx_area)	
******************	
