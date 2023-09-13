************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 4080
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
************************************

 // MATERNAL COMPLICATIONS RECORDS (4080)
	use "IHME_SMI_BLZ_HFS_2022_MATCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4080: Women with obstetric complications (sepsis, hemorrhage, severe pre-eclampsia and eclampsia) managed according to the norm in the last two years
***************************************************************************************

// Denominator: Total number of maternal complications records in our sample  
	
	// Must have a complication
	drop if mrr_wom_del_comp_no == 1
	tab mrr_wom_del_comp, m
	
	//Basic and Complete level
	cap gen cone = "amb" if fac_type == 1
	replace cone = "basic" if fac_type == 2
	replace cone = "comp" if fac_type == 3
		
	keep if cone == "basic" | cone == "comp"

{ //Date restrictions
	gen record_date = date(wom_adm_date_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/16/2020 - 7/15/2022)
	replace time = "evaluation" if record_date >= date("2020-7-16", "YMD") & record_date <= date("2022-7-15", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 7/15/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-7-15", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Format variables if necessary
	replace wom_gestage_spec = . if wom_gestage_spec ==-1


//Manage antibiotics variables here
	foreach var in ami cli gen amp met peni penicry pip taz {
		rename wom_sep_med_adm_`var' sep_`var'
	}

	rename wom_hem_med_adm_gen hem_gen

	tab1 *med*name

// Generate antibiotics variables from 'other specify'
	foreach comp in hem sep pre ecl {
		cap gen wom_`comp'_med_adm_oan1 =.
		cap gen wom_`comp'_med_oan1_name =.
		
		//format
		foreach type in oan1 ome1 ome2 ome3 {
			tostring  wom_`comp'_med_`type'_name, replace
			replace wom_`comp'_med_`type'_name = "" if wom_`comp'_med_`type'_name == "."
			replace wom_`comp'_med_`type'_name = lower(wom_`comp'_med_`type'_name)
		}
		
		//ceftriaxone
		gen `comp'_ceftr = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_ceftr = 1 if regex(wom_`comp'_med_oan1_name, "ceftr") | regex(wom_`comp'_med_ome1_name, "ceftr") | regex(wom_`comp'_med_ome2_name, "ceftr") | regex(wom_`comp'_med_ome3_name, "ceftr")

		//amoxicillin
		gen `comp'_amoxi = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_amoxi = 1 if regex(wom_`comp'_med_oan1_name, "amoxi") | regex(wom_`comp'_med_ome1_name, "amoxi") | regex(wom_`comp'_med_ome2_name, "amoxi") | regex(wom_`comp'_med_ome3_name, "amoxi")
		
		//metronidazole
		gen `comp'_metron = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_metron = 1 if regex(wom_`comp'_med_oan1_name, "metron") | regex(wom_`comp'_med_ome1_name, "metron") | regex(wom_`comp'_med_ome2_name, "metron") | regex(wom_`comp'_med_ome3_name, "metron") | regex(wom_`comp'_med_oan1_name, "flagyl") | regex(wom_`comp'_med_ome1_name, "flagyl") | regex(wom_`comp'_med_ome2_name, "flagyl") | regex(wom_`comp'_med_ome3_name, "flagyl")
		
	}

	foreach comp in hem pre ecl {
		//Ampicillin
		gen `comp'_amp = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_amp = 1 if regex(wom_`comp'_med_oan1_name, "ampic") | regex(wom_`comp'_med_ome1_name, "ampic") | regex(wom_`comp'_med_ome2_name, "ampic") | regex(wom_`comp'_med_ome3_name, "ampic")
	}

	foreach comp in pre ecl {
		//Gentamycin
		gen `comp'_gen = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_gen = 1 if regex(wom_`comp'_med_oan1_name, "genta") | regex(wom_`comp'_med_ome1_name, "genta") | regex(wom_`comp'_med_ome2_name, "genta") | regex(wom_`comp'_med_ome3_name, "genta")

	}

// For each one, check whether it was administered once
	foreach var in ceftr amoxi metron amp gen ami cli met peni penicry pip taz {
		cap gen hem_`var' =.
		cap gen pre_`var' =.
		cap gen sep_`var' =.
		cap gen ecl_`var' =.
		
		gen allcomps_`var' = 0 if hem_`var' !=. | pre_`var' !=. | sep_`var' !=. | ecl_`var' !=.
		replace allcomps_`var' = 1 if hem_`var' == 1 | pre_`var' == 1 | sep_`var' == 1 | ecl_`var' == 1
	}	
	
// For double/triple therapy, check whether two or more antibiotics were administered
	// Number administered
	egen num_antibiotics = anycount(allcomps_ceftr allcomps_amoxi allcomps_metron allcomps_amp allcomps_gen allcomps_ami allcomps_cli allcomps_met allcomps_peni allcomps_penicry allcomps_pip allcomps_taz), value(1) 
	// At least one?
	gen anti = 0 if num_antibiotics !=.
	replace anti = 1 if num_antibiotics >= 1 & num_antibiotics !=.
	// Two or more?
	gen double_anti = 0 if num_antibiotics !=.
	replace double_anti = 1 if num_antibiotics > 1 & num_antibiotics !=.



	
{ // HEMORRHAGE 4080 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in bp hr puls {
		rename wom_hem_check_reg_`var' hem_`var'
	}

	foreach var in hgb hmt plat {
		rename wom_hem_lab_reg_`var' hem_`var'
	}

	foreach var in oxi lact hart sal miso metr out {
		rename wom_hem_med_adm_`var' hem_`var'
	}

	foreach var in ameu cavidad legrado csec hist lap suture surg suture2 drenaje salpin masaje biman aorta tap balon manual rep hypoart utart blynch {
		rename wom_hem_procedures_`var' hem_`var'
	}
		
	foreach var in abort abort2 abort3 retain retainpart restos product placent previa previa2 premature placenta rupture rupturev rupturec atony hipo ectopic ectopicroto descerv descanal desvulvo inversion {
		rename wom_hem_cause_`var' hem_`var'
	}		


// CHECKS - BASIC & COMP: Pulse/Heart rate + BP 
	gen hem_vitsigns = 0 if hem_puls !=. & hem_bp !=. & hem_hr !=.
	replace hem_vitsigns = 1 if (hem_puls == 1 | hem_hr == 1 ) & hem_bp == 1 

// LAB - COMP: Hematocrit + Hemoglobin + platelet count
	gen hem_lab = 0 if hem_hmt !=. & hem_hgb !=. & hem_plat !=. & cone == "comp"
	replace hem_lab = 1 if hem_hmt == 1 & hem_hgb == 1 & hem_plat == 1 & cone == "comp"	

// MEDS - BASIC & COMP: ringer's lactate/hartmann/saline solution
	gen hem_med = 0 if hem_lact !=. & hem_hart !=. & hem_sal !=.
	replace hem_med = 1 if (hem_lact == 1 | hem_hart == 1 | hem_sal == 1 ) 	

// APPROPRIATE CARE

	//Hemorrhage following incomplete or complete abortion
	gen hem_treat_abort =.
	//BASIC: MVA or instrumental curettage or ref to Complete	
	replace hem_treat_abort = 0 if (hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & hem_ameu !=. & hem_legrado !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_abort = 1 if (hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & (hem_ameu == 1 | hem_legrado == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: MVA or instrumental curettage 
	replace hem_treat_abort = 0 if (hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & hem_ameu !=. & hem_legrado !=. & cone == "comp"
	replace hem_treat_abort = 1 if (hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & (hem_ameu == 1 | hem_legrado == 1 ) & cone == "comp"

	//Ectopic pregnancy
	gen hem_treat_ectopic =.
	//BASIC: laparotomy or salpingectomy or surgical repair or ref to Complete
	replace hem_treat_ectopic = 0 if (hem_ectopic == 1 | hem_ectopicroto == 1 ) & hem_lap !=. & hem_salpin !=. & hem_surg !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_ectopic = 1 if (hem_ectopic == 1 | hem_ectopicroto == 1 ) & (hem_lap == 1 | hem_salpin == 1 | hem_surg == 1 | wom_hem_disposition == 3 )  & cone == "basic"
	//COMP: laparotomy or salpingectomy or surgical repair
	replace hem_treat_ectopic = 0 if (hem_ectopic == 1 | hem_ectopicroto == 1 ) & hem_lap !=. & hem_salpin !=. & hem_surg !=. & cone == "comp"
	replace hem_treat_ectopic = 1 if (hem_ectopic == 1 | hem_ectopicroto == 1 ) & (hem_lap == 1 | hem_salpin == 1 | hem_surg == 1 ) & cone == "comp"
	
	//Placenta previa with hemorrhage
	gen hem_treat_previa =.
	//BASIC: C-section or hysterectomy or ref to Complete
	replace hem_treat_previa = 0 if ( hem_previa == 1 | hem_previa2 == 1 ) & wom_hem_result !=. & hem_hist !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_previa = 1 if ( hem_previa == 1 | hem_previa2 == 1 ) & (wom_hem_result == 2 | wom_hem_result == 3 | hem_hist == 1 | hem_csec == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: C-section or hysterectomy
	replace hem_treat_previa = 0 if ( hem_previa == 1 | hem_previa2 == 1 ) & wom_hem_result !=. & hem_hist !=. & cone == "comp"
	replace hem_treat_previa = 1 if ( hem_previa == 1 | hem_previa2 == 1 ) & (wom_hem_result == 2 | wom_hem_result == 3 | hem_hist == 1 | hem_csec == 1 ) & cone == "comp"

	//Uterine rupture
	gen hem_treat_rupture =.
	//BASIC: laparotomy or hysterectomy or surgical repair or C-section or ref to Complete
	replace hem_treat_rupture = 0 if hem_rupture == 1 & wom_hem_result !=. & hem_lap !=. & hem_hist !=. & hem_surg !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_rupture = 1 if hem_rupture == 1 & (wom_hem_result == 2 | wom_hem_result == 3 | hem_csec == 1 | hem_lap == 1 | hem_hist == 1 | hem_surg == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: laparotomy or hysterectomy or surgical repair or C-section
	replace hem_treat_rupture = 0 if hem_rupture == 1 & wom_hem_result !=. & hem_lap !=. & hem_hist !=. & hem_surg !=. & cone == "comp"
	replace hem_treat_rupture = 1 if hem_rupture == 1 & (wom_hem_result == 2 | wom_hem_result == 3 | hem_csec == 1 | hem_lap == 1 | hem_hist == 1 | hem_surg == 1 ) & cone == "comp"
	
	//Uterine atony
	gen hem_treat_atony = .
	//BASIC: uterotonics (oxytocin or others) + bimanual compression or uterine massage or hydrostatic balloon or uterine tamponade or hypogastric artery ligation or uterine artery ligation or B-lynch suture or ref to Complete
	replace hem_treat_atony = 0 if hem_atony == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_biman !=. & hem_masaje !=. & hem_balon !=. & hem_tap !=. & hem_hypoart !=. & hem_utart!=. & hem_blynch !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_atony = 1 if hem_atony == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (hem_biman == 1 | hem_masaje == 1 | hem_balon == 1 | hem_tap == 1 | hem_hypoart == 1 | hem_utart == 1 | hem_blynch == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: uterotonics (oxytocin or others) or bimanual compression or uterine massage or hydrostatic balloon or uterine tamponade or hypogastric artery ligation or uterine artery ligation or B-lynch suture or hysterectomy
	replace hem_treat_atony = 0 if hem_atony == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_biman !=. & hem_masaje !=. & hem_balon !=. & hem_tap !=. & hem_hypoart !=. & hem_utart!=. & hem_blynch !=. & hem_hist !=. & cone == "comp"
	replace hem_treat_atony = 1 if hem_atony == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (hem_biman == 1 | hem_masaje == 1 | hem_balon == 1 | hem_tap == 1 | hem_hypoart == 1 | hem_utart == 1 | hem_blynch == 1 | hem_hist == 1 ) & cone == "comp"
	
	//Uterine inversion
	gen hem_treat_inv = .
	//BASIC: uterotonics (oxytocin or others) + repositioning of the uterus with anesthesia or sedation (nonsurgical procedures or surgical procedures) or hysterectomy or ref to Complete
	replace hem_treat_inv = 0 if hem_inversion == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_rep !=. & hem_hist !=. & wom_hem_disposition !=.  & cone == "basic"
	replace hem_treat_inv = 1 if hem_inversion == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & hem_rep == 1 & (wom_hem_reposition_sed == 1 | wom_hem_reposition_sed == 2 | wom_hem_reposition_sed == 3 ) & cone == "basic"
	replace hem_treat_inv = 1 if hem_inversion == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (hem_hist == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: uterotonics (oxytocin or others) + repositioning of the uterus with anesthesia or sedation (nonsurgical procedures or surgical procedures) or hysterectomy
	replace hem_treat_inv = 0 if hem_inversion == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_rep !=. & hem_hist !=. & (wom_hem_reposition_sed !=. & hem_rep == 1) & cone == "comp"
	replace hem_treat_inv = 1 if hem_inversion == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & ((hem_rep == 1 & (wom_hem_reposition_sed == 1 | wom_hem_reposition_sed == 2 | wom_hem_reposition_sed == 3 )) | hem_hist == 1) & cone == "comp"
	
	//Retained product [NOTE: hysterectomy alternative added at 3rd operation]
	gen hem_treat_placenta = .
	//BASIC: uterotonics (oxytocin or others) + manual extraction or instrumental curettage or hysterectomy or ref to Complete
	replace hem_treat_placenta = 0 if hem_product == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_manual !=. & hem_legrado !=. & wom_hem_disposition !=. & hem_hist !=. & cone == "basic"
	replace hem_treat_placenta = 1 if hem_product == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (hem_manual == 1 | hem_legrado == 1 | wom_hem_disposition == 3 | hem_hist == 1 ) & cone == "basic"
	//COMP: uterotonics (oxytocin or others) + manual extraction or instrumental curettage or hysterectomy
	replace hem_treat_placenta = 0 if hem_product == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_manual !=. & hem_legrado !=. & hem_hist !=. & cone == "comp"
	replace hem_treat_placenta = 1 if hem_product == 1 & (hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (hem_manual == 1 | hem_legrado == 1 | hem_hist == 1 ) & cone == "comp"
  
	// Overall treatment
	gen hem_treatment = 1 if (hem_treat_abort !=. | hem_treat_ectopic !=. | hem_treat_previa !=. | hem_treat_rupture !=. | hem_treat_atony !=. | hem_treat_inv !=. | hem_treat_placenta !=.)
	replace hem_treatment = 0 if (hem_treat_abort == 0 | hem_treat_ectopic == 0 | hem_treat_previa == 0 | hem_treat_rupture == 0 | hem_treat_atony == 0 | hem_treat_inv == 0 | hem_treat_placenta == 0 )


//FINAL CALCULATION
	gen hem_norm = 0 if hem_vitsigns !=. & hem_med !=. & cone == "basic"
	replace hem_norm = 1 if hem_vitsigns == 1 & hem_med == 1 & hem_treatment != 0 & cone == "basic"

	replace hem_norm = 0 if hem_vitsigns !=. & hem_med !=. & hem_lab !=. & cone == "comp"
	replace hem_norm = 1 if hem_vitsigns == 1 & hem_med == 1 & hem_lab == 1 & hem_treatment != 0 & cone == "comp"

	replace hem_norm = . if hem_desvulvo == 1 & hem_abort == 0 & hem_abort2 == 0 & hem_abort3 == 0 & hem_retain == 0 & hem_retainpart == 0 & hem_restos == 0 & hem_product == 0 & hem_placent == 0 & hem_previa == 0 & hem_previa2 == 0 & hem_premature == 0 & hem_placenta == 0 & hem_rupture == 0 & hem_rupturev == 0 & hem_rupturec == 0 & hem_atony == 0 & hem_hipo == 0 & hem_ectopic == 0 & hem_ectopicroto == 0 & hem_descerv == 0 & hem_descanal == 0 & hem_inversion == 0 & wom_hem_cause_otro == 0 
}	
	
{ // PRE-ECLAMPSIA 4080 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in bp puls resp hr pat {
		rename wom_pre_check_reg_`var' pre_`var'
	}
		
	rename wom_pre_check_num_bp_dias pre_bp_dias

	foreach var in plat asp ala lac creat acid tgo tgp prot {
		rename wom_pre_lab_reg_`var' pre_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_pre_med_adm_`var' pre_`var'
	}

// CHECKS
	// BASIC (with referral): BP
	gen pre_vitsigns = 0 if pre_bp !=. & cone == "basic" & wom_pre_disposition == 3
	replace pre_vitsigns = 1 if pre_bp == 1 & cone == "basic" & wom_pre_disposition == 3
	
	// BASIC (without referral) and COMPLETE: BP + pulse + respiratory rate + patellar reflex 
	replace pre_vitsigns = 0 if pre_bp !=. & pre_hr !=. & pre_puls !=. & pre_resp !=. & pre_pat !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 )) 
	replace pre_vitsigns = 1 if pre_bp == 1 & (pre_puls == 1 | pre_hr == 1 ) & pre_resp == 1 & pre_pat == 1 & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))	

// LAB [NOTE 3rd operation: urine protein is no longer required]
	// COMPLETE: platelet count + (Aspartate aminotransferase or serum glutamic oxaloacetic transaminase) + (Alanine aminotransferase or serum glutamate-pyruvate transaminase)
	gen pre_lab = 0 if pre_plat !=. & pre_asp !=. & pre_tgo !=. & pre_ala !=. & pre_tgp !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 )) 
	replace pre_lab = 1 if pre_plat == 1 & (pre_asp == 1 | pre_tgo == 1 ) & (pre_ala == 1 | pre_tgp == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  

// MEDS
	// dexamenthasone/betamethasone (if 24 =< gestational age < 34)
	destring wom_gestage_spec, replace 	
	gen pre_dexbet = 0 if wom_gestage_spec !=. & wom_gestage_spec >= 24 & wom_gestage_spec < 34 & pre_bet !=. & pre_dex !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  
	replace pre_dexbet = 1 if (wom_gestage_spec >= 24 & wom_gestage_spec < 34 & wom_gestage_spec !=.) & (pre_bet == 1 | pre_dex == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  

	// hydralazine or labetalol or nifedipine (if diastolic BP > 110)
	destring pre_bp_dias, replace 
	gen pre_hydra = 0 if pre_bp_dias!=. & pre_bp_dias > 110 & pre_hid !=. & pre_nif !=. & pre_lol !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  
	replace pre_hydra = 1 if (pre_bp_dias > 110 & pre_bp_dias !=.) & (pre_hid == 1 | pre_nif == 1 | pre_lol == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  

	// BASIC (with referral): Ringer/Hartman lactate or saline solution + magnesium sulfate 
	gen pre_med = 0 if pre_mgs !=. & pre_lact !=. & pre_hart !=. & pre_sal !=. & cone == "basic" & wom_pre_disposition == 3
	replace pre_med = 1 if pre_mgs == 1 & (pre_lact == 1 | pre_hart == 1 | pre_sal == 1 ) & cone == "basic" & wom_pre_disposition == 3	 			

	// BASIC (without referral) and COMPLETE: magnesium sulfate + if diastolic BP>110: (hydralazine or labetalol or nifedipine) + if 24=< gestational age <34 weeks: (Dexamethasone or betamethasone)]
	replace pre_med = 0 if pre_mgs !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  
	replace pre_med = 1 if pre_mgs == 1 & pre_hydra !=0 & pre_dexbet !=0 & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 ))  
	

//FINAL CALCULATION
	gen pre_norm = .

	replace pre_norm = 0 if pre_vitsigns !=. & pre_med !=. & cone == "basic" & wom_pre_disposition == 3
	replace pre_norm = 1 if pre_vitsigns == 1 & pre_med == 1 & cone == "basic" & wom_pre_disposition == 3

	replace pre_norm = 0 if pre_vitsigns !=. & pre_lab !=. & pre_med !=. & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 )) 
	replace pre_norm = 1 if pre_vitsigns == 1 & pre_lab == 1 & pre_med == 1 & ( cone == "comp" | ( cone == "basic" & wom_pre_disposition != 3 )) 
}

{ // ECLAMPSIA 4080 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in bp puls resp hr pat {
		rename wom_ecl_check_reg_`var' ecl_`var'
	}
		
	rename wom_ecl_check_num_bp_dias ecl_bp_dias

	foreach var in plat asp ala lac creat acid tgo tgp prot {
		rename wom_ecl_lab_reg_`var' ecl_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_ecl_med_adm_`var' ecl_`var'
	}

// CHECKS
	// BASIC (with referral): BP
	gen ecl_vitsigns = 0 if ecl_bp !=. & cone == "basic" & wom_ecl_disposition == 3
	replace ecl_vitsigns = 1 if ecl_bp == 1 & cone == "basic" & wom_ecl_disposition == 3
	
	// BASIC (without referral) and COMPLETE: BP + pulse + respiratory rate + patellar reflex 
	replace ecl_vitsigns = 0 if ecl_bp !=. & ecl_hr !=. & ecl_puls !=. & ecl_resp !=. & ecl_pat !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 )) 
	replace ecl_vitsigns = 1 if ecl_bp == 1 & (ecl_puls == 1 | ecl_hr == 1 ) & ecl_resp == 1 & ecl_pat == 1 & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))	

