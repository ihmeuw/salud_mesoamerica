************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// October 2022 - IHME
// Nicaragua Performance Indicator 4030
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// POSTPARTUM CARE WITHIN 10 DAYS (4030)
// bring in module 2B data
	use "IHME_SMI_NIC_HHS_2022_MOD2B_Y2023M08D17.dta", clear
	
// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"

// Recreate variables
cap drop ppcheck1_mom_time_days_
gen ppcheck1_mom_time_days_  = . 
replace ppcheck1_mom_time_days = pp_checkmom_1_when_hr/24 if pp_checkmom_1_when==1
replace ppcheck1_mom_time_days = pp_checkmom_1_when_day if pp_checkmom_1_when==2
replace ppcheck1_mom_time_days = pp_checkmom_1_when_wk*7 if pp_checkmom_1_when==3

forvalues x=2/8 {
		cap drop ppcheck`x'_mom_time_days_
		gen ppcheck`x'_mom_time_days_ = .

		replace ppcheck`x'_mom_time_days = pp_checkmom_`x'_when_hr/24 if pp_checkmom_`x'_when==1
		replace ppcheck`x'_mom_time_days = pp_checkmom_`x'_when_day if pp_checkmom_`x'_when==2
		replace ppcheck`x'_mom_time_days = pp_checkmom_`x'_when_wk*7 if pp_checkmom_`x'_when==3
	}
	
replace ppcheck1_mom_time_days = . if ppcheck1_mom_time_days<0
	
***********************************************************************************
**  Indicator 4030: Postpartum care within 10 days of delivery by skilled personnel (Dr, nurse, auxiliary nurse)
***********************************************************************************
	
	gen mostrecentbirth_last2yrs = lb_last2years ==1 & lb_mostrecent==1 //only most recent birth in the last 2 years included in the indicator definition
	
*Postpartum care
	gen mom_ppcheck_10_skilled_  = 0 
	replace mom_ppcheck_10_skilled_ = . if pp_checkmom==-1 | pp_checkmom==-2 | pp_checkmom==.
	replace mom_ppcheck_10_skilled_ = 1 if pp_checkmom==1 & ( (ppcheck1_mom_time_days<10 & (pp_checkmom_1_who==1 | pp_checkmom_1_who==2 | pp_checkmom_1_who==3)) | ///
	(ppcheck2_mom_time_days<10 & (pp_checkmom_2_who==1 | pp_checkmom_2_who==2 | pp_checkmom_2_who==3)) | ///
	(ppcheck3_mom_time_days<10 & (pp_checkmom_3_who==1 | pp_checkmom_3_who==2 | pp_checkmom_3_who==3)) | ///
	(ppcheck4_mom_time_days<10 & (pp_checkmom_4_who==1 | pp_checkmom_4_who==2 | pp_checkmom_4_who==3)) | ///
	(ppcheck5_mom_time_days<10 & (pp_checkmom_5_who==1 | pp_checkmom_5_who==2 | pp_checkmom_5_who==3)) | ///
	(ppcheck6_mom_time_days<10 & (pp_checkmom_6_who==1 | pp_checkmom_6_who==2 | pp_checkmom_6_who==3)) | ///
	(ppcheck7_mom_time_days<10 & (pp_checkmom_7_who==1 | pp_checkmom_7_who==2 | pp_checkmom_7_who==3)) | ///
	(ppcheck8_mom_time_days<10 & (pp_checkmom_8_who==1 | pp_checkmom_8_who==2 | pp_checkmom_8_who==3)) )
	la var mom_ppcheck_10_skilled_ "within 10 days with skilled provider"

**** Also allowed in definition: Checked after delivery before leaving the health facility 	
	gen mom_ppcheck_10_or_del_check_ = mom_ppcheck_10_skilled_
	replace mom_ppcheck_10_or_del_check_ = 1 if del_check ==1 
	
// INDICATOR CALCULATION ************************************************************
	svyset wtSEG [pweight=weight_woman], strata(tx_area)  
	di in red _newline "Indicator: Women (age 15-49) who received postpartum care within 10 days with skilled personnel in their most recent pregnancy in the last two years"
	svy, subpop(if mostrecentbirth_last2yrs==1): prop mom_ppcheck_10_or_del_check_, over(tx_area)	
	tab tx_area mom_ppcheck_10_or_del_check_ if mostrecentbirth_last2yrs==1
********************	
