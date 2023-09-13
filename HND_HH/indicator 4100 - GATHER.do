************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// February 2023 - IHME
// Honduras Performance Indicator 4100
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// POSTNATAL CARE WITHIN 72 HOURS (4100)
// bring in module 2B data
	use "IHME_SMI_HND_HHS_2022_MOD2B_Y2023M08D17.dta", clear
	
// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"

// Rename variables
ren pp_checkbaby pp_check12
ren pp_checkbaby_1_who pp_check10

// Recreate ppcheck*_baby_time_days
	forvalues x=1/8 {
		cap gen ppcheck`x'_baby_time_days_ = .
		replace ppcheck`x'_baby_time_days = pp_checkbaby_`x'_when_hr/24 if pp_checkbaby_`x'_when==1
		replace ppcheck`x'_baby_time_days = pp_checkbaby_`x'_when_day if pp_checkbaby_`x'_when==2
		replace ppcheck`x'_baby_time_days = pp_checkbaby_`x'_when_wk*7 if pp_checkbaby_`x'_when==3
	}

// Recreate pp_babycheck_*_who
	foreach num of numlist 1/8 {
		cap gen pp_babycheck_who_`num' = pp_checkbaby_`num'_who // "¿Quién revisó la salud de ${KID_NAME} en ese momento?"
		cap replace pp_babycheck_who_`num' = pp_checkbaby_`num'_who  // "¿Quién revisó la salud de ${KID_NAME} en ese momento?"
		cap gen pp_babycheck_where_`num' = pp_checkbaby_`num'_where  // "¿Quién revisó la salud de ${KID_NAME} en ese momento?"
		cap replace pp_babycheck_where_`num' = pp_checkbaby_`num'_where  // "¿Quién revisó la salud de ${KID_NAME} en ese momento?"
		cap gen pp_babycheck_`num'_when_hr = pp_checkbaby_`num'_when_hr 
		cap replace pp_babycheck_`num'_when_hr = pp_checkbaby_`num'_when_hr 
		cap gen pp_babycheck_`num'_when_day = pp_checkbaby_`num'_when_day 
		cap replace pp_babycheck_`num'_when_day = pp_checkbaby_`num'_when_day 
		cap gen pp_babycheck_`num'_when_wk = pp_checkbaby_`num'_when_wk 
		cap replace pp_babycheck_`num'_when_wk = pp_checkbaby_`num'_when_wk
		cap gen pp_babycheck_`num'_when = pp_checkbaby_`num'_when 
		cap replace pp_babycheck_`num'_when = pp_checkbaby_`num'_when 
	}

	
***********************************************************************************
**  Indicator 4100: Postnatal care for neonate within 72 hours of birth by skilled personnel (Dr, nurse, aux nurse)
***********************************************************************************

	gen mostrecentbirth_last2yrs = lb_last2years ==1 & lb_mostrecent==1	 

	
	gen baby_ppcheck_3_skilled_aux_  = 0 
	replace baby_ppcheck_3_skilled_aux_ = . if pp_check12==-1 | pp_check12==-2 | pp_check12==.
	replace baby_ppcheck_3_skilled_aux_ = 1 if pp_check12==1 & ( (ppcheck1_baby_time_days<3 & (pp_check10==1 | pp_check10==2 | pp_check10==3)) | ///
	(ppcheck2_baby_time_days<3 & (pp_babycheck_who_2==1 | pp_babycheck_who_2==2 | pp_babycheck_who_2==3)) | ///
	(ppcheck3_baby_time_days<3 & (pp_babycheck_who_3==1 | pp_babycheck_who_3==2 | pp_babycheck_who_3==3)) | ///
	(ppcheck4_baby_time_days<3 & (pp_babycheck_who_4==1 | pp_babycheck_who_4==2 | pp_babycheck_who_4==3)) | ///
	(ppcheck5_baby_time_days<3 & (pp_babycheck_who_5==1 | pp_babycheck_who_5==2 | pp_babycheck_who_5==3)) | ///
	(ppcheck6_baby_time_days<3 & (pp_babycheck_who_6==1 | pp_babycheck_who_6==2 | pp_babycheck_who_6==3)) | ///
	(ppcheck7_baby_time_days<3 & (pp_babycheck_who_7==1 | pp_babycheck_who_7==2 | pp_babycheck_who_7==3)) | ///
	(ppcheck8_baby_time_days<3 & (pp_babycheck_who_8==1 | pp_babycheck_who_8==2 | pp_babycheck_who_8==3)) )
	replace baby_ppcheck_3_skilled_aux_ = . if pp_nicu==1
	la var baby_ppcheck_3_skilled_aux_ "skilled, including aux, within 3 days: new monitoring indicator 36, NEW PAYMENT INDICATOR 54"
	
	
// INDICATOR CALCULATION ************************************************************
	cap rename wtseg wtSEG
	svyset wtSEG [pweight=weight_woman], strata(tx_area) 
	
	di in red _newline "Indicator: Skilled postnatal care within 72 hours"
	svy, subpop(if lb_last2years==1): prop baby_ppcheck_3_skilled_aux_ , over(tx_area)	
	tab tx_area baby_ppcheck_3_skilled_aux_ if  lb_last2years==1	

	******************		
	
	