// LAB [NOTE 3rd operation: urine protein is no longer required]
	// COMPLETE: platelet count + (Aspartate aminotransferase or serum glutamic oxaloacetic transaminase) + (Alanine aminotransferase or serum glutamate-pyruvate transaminase)
	gen ecl_lab = 0 if ecl_plat !=. & ecl_asp !=. & ecl_tgo !=. & ecl_ala !=. & ecl_tgp !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 )) 
	replace ecl_lab = 1 if ecl_plat == 1 & (ecl_asp == 1 | ecl_tgo == 1 ) & (ecl_ala == 1 | ecl_tgp == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  

// MEDS
	// dexamenthasone/betamethasone (if 24 =< gestational age < 34)
	destring wom_gestage_spec, replace 	
	gen ecl_dexbet = 0 if wom_gestage_spec !=. & wom_gestage_spec >= 24 & wom_gestage_spec < 34 & ecl_bet !=. & ecl_dex !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  
	replace ecl_dexbet = 1 if (wom_gestage_spec >= 24 & wom_gestage_spec < 34 & wom_gestage_spec !=.) & (ecl_bet == 1 | ecl_dex == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  

	// hydralazine or labetalol or nifedipine (if diastolic BP > 110)
	destring ecl_bp_dias, replace 
	gen ecl_hydra = 0 if ecl_bp_dias!=. & ecl_bp_dias > 110 & ecl_hid !=. & ecl_nif !=. & ecl_lol !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  
	replace ecl_hydra = 1 if (ecl_bp_dias > 110 & ecl_bp_dias !=.) & (ecl_hid == 1 | ecl_nif == 1 | ecl_lol == 1 ) & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  

	// BASIC (with referral): Ringer/Hartman lactate or saline solution + magnesium sulfate
	gen ecl_med = 0 if ecl_mgs !=. & ecl_lact !=. & ecl_hart !=. & ecl_sal !=. & cone == "basic" & wom_ecl_disposition == 3
	replace ecl_med = 1 if ecl_mgs == 1 & (ecl_lact == 1 | ecl_hart == 1 | ecl_sal == 1 ) & cone == "basic" & wom_ecl_disposition == 3	 			

	// BASIC (without referral) and COMPLETE: magnesium sulfate + if diastolic BP>110: (hydralazine or labetalol or nifedipine) + if 24=< gestational age <34 weeks: (Dexamethasone or betamethasone)]
	replace ecl_med = 0 if ecl_mgs !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  
	replace ecl_med = 1 if ecl_mgs == 1 & ecl_hydra !=0 & ecl_dexbet !=0 & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 ))  
	

