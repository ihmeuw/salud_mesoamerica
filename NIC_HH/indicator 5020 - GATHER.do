************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// October 2022 - IHME
// Nicaragua Performance Indicator 5020
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// COMPLETE VACCINATION FOR AGE (5020)
// bring in module 2C data
	use "IHME_SMI_NIC_HHS_2022_MOD2C_Y2023M08D17.dta", clear

// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"

// MD: dt_ variables do not exist in the 54mo datasets and the code will not run unless those lines are commented out/removed from loops. When those are commented out the code runs successfully and reproduces the result reported in the memo.
	
***********************************************************************************
**  Indicator 5020: Complete vaccination for age according to vaccine card
***********************************************************************************
	
	cap drop *compliant_card_ rota_elig pneum_elig  
	*ren age_mo kid_age_mon
	
	
*Vaccination by card

	* In case any dates came in as numeric
	cap tostring *dose*date *boost*date, replace
	foreach v in bcg hepb pent dpt rota pneum flu mmr opv mr ipv {
		forvalues x=1/8 {
			cap replace `v'_dose`x'date="" if `v'_dose`x'date=="."
			cap replace `v'_boost`x'date="" if `v'_boost`x'date=="."
		}
	}
	
	* Count number of doses of each vaccine on vaccard
	cap egen bcg_num_ = anycount(bcg_dose1), values(1 2) 
	replace bcg_num_ = . if (bcg_dose1<0 | bcg_dose1==.) 

	cap drop opv_num 
	egen opv_num_ = anycount(ipv_dose1 opv_dose1 opv_dose2 opv_dose3 opv_boost1 opv_boost2 opv_boost3 opv_boost4), values(1 2) 
	replace opv_num_ = . if (ipv_dose1<0 | ipv_dose1==.) & (opv_dose1<0 | opv_dose1==.) & (opv_dose2<0 | opv_dose2==.) & (opv_dose3<0 | opv_dose3==.) & (opv_boost1<0 | opv_boost1==.) & (opv_boost2<0 | opv_boost2==.) & (opv_boost3<0 | opv_boost3==.) & (opv_boost4<0 | opv_boost4==.) 
	
	cap egen rota_num_ = anycount(rota_dose1 rota_dose2 rota_dose3), values(1 2) 
	replace rota_num_ = . if (rota_dose1<0 | rota_dose1==.) & (rota_dose2<0 | rota_dose2==.) & (rota_dose3<0 | rota_dose3==.) 
	
	cap egen pent_num_ = anycount(pent_dose1 pent_dose2 pent_dose3), values(1 2) 
	replace pent_num_ = . if (pent_dose1<0 | pent_dose1==.) & (pent_dose2<0 | pent_dose2==.) & (pent_dose3<0 | pent_dose3==.) 
	
	cap egen pneum_num_ = anycount(pneum_dose1 pneum_dose2 pneum_dose3), values(1 2) 
	replace pneum_num_ = . if (pneum_dose1<0 | pneum_dose1==.) & (pneum_dose2<0 | pneum_dose2==.) & (pneum_dose3<0 | pneum_dose3==.) 
	
	cap egen mmr_num_ = anycount(mmr_dose1), values(1 2) 
	replace mmr_num_ = . if (mmr_dose1<0 | mmr_dose1==.) 
	
	cap egen dpt_num_ = anycount(dpt_dose1 ), values(1 2) 
	replace dpt_num_ = . if (dpt_dose1<0 | dpt_dose1==.) 
	
	cap egen mr_num_ = anycount(mr_dose1), values(1 2) 
	replace mr_num_ = . if (mr_dose1<0 | mr_dose1==.) 
	
	*cap egen dt_num_ = anycount(dt_dose1 dt_dose2 dt_dose3 dt_boost1 dt_boost2 dt_boost3 dt_boost4), values(1 2) 
	*replace dt_num_ = . if (dt_dose1<0 | dt_dose1==.) & (dt_dose2<0 | dt_dose2==.) & (dt_dose3<0 | dt_dose3==.) & (dt_boost1<0 | dt_boost1==.) & (dt_boost2<0 | dt_boost2==.) & (dt_boost3<0 | dt_boost3==.) & (dt_boost4<0 | dt_boost4==.) 
	
	* mark if each vaccine type on vaccard was received
	cap egen bcg_any_ = anymatch(bcg_dose1), values(1 2) 
	replace bcg_any_ = . if (bcg_dose1<0 | bcg_dose1==.) 
	
	cap drop opv_any_ //need to add in IPV option
	egen opv_any_ = anymatch(ipv_dose1 opv_dose1 opv_dose2 opv_dose3 opv_boost1 opv_boost2 opv_boost3 opv_boost4), values(1 2) 
	replace opv_any_ = . if (ipv_dose1<0 | ipv_dose1==.) & (opv_dose1<0 | opv_dose1==.) & (opv_dose2<0 | opv_dose2==.) & (opv_dose3<0 | opv_dose3==.) & (opv_boost1<0 | opv_boost1==.) & (opv_boost2<0 | opv_boost2==.) & (opv_boost3<0 | opv_boost3==.) & (opv_boost4<0 | opv_boost4==.) 
	
	cap egen rota_any_ = anymatch(rota_dose1 rota_dose2 rota_dose3), values(1 2) 
	replace rota_any_ = . if (rota_dose1<0 | rota_dose1==.) & (rota_dose2<0 | rota_dose2==.) & (rota_dose3<0 | rota_dose3==.) 
	
	cap egen pent_any_ = anymatch(pent_dose1 pent_dose2 pent_dose3), values(1 2) 
	replace pent_any_ = . if (pent_dose1<0 | pent_dose1==.) & (pent_dose2<0 | pent_dose2==.) & (pent_dose3<0 | pent_dose3==.) 
	
	cap egen pneum_any_ = anymatch(pneum_dose1 pneum_dose2 pneum_dose3), values(1 2) 
	replace pneum_any_ = . if (pneum_dose1<0 | pneum_dose1==.) & (pneum_dose2<0 | pneum_dose2==.) & (pneum_dose3<0 | pneum_dose3==.) 
	
	cap egen mmr_any_ = anymatch(mmr_dose1), values(1 2) 
	replace mmr_any_ = . if (mmr_dose1<0 | mmr_dose1==.) 
	
	cap egen dpt_any_ = anymatch(dpt_dose1 ), values(1 2) 
	replace dpt_any_ = . if (dpt_dose1<0 | dpt_dose1==.) 
	
	cap egen mr_any_ = anymatch(mr_dose1), values(1 2) 
	replace mr_any_ = . if (mr_dose1<0 | mr_dose1==.) 
	
	cap egen dt_any_ = anymatch(dt_dose1 dt_dose2 dt_dose3 dt_boost1 dt_boost2 dt_boost3 dt_boost4), values(1 2) 
	replace dt_any_ = . if (dt_dose1<0 | dt_dose1==.) & (dt_dose2<0 | dt_dose2==.) & (dt_dose3<0 | dt_dose3==.) & (dt_boost1<0 | dt_boost1==.) & (dt_boost2<0 | dt_boost2==.) & (dt_boost3<0 | dt_boost3==.) & (dt_boost4<0 | dt_boost4==.) 
	
	foreach var of varlist bcg_num_  opv_num_  rota_num_  pent_num_  pneum_num_   mmr_num_  dpt_num_  mr_num_  dt_num_  bcg_any_ opv_any_ pent_any_ pneum_any_ rota_any_ mmr_any_ mr_any_ dpt_any_ dt_any_  {
		replace `var'=0 if vaccard==2
	}
	
	cap egen types_vacs_received_card_ = rowtotal(bcg_any_ opv_any_ rota_any_ pent_any_ pneum_any_ mmr_any_ dpt_any_ mr_any_ dt_any)
	replace types_vacs_received_card=. if vaccard!=1
	replace types_vacs_received_card=0 if vaccard==2
	
	* number
	cap egen total_vacs_received_card_ = rowtotal(bcg_num_  opv_num_  rota_num_  pent_num_  pneum_num_  mmr_num_  dpt_num_  mr_num_  dt_num_ )
	replace types_vacs_received_card=. if vaccard!=1
	replace types_vacs_received_card=0 if vaccard==2

	
******************************************
***VACCINATION SCHEME FOR 3RD OPERATION***
******************************************
	* 1. 1 dose of bcg at birth; indicator manual specifies that this is only if weight at birth is >2000g (2kg)
		gen bcg_compliant_card_ = 0
		replace bcg_compliant_card_ = 1 if ((vacbirth_wt>0 & vacbirth_wt<=2) | (vacbirth_wt>245 & vacbirth_wt<=2000))  // most of the data are in kg; using 245g as the lower cutoff to determine possible weight in grams
		replace bcg_compliant_card_ = 1 if (bcg_num>=1 & bcg_num!=.)
		replace bcg_compliant_card_ = . if (vaccard==1 | vaccard==2) & (bcg_num==.)
		replace bcg_compliant_card_ = 0 if bcg_num==0
	
	* 2. ipv/opv at 2 months, 4 months, 6 months		
		gen opv_compliant_card_ = 0
		replace opv_compliant_card_=1 if kid_age_mon<=2
		replace opv_compliant_card_=1 if (kid_age_mon>2 & kid_age_mon<=4) & ((opv_num>=1 & opv_num!=.) )
		replace opv_compliant_card_=. if (kid_age_mon>2 & kid_age_mon<=4) & (vaccard==1 | vaccard==2) & (opv_num==.)
		replace opv_compliant_card_=1 if (kid_age_mon>4 & kid_age_mon<=6) & ((opv_num>=2 & opv_num!=.) )
		replace opv_compliant_card_=. if (kid_age_mon>4 & kid_age_mon<=6) & (vaccard==1 | vaccard==2) & (opv_num==.)
		replace opv_compliant_card_=1 if (kid_age_mon>6) & ((opv_num>=3 & opv_num!=.) )
		replace opv_compliant_card_=. if (kid_age_mon>6) & (vaccard==1 | vaccard==2) & (opv_num==.)
		replace opv_compliant_card_ = 0 if kid_age_mon>2 & opv_num==0
		
	* 3. pentavalent at 2, 4, and 6 months 
	* dpt- hepb - hib
		gen pent_compliant_card_ = 0
		replace pent_compliant_card_ = 1 if kid_age_mon<=2
		replace pent_compliant_card_ = 1 if (kid_age_mon>2 & kid_age_mon<=4) & ( (pent_num>=1 & pent_num!=.))
		replace pent_compliant_card_ = . if (kid_age_mon>2 & kid_age_mon<=4) & (pent_num==.) & (vaccard==1 | vaccard==2) 
		replace pent_compliant_card_ = 1 if (kid_age_mon>4 & kid_age_mon<=6) & ( (pent_num>=2 & pent_num!=.))
		replace pent_compliant_card_ = . if (kid_age_mon>4 & kid_age_mon<=6) & ( (pent_num==.) & (vaccard==1 | vaccard==2) )
		replace pent_compliant_card_ = 1 if (kid_age_mon>6 ) & ((pent_num>=3 & pent_num!=.))
		replace pent_compliant_card_ = . if (kid_age_mon>6 ) & ( (pent_num==.) & (vaccard==1 | vaccard==2) )
		replace pent_compliant_card_ = 0 if kid_age_mon>2 & pent_num==0
		
	* 4. rotavirus - at 2 and 4 months 	
		gen rota_compliant_card_ = 0
		replace rota_compliant_card_ = 1 if kid_age_mon<=2
		replace rota_compliant_card_ = 1 if (kid_age_mon>2 & kid_age_mon<=4) & (rota_num>=1 & rota_num!=.) 
		replace rota_compliant_card_ = . if (kid_age_mon>2 & kid_age_mon<=4) & (vaccard==1 | vaccard==2) & (rota_num==.)
		replace rota_compliant_card_ = 1 if (kid_age_mon>4 & kid_age_mon<=6) & (rota_num>=2 & rota_num!=.)
		replace rota_compliant_card_ = . if (kid_age_mon>4 & kid_age_mon<=6) & (vaccard==1 | vaccard==2) & (rota_num==.)
	*indicator definition requires only 2mo and 4mo; any child 6mo or older with 2 doses passes.
		replace rota_compliant_card_ = 1 if (kid_age_mon>6) & (rota_num>=2 & rota_num!=.)
		replace rota_compliant_card_ = . if (kid_age_mon>6) & (vaccard==1 | vaccard==2) & (rota_num==.)
		replace rota_compliant_card_ = 0 if kid_age_mon>2 & rota_num==0
	
	* 5. pneumococcal conjugate- at 2, 4 and 6 months
		gen pneum_elig_ = 1 //eligibility was complicated at baseline - but all children in 3rd operation should get doses at 2,4,6mo	
		
		gen pneu_compliant_card_ = 0
		replace pneu_compliant_card_ = 1 if kid_age_mon<=2 | pneum_elig==0 
		replace pneu_compliant_card_ = 1 if (kid_age_mon>2 & kid_age_mon<=4) & ((pneum_num>=1 & pneum_num!=.) )
		replace pneu_compliant_card_ = . if (kid_age_mon>2 & kid_age_mon<=4) & (vaccard==1 | vaccard==2) & (pneum_num==.)
		replace pneu_compliant_card_ = 1 if (kid_age_mon>4 & kid_age_mon<=6) & ((pneum_num>=2 & pneum_num!=.) )
		replace pneu_compliant_card_ = . if (kid_age_mon>4 & kid_age_mon<=6) & (vaccard==1 | vaccard==2) & (pneum_num==.)
		replace pneu_compliant_card_ = 1 if kid_age_mon>6 & ((pneum_num>=3 & pneum_num!=.) )  & pneum_elig==1 
		replace pneu_compliant_card_ = . if kid_age_mon>6 & (vaccard==1 | vaccard==2) & (pneum_num==.)  & pneum_elig==1 
		replace pneu_compliant_card_ = 0 if kid_age_mon>2 & pneum_num==0 & pneum_elig==1 
				
	* 6. mmr at 1 year, booster required at 18mo for 3rd operation 	
		gen mmr_compliant_card_ = 0
		replace mmr_compliant_card_=1 if kid_age_mon<=12
		replace mmr_compliant_card_= 1 if kid_age_mon>12 & kid_age_mon<=18 & ((mmr_num>=1 & mmr_num!=.) ) 
		replace mmr_compliant_card_= 1 if kid_age_mon>18 & ((mmr_num>=2 & mmr_num!=.)|(mr_num>=1 & mr_num!=.) )
		replace mmr_compliant_card_= . if kid_age_mon>12 & (vaccard==1 | vaccard==2) & (mmr_num==.)
		replace mmr_compliant_card_ = 0 if kid_age_mon>12 & mmr_num==0
	
	* 7. dpt- 1 at 18 months (a year after the third pentavalent dose) 
		gen dpt_compliant_card_ = 0
		replace dpt_compliant_card_ = 1 if kid_age_mon<=18
		replace dpt_compliant_card_ = 1 if (kid_age_mon>18) & (dpt_num>=1 & dpt_num!=.)  & pent_compliant_card_==1
		replace dpt_compliant_card_ = . if (kid_age_mon>18) & (vaccard==1 | vaccard==2) & (dpt_num==. | pent_compliant_card_==.)
		replace dpt_compliant_card_ = 0 if kid_age_mon>18 & dpt_num==0

//Overall compliance
	gen vac_compliant_card_ = 0
	replace vac_compliant_card_ = 1 if bcg_compliant_card_==1 & opv_compliant_card_==1 & pent_compliant_card_==1 & pneu_compliant_card_==1 & rota_compliant_card_==1 & dpt_compliant_card_==1 &  mmr_compliant_card_==1  
	replace vac_compliant_card_ = . if bcg_compliant_card_==. | opv_compliant_card_==. | pent_compliant_card_==. | pneu_compliant_card_==. | rota_compliant_card_==. | dpt_compliant_card_==. |  mmr_compliant_card_==.  

// INDICATOR CALCULATION ************************************************************
	cap rename wtseg wtSEG
	svyset wtSEG [pweight=weight_child], strata(tx_area)  

	di in red _newline "Indicator: Children 0-59 months fully vaccinated for age, according to vaccine card"
	svy: prop vac_compliant_card_ , over(tx_area)	
	tab vac_compliant_card_ tx_area
********************