//FINAL CALCULATION
	gen ecl_norm = .

	replace ecl_norm = 0 if ecl_vitsigns !=. & ecl_med !=. & cone == "basic" & wom_ecl_disposition == 3
	replace ecl_norm = 1 if ecl_vitsigns == 1 & ecl_med == 1 & cone == "basic" & wom_ecl_disposition == 3

	replace ecl_norm = 0 if ecl_vitsigns !=. & ecl_lab !=. & ecl_med !=. & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 )) 
	replace ecl_norm = 1 if ecl_vitsigns == 1 & ecl_lab == 1 & ecl_med == 1 & ( cone == "comp" | ( cone == "basic" & wom_ecl_disposition != 3 )) 
}		
	
{ // SEPSIS 4080 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in temp hr puls bp {
		rename wom_sep_check_reg_`var' sep_`var'
	}

	foreach var in /* cbc */ leuc plat hgb hmt {
		rename wom_sep_lab_reg_`var' sep_`var'
	}

	foreach var in ameu cavidad legrado hist lap suture surg drenaje salpin {
		rename wom_sep_procedures_`var' sep_`var'
	}	

	foreach var in abort abort2 prerupture perf corio abscess pelvicabscess ectinfect pelviper canaltear epistoinfect postendo fever product {
		rename wom_sep_cause_`var' sep_`var'
	}

// CHECKS : temperature + pulse + BP
	gen sep_vitsigns = 0 if sep_hr !=. & sep_puls !=. & sep_bp !=. & sep_temp !=. 
	replace sep_vitsigns = 1 if (sep_puls == 1 | sep_hr == 1 ) & sep_bp == 1 & sep_temp == 1 
	
// LAB - COMPLETE: hemoglobin + hematocrit + platelets + leukocytes
	gen sep_lab = 0 if sep_leuc !=. & sep_plat !=. & sep_hgb !=. & sep_hmt !=. & cone == "comp"
	replace sep_lab = 1 if sep_leuc == 1 & sep_plat == 1 & sep_hgb == 1 & sep_hmt == 1 & cone == "comp"	
 
// ANTIBIOTICS
	gen sep_med = 0 if double_anti !=. & mrr_wom_del_comp_sep == 1
	replace sep_med = 1 if double_anti == 1 & mrr_wom_del_comp_sep == 1

// APPROPRIATE CARE
	
	//Septic abortion	
	gen sep_treat_abort =.
	//BASIC: MVA or instrumental curettage or hysterectomy or ref to Complete
	replace sep_treat_abort = 0 if (sep_abort == 1 | sep_abort2 == 1 ) & sep_ameu !=. & sep_legrado !=. & sep_hist !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_abort = 1 if (sep_abort == 1 | sep_abort2 == 1 ) & (sep_ameu == 1 | sep_legrado == 1 | sep_hist == 1 | wom_sep_disposition == 3 ) & cone == "basic"
	//COMP: MVA or instrumental curettage or hysterectomy
	replace sep_treat_abort = 0 if (sep_abort == 1 | sep_abort2 == 1 ) & sep_ameu !=. & sep_legrado !=. & sep_hist !=. & cone == "comp"
	replace sep_treat_abort = 1 if (sep_abort == 1 | sep_abort2 == 1 ) & (sep_ameu == 1 | sep_legrado == 1 | sep_hist == 1 ) & cone == "comp"

	//Pelvic abscess [Note 3rd operation: surgical repair removed as an option]
	gen sep_treat_abscess = .
	//BASIC: laparotomy or drainage or hysterectomy or ref to Complete
	replace sep_treat_abscess = 0 if sep_pelvicabscess == 1 & sep_drenaje !=. & sep_lap !=. & sep_hist !=. & wom_sep_disposition !=. & cone == "basic" 
	replace sep_treat_abscess = 1 if sep_pelvicabscess == 1 & (sep_drenaje == 1 | sep_lap == 1 | sep_hist == 1 | wom_sep_disposition == 3 ) & cone == "basic" 
	//COMP: laparotomy or drainage or hysterectomy
	replace sep_treat_abscess = 0 if sep_pelvicabscess == 1 & sep_drenaje !=. & sep_lap !=. & sep_hist !=. & cone == "comp" 
	replace sep_treat_abscess = 1 if sep_pelvicabscess == 1 & (sep_drenaje == 1 | sep_lap == 1 | sep_hist == 1 ) & cone == "comp" 
 
	//Retained product
	gen sep_treat_reten =.
	//BASIC: instrumental curettage or laparotomy or hysterectomy  or ref to complete 
	replace sep_treat_reten = 0 if sep_product == 1 & sep_legrado !=. & sep_lap !=. & sep_hist !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_reten = 1 if sep_product == 1 & (sep_legrado == 1 | sep_lap == 1 | sep_hist == 1 | wom_sep_disposition == 3 ) & cone == "basic"
	//COMP: instrumental curettage or laparotomy or hysterectomy 
	replace sep_treat_reten = 0 if sep_product == 1 & sep_legrado !=. & sep_lap !=. & sep_hist !=. & cone == "comp"
	replace sep_treat_reten = 1 if sep_product == 1 & (sep_legrado == 1 | sep_lap == 1 | sep_hist == 1 ) & cone == "comp"

	//Puerperal fever
	gen sep_treat_fever =.
	//BASIC: antibiotic administration or ref to Complete
	replace sep_treat_fever = 0 if sep_fever == 1 & sep_ami !=. & sep_cli !=. & sep_gen !=. & sep_amp !=. & sep_met !=. & sep_peni !=. & sep_penicry !=. & sep_pip !=. & sep_taz !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_fever = 1 if sep_fever == 1 & (sep_ami == 1 | sep_cli == 1 | sep_gen == 1 | sep_amp == 1 | sep_met == 1 | sep_peni == 1 | sep_penicry == 1 | sep_pip == 1 | sep_taz == 1 | wom_sep_disposition == 3 ) & cone == "basic"
	//COMP: antibiotic administration 
	replace sep_treat_fever = 0 if sep_fever == 1 & sep_ami !=. & sep_cli !=. & sep_gen !=. & sep_amp !=. & sep_met !=. & sep_peni !=. & sep_penicry !=. & sep_pip !=. & sep_taz !=. & cone == "comp"
	replace sep_treat_fever = 1 if sep_fever == 1 & (sep_ami == 1 | sep_cli == 1 | sep_gen == 1 | sep_amp == 1 | sep_met == 1 | sep_peni == 1 | sep_penicry == 1 | sep_pip == 1 | sep_taz == 1 ) & cone == "comp"
	
	//Uterine perforation
	gen sep_treat_perf =.
	//BASIC: surgical repair or hysterectomy or ref to Complete
	replace sep_treat_perf = 0 if sep_perf == 1 & sep_surg !=. & sep_hist !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_perf = 1 if sep_perf == 1 & (sep_surg == 1 | sep_hist == 1 | wom_sep_disposition == 3 ) & cone == "basic"
	//COMP: surgical repair or hysterectomy
	replace sep_treat_perf = 0 if sep_perf == 1 & sep_surg !=. & sep_hist !=. & cone == "comp"
	replace sep_treat_perf = 1 if sep_perf == 1 & (sep_surg == 1 | sep_hist == 1 ) & cone == "comp"
	
	//Postpartum endometritis
	gen sep_treat_endo =.
	//BASIC: antibiotic administration or ref to Complete
	replace sep_treat_endo = 0 if sep_postendo == 1 & sep_ami !=. & sep_cli !=. & sep_gen !=. & sep_amp !=. & sep_met !=. & sep_peni !=. & sep_penicry !=. & sep_pip !=. & sep_taz !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_endo = 1 if sep_postendo == 1 & (sep_ami == 1 | sep_cli == 1 | sep_gen == 1 | sep_amp == 1 | sep_met == 1 | sep_peni == 1 | sep_penicry == 1 | sep_pip == 1 | sep_taz == 1 | wom_sep_disposition == 3 ) & cone == "basic"
	//COMP: antibiotic administration
	replace sep_treat_endo = 0 if sep_postendo == 1 & sep_ami !=. & sep_cli !=. & sep_gen !=. & sep_amp !=. & sep_met !=. & sep_peni !=. & sep_penicry !=. & sep_pip !=. & sep_taz !=. & cone == "comp"
	replace sep_treat_endo = 1 if sep_postendo == 1 & (sep_ami == 1 | sep_cli == 1 | sep_gen == 1 | sep_amp == 1 | sep_met == 1 | sep_peni == 1 | sep_penicry == 1 | sep_pip == 1 | sep_taz == 1 ) & cone == "comp"
	
	// Overall Treatment	
	gen sep_treatment = 1 if (sep_treat_abort !=. | sep_treat_abscess !=. | sep_treat_reten !=. | sep_treat_fever !=. | sep_treat_perf !=. | sep_treat_endo !=. ) 
	replace sep_treatment = 0 if ( sep_treat_abort == 0 | sep_treat_abscess == 0 | sep_treat_reten == 0 | sep_treat_fever == 0 | sep_treat_perf == 0 | sep_treat_endo == 0 ) 


// FINAL CALCULATION
	gen sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & cone == "basic"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_treatment !=0 & cone == "basic"
		
	replace sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & sep_lab !=. & cone == "comp"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_lab == 1 & sep_treatment !=0 & cone == "comp"	
}

// INDICATOR CALCULATION ************************************************************
	gen I4080 = 0 if sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.
	replace I4080 = 1 if sep_norm !=0 & pre_norm !=0 & ecl_norm !=0 & hem_norm !=0 & (sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.)

	// Indicator value
	prop I4080 if time == "pre-evaluation" 
	prop I4080 if time == "evaluation" 
