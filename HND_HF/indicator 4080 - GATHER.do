************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Honduras Performance Indicator 4080
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

 // MATERNAL COMPLICATIONS RECORDS (4080)
	use "IHME_SMI_HND_HFS_2022_MATCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4080: Women with obstetric complications (sepsis, hemorrhage, severe pre-eclampsia and eclampsia) managed according to the norm in the last two years
***************************************************************************************

// Denominator: Total number of maternal complications records in our sample 
	
	// Must have a complication
	drop if mrr_wom_del_comp_no == 1
	tab mrr_wom_del_comp, m
	
	//Basic and Complete
	keep if cone == 2 | cone == 3
	rename cone cone_numeric
	gen cone = "basic" if cone_numeric == 2
	replace cone = "comp" if cone_numeric == 3

{ //Date restrictions
	gen record_date = date(wom_adm_date_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/1/2020 - 6/30/2022)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 6/30/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Format variables if necessary
	replace wom_gestage = . if wom_gestage ==-1
	

{ // HEMORRHAGE 4080

// Shorten varnames here
	foreach var in bp puls hr {
		rename wom_hem_check_reg_`var' hem_`var'
	}

	foreach var in hgb hmt plat {
		rename wom_hem_lab_reg_`var' hem_`var'
	}

	foreach var in oxi lact hart sal miso metr out {
		rename wom_hem_med_adm_`var' hem_`var'
	}

	foreach var in abort abort2 abort3 retain retainpart restos placent previa previa2 premature placenta rupture rupturev rupturec atony hipo ectopic ectopicroto descerv descanal desvulvo inversion {
		rename wom_hem_cause_`var' hem_`var'
	}

	foreach var in ameu cavidad legrado csec hist lap suture surg suture2 drenaje salpin masaje biman aorta tap balon manual rep oth {
		rename wom_hem_procedures_`var' hem_`var'
	}

// CHECKS - BASIC & COMP: Pulse + BP 
	gen hem_vitsigns = 0 if hem_puls !=. & hem_hr !=. & hem_bp !=. 
	replace hem_vitsigns = 1 if ( hem_puls == 1 | hem_hr == 1 ) & hem_bp == 1 

// LAB - COMP: Hto + Hb + platelet count 
	gen hem_lab = 0 if hem_hmt !=. & hem_hgb !=. & hem_plat !=. & cone == "comp"
	replace hem_lab = 1 if hem_hmt == 1 & hem_hgb == 1 & hem_plat == 1 & cone == "comp"	
	
// MEDS - BASIC & COMP: ringer's lactate/hartmann/saline solution
	gen hem_med = 0 if hem_lact !=. & hem_hart !=. & hem_sal !=. 
	replace hem_med = 1 if ( hem_lact == 1 | hem_hart == 1 | hem_sal == 1 ) 

// APPROPRIATAE TREATMENT

	//Aborto incompleto complicado con hemorragia o hemorragia consecutiva al aborto	
	gen hem_treat_abort = .
	//BASIC: AMEU o legrado instrumental o traslado a CONE complete 
	replace hem_treat_abort = 0 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & hem_ameu !=. & hem_legrado !=. & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_abort = 1 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & ( hem_ameu == 1 | hem_legrado == 1 | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: AMEU o legrado instrumental 
	replace hem_treat_abort = 0 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & hem_ameu !=. & hem_legrado !=. & cone == "comp"
	replace hem_treat_abort = 1 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & ( hem_ameu == 1 | hem_legrado == 1 ) & cone == "comp"
	
	//Embarazo ectópico
	gen hem_treat_ectopic = .
	//BASIC: traslado a CONE completo 
	replace hem_treat_ectopic = 0 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_ectopic = 1 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & wom_hem_disposition == 3 & cone == "basic"
	//COMP: laparotomía o salpinguectomia o reparacion quirúrgica 
	replace hem_treat_ectopic = 0 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & hem_lap !=. & hem_salpin !=. & hem_surg !=. & cone == "comp"
	replace hem_treat_ectopic = 1 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & ( hem_lap == 1 | hem_salpin == 1 | hem_surg == 1 ) & cone == "comp"
	
	//Placenta previa
	gen hem_treat_previa = .
	//BASIC: traslado a CONE completo
	replace hem_treat_previa = 0 if ( hem_previa == 1 | hem_previa2 == 1 )& wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_previa = 1 if ( hem_previa == 1 | hem_previa2 == 1 ) & wom_hem_disposition == 3 & cone == "basic"
	//COMP: cesárea
	replace hem_treat_previa = 0 if ( hem_previa == 1 | hem_previa2 == 1 ) & hem_csec !=. & wom_hem_result !=. & cone == "comp"
	replace hem_treat_previa = 1 if ( hem_previa == 1 | hem_previa2 == 1 ) & ( hem_csec == 1 | wom_hem_result == 2 | wom_hem_result == 3 ) & cone == "comp"
	
	//Desprendimiento de placenta
	gen hem_treat_desp = .
	//BASIC: traslado a CONE completo 
	replace hem_treat_desp = 0 if ( hem_premature == 1 | hem_placenta == 1 ) & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_desp = 1 if ( hem_premature == 1 | hem_placenta == 1 ) & wom_hem_disposition == 3 & cone == "basic"
	//COMP: parto vaginal o cesárea
	replace hem_treat_desp = 0 if ( hem_premature == 1 | hem_placenta == 1 ) & hem_csec !=. & wom_hem_result !=. & cone == "comp"
	replace hem_treat_desp = 1 if ( hem_premature == 1 | hem_placenta == 1 ) & ( hem_csec == 1 | wom_hem_result == 1 | wom_hem_result == 2 | wom_hem_result == 3 ) & cone == "comp"
	
	//Ruptura uterina
	gen hem_treat_rupture = .
	//BASIC: traslado a CONE completo
	replace hem_treat_rupture = 0 if hem_rupture == 1 & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_rupture = 1 if hem_rupture == 1 & wom_hem_disposition == 3 & cone == "basic"
	//COMP: laparotomía o histerectomia o reparacion quirurgica 
	replace hem_treat_rupture = 0 if hem_rupture == 1 & hem_lap !=. & hem_hist !=. & hem_surg !=. & cone == "comp"
	replace hem_treat_rupture = 1 if hem_rupture == 1 & hem_lap == 1 | hem_hist == 1 | hem_surg == 1 & cone == "comp"
	
	//Atonía uterina
	gen hem_treat_atony = .
	//BASIC: uterotonico + traslado a CONE completo
	replace hem_treat_atony = 0 if hem_atony == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_atony = 1 if hem_atony == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & wom_hem_disposition == 3 & cone == "basic"
	//COMP: uterotonico + [masaje uterino o compresión bimanual o compresión de la aorta o taponmiento uterino (balón hidrostático) o suturas compresivas o histerectomía]
	replace hem_treat_atony = 0 if hem_atony == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_masaje !=. & hem_biman !=. & hem_aorta !=. & hem_tap !=. & hem_suture2 !=. & hem_hist !=. & cone == "comp"
	replace hem_treat_atony = 1 if hem_atony == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & ( hem_masaje == 1 | hem_biman == 1 | hem_aorta == 1 | hem_tap == 1 | hem_suture2 == 1 | hem_hist == 1 ) & cone == "comp"
	
	//Inversión uterina
	gen hem_treat_inv = .
	//BASIC: uterotonico (oxitocina o misoprostol o metilergonovina) + [reposición o restitución del útero bajo sedación o anestésicos disponibles en el servicios y técnicas no quirúrgicas (maniobra de Johnson) o quirúrgicas (maniobras de Huntington o de Haultani) o Histerectomia o traslado a CONE completo]
	replace hem_treat_inv = 0 if hem_inversion == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_rep !=. & wom_hem_reposition_sed !=. & hem_hist !=. & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_inv = 1 if hem_inversion == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (( hem_rep == 1 & ( wom_hem_reposition_sed == 1 | wom_hem_reposition_sed == 2 | wom_hem_reposition_sed == 3 )) | wom_hem_disposition == 3 ) & cone == "basic"
	//COMP: uterotonico (oxitocina o misoprostol o metilergonovina) + [reposición o restitución del útero bajo sedación o anestésicos disponibles en el servicios y técnicas no quirúrgicas (maniobra de Johnson) o quirúrgicas (maniobras de Huntington o de Haultani)]
	replace hem_treat_inv = 0 if hem_inversion == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_rep !=. & wom_hem_reposition_sed !=. & cone == "comp"
	replace hem_treat_inv = 1 if hem_inversion == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & hem_rep == 1 & ( wom_hem_reposition_sed == 1 | wom_hem_reposition_sed == 2 | wom_hem_reposition_sed == 3 ) & cone == "comp"
	
	//Retención de placenta
	gen hem_treat_placenta = .
	//BASIC: uterotonico (oxitocina o misoprostol o metilergonovina) + traslado a CONE completo
	replace hem_treat_placenta = 0 if ( hem_retain == 1 | hem_retainpart == 1 | hem_restos == 1 | hem_placent == 1 ) & hem_oxi !=. & hem_miso !=. & hem_metr !=. & wom_hem_disposition !=. & cone == "basic"
	replace hem_treat_placenta = 1 if ( hem_retain == 1 | hem_retainpart == 1 | hem_restos == 1 | hem_placent == 1 ) & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & wom_hem_disposition == 3 & cone == "basic"
	//COMP: uterotonico (oxitocina o misoprostol o metilergonovina) + [extracción manual ó legrado o histerectomia]
	replace hem_treat_placenta = 0 if ( hem_retain == 1 | hem_retainpart == 1 | hem_restos == 1 | hem_placent == 1 ) & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_manual !=. & hem_legrado !=. & hem_hist !=. & cone == "comp"
	replace hem_treat_placenta = 1 if ( hem_retain == 1 | hem_retainpart == 1 | hem_restos == 1 | hem_placent == 1 ) & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & ( hem_manual == 1 | hem_legrado == 1 | hem_hist == 1 ) & cone == "comp"

	//Overall treatment
	gen hem_treatment = 1 if hem_treat_abort !=. | hem_treat_ectopic !=. | hem_treat_previa !=. | hem_treat_desp !=. | hem_treat_rupture !=. | hem_treat_atony !=. | hem_treat_inv !=. | hem_treat_placenta !=.
	replace hem_treatment = 0 if hem_treat_abort == 0 | hem_treat_ectopic == 0 | hem_treat_previa == 0 | hem_treat_desp == 0 | hem_treat_rupture == 0 | hem_treat_atony == 0 | hem_treat_inv == 0 | hem_treat_placenta == 0
	
	
//FINAL CALCULATION
	gen hem_norm = 0 if hem_vitsigns !=. & hem_med !=. & cone == "basic"
	replace hem_norm = 1 if hem_vitsigns == 1 & hem_med == 1 & hem_treatment != 0 & cone == "basic"

	replace hem_norm = 0 if hem_vitsigns !=. & hem_med !=. & hem_lab !=. & cone == "comp"
	replace hem_norm = 1 if hem_vitsigns == 1 & hem_med == 1 & hem_lab == 1 & hem_treatment != 0 & cone == "comp"
}

{ // PRE-ECLAMPSIA 4080

// Shorten varnames here
	foreach var in bp hr puls resp pat {
		rename wom_pre_check_reg_`var' pre_`var'
	}

	foreach var in plat asp ala lac creat acid  tgo tgp prot {
		rename wom_pre_lab_reg_`var' pre_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_pre_med_adm_`var' pre_`var'
	}

// CHECKS
	// BASIC: BP
	gen pre_vitsigns = 0 if pre_bp !=. & cone == "basic"
	replace pre_vitsigns = 1 if pre_bp == 1 & cone == "basic"
	
	// COMPLETE: BP + pulse + respiratory rate + patellar reflex 
	replace pre_vitsigns = 0 if pre_bp !=. & pre_puls !=. & pre_hr !=. & pre_resp !=. & pre_pat !=. & cone == "comp"
	replace pre_vitsigns = 1 if pre_bp == 1 & ( pre_puls == 1 | pre_hr == 1 ) & pre_resp == 1 & pre_pat == 1 & cone == "comp"	
 
// LAB
	// BASIC: urine protein
	gen pre_lab = 0 if pre_prot !=. & cone == "basic"
	replace pre_lab = 1 if pre_prot == 1 & cone == "basic"
	
	// COMPLETE: urine protein + platelets + creatine + uric acid + aspartato aminotransferasa/Transaminasa glutámico-oxalacética (TGO o GOT ) + alanina aminotransferasa/Transaminasa glutámico-pirúvica (TGP o GPT) + lactate dehydrogenase
	replace pre_lab = 0 if pre_prot !=. & pre_plat !=. & pre_creat !=. & pre_acid !=. & pre_asp !=. & pre_tgo !=. & pre_ala !=. & pre_tgp !=. & pre_lac !=. & cone == "comp"
	replace pre_lab = 1 if pre_prot == 1 & pre_plat == 1 & pre_creat == 1 & pre_acid == 1 & (pre_asp == 1 | pre_tgo == 1 ) & (pre_ala == 1 | pre_tgp == 1 ) & pre_lac == 1 & cone == "comp"

// MEDS
	//BASIC: magnesium sulfate + saline/ringer's lactate/hartmann 
	gen pre_med = 0 if pre_mgs !=. & pre_sal !=. & pre_lact !=. & pre_hart !=. & cone == "basic"
	replace pre_med = 1 if pre_mgs == 1 & ( pre_sal == 1 | pre_lact == 1 | pre_hart == 1 ) & cone == "basic"
	
	//COMPLETE: magnesium sulfate + hydralazine/labeltalol/nifedipine (if diastolic bp > 110)
	//hydralazine/labeltalol/nifedipine (if diastolic bp > 110)
	gen pre_hydra = 0 if wom_pre_check_bp_110 == 1 & pre_hid !=. & pre_lol !=. & pre_nif !=. 
	replace pre_hydra = 1 if wom_pre_check_bp_110 == 1 & ( pre_hid == 1 | pre_lol == 1 | pre_nif == 1 ) 
	
	replace pre_med = 0 if pre_mgs !=. & cone == "comp"
	replace pre_med = 1 if pre_mgs == 1 & pre_hydra != 0 & cone == "comp"
	
// REFERRED (basic only)
	gen pre_ref = 0 if wom_pre_disposition !=. & cone == "basic"
	replace pre_ref = 1 if wom_pre_disposition == 3 & cone == "basic"
	

//FINAL CALCULATION
	gen  pre_norm = 0 if pre_vitsigns !=. & pre_lab !=. & pre_med !=. & pre_ref !=. & cone == "basic"
	replace pre_norm = 1 if pre_vitsigns == 1 & pre_lab == 1 & pre_med == 1 & pre_ref == 1 & cone == "basic"

	replace pre_norm = 0 if pre_vitsigns !=. & pre_lab !=. & pre_med !=. & cone == "comp"
	replace pre_norm = 1 if pre_vitsigns == 1 & pre_lab == 1 & pre_med == 1 & cone == "comp"
}		

{ // ECLAMPSIA 4080

// Shorten varnames here
	foreach var in bp hr puls resp pat {
		rename wom_ecl_check_reg_`var' ecl_`var'
	}

	foreach var in plat asp ala lac creat acid  tgo tgp prot {
		rename wom_ecl_lab_reg_`var' ecl_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_ecl_med_adm_`var' ecl_`var'
	}

// CHECKS
	// BASIC: BP
	gen ecl_vitsigns = 0 if ecl_bp !=. & cone == "basic"
	replace ecl_vitsigns = 1 if ecl_bp == 1 & cone == "basic"
	
	// COMPLETE: BP + pulse + respiratory rate + patellar reflex 
	replace ecl_vitsigns = 0 if ecl_bp !=. & ecl_puls !=. & ecl_hr !=. & ecl_resp !=. & ecl_pat !=. & cone == "comp"
	replace ecl_vitsigns = 1 if ecl_bp == 1 & ( ecl_puls == 1 | ecl_hr == 1 ) & ecl_resp == 1 & ecl_pat == 1 & cone == "comp"	
 
// LAB
	// BASIC: urine protein
	gen ecl_lab = 0 if ecl_prot !=. & cone == "basic"
	replace ecl_lab = 1 if ecl_prot == 1 & cone == "basic"
	
	// COMPLETE: urine protein + platelets + creatine + uric acid + aspartato aminotransferasa/Transaminasa glutámico-oxalacética (TGO o GOT ) + alanina aminotransferasa/Transaminasa glutámico-pirúvica (TGP o GPT) + lactate dehydrogenase
	replace ecl_lab = 0 if ecl_prot !=. & ecl_plat !=. & ecl_creat !=. & ecl_acid !=. & ecl_asp !=. & ecl_tgo !=. & ecl_ala !=. & ecl_tgp !=. & ecl_lac !=. & cone == "comp"
	replace ecl_lab = 1 if ecl_prot == 1 & ecl_plat == 1 & ecl_creat == 1 & ecl_acid == 1 & (ecl_asp == 1 | ecl_tgo == 1 ) & (ecl_ala == 1 | ecl_tgp == 1 ) & ecl_lac == 1 & cone == "comp"

// MEDS
	//BASIC: magnesium sulfate + saline/ringer's lactate/hartmann 
	gen ecl_med = 0 if ecl_mgs !=. & ecl_sal !=. & ecl_lact !=. & ecl_hart !=. & cone == "basic"
	replace ecl_med = 1 if ecl_mgs == 1 & ( ecl_sal == 1 | ecl_lact == 1 | ecl_hart == 1 ) & cone == "basic"
	
	//COMPLETE: magnesium sulfate + hydralazine/labeltalol/nifedipine (if diastolic bp > 110)
	//hydralazine/labeltalol/nifedipine (if diastolic bp > 110)
	gen ecl_hydra = 0 if wom_ecl_check_bp_110 == 1 & ecl_hid !=. & ecl_lol !=. & ecl_nif !=. 
	replace ecl_hydra = 1 if wom_ecl_check_bp_110 == 1 & ( ecl_hid == 1 | ecl_lol == 1 | ecl_nif == 1 ) 
	
	replace ecl_med = 0 if ecl_mgs !=. & cone == "comp"
	replace ecl_med = 1 if ecl_mgs == 1 & ecl_hydra != 0 & cone == "comp"
	
// REFERRED (basic only)
	gen ecl_ref = 0 if wom_ecl_disposition !=. & cone == "basic"
	replace ecl_ref = 1 if wom_ecl_disposition == 3 & cone == "basic"
	

//FINAL CALCULATION
	gen  ecl_norm = 0 if ecl_vitsigns !=. & ecl_lab !=. & ecl_med !=. & ecl_ref !=. & cone == "basic"
	replace ecl_norm = 1 if ecl_vitsigns == 1 & ecl_lab == 1 & ecl_med == 1 & ecl_ref == 1 & cone == "basic"

	replace ecl_norm = 0 if ecl_vitsigns !=. & ecl_lab !=. & ecl_med !=. & cone == "comp"
	replace ecl_norm = 1 if ecl_vitsigns == 1 & ecl_lab == 1 & ecl_med == 1 & cone == "comp"
}		

{ // SEPSIS 4080

// Shorten varnames here
	foreach var in temp hr puls bp {
		rename wom_sep_check_reg_`var' sep_`var'
	}

	foreach var in leuc plat hgb hmt bio {
		rename wom_sep_lab_reg_`var' sep_`var'
	}

	rename wom_sep_cause_product sep_retain
	foreach var in abort abort2 perf corio pelvicabscess ectinfect pelviper canaltear epistoinfect postendo fever /* retain */ {
		rename wom_sep_cause_`var' sep_`var'
	}

	foreach var in ameu cavidad legrado hist lap suture surg drenaje salpin {
		rename wom_sep_procedures_`var' sep_`var'
	}

//Manage antibiotics variables
	foreach var in ami cli gen amp met peni penicry pip taz {
		rename wom_sep_med_adm_`var' sep_`var'
	}
	
	replace wom_sep_med_oan1_name = lower(wom_sep_med_oan1_name)	
	replace wom_sep_med_ome1_name = lower(wom_sep_med_ome1_name)	
	replace wom_sep_med_ome2_name = lower(wom_sep_med_ome2_name)	
	tab1 wom_sep_med_oan*_name
	tab1 wom_sep_med_ome*_name
	
	//ceftriaxone
	gen sep_ceftr = 0 if mrr_wom_del_comp_sep == 1
	replace sep_ceftr = 1 if regex(wom_sep_med_oan1_name,"ceftriaxona")

	// All-encompasing antibiotic
	gen sep_anti = 0 if sep_ami !=. & sep_cli !=. & sep_gen !=. & sep_amp !=. & sep_met !=. & sep_peni !=. & sep_penicry !=. & sep_pip !=. & sep_taz !=. & sep_ceftr !=.
	replace sep_anti = 1 if sep_ami == 1 | sep_cli == 1 | sep_gen == 1 | sep_amp == 1 | sep_met == 1 | sep_peni == 1 | sep_penicry == 1 | sep_pip == 1 | sep_taz == 1 | sep_ceftr == 1
	
	// Number of antibiotics
	egen num_antibiotics = anycount(sep_ami sep_cli sep_gen sep_amp sep_met sep_peni sep_penicry sep_pip sep_taz sep_ceftr), value(1) 
	
	// Two or more?
	gen sep_anti_double = 0 if num_antibiotics !=. & mrr_wom_del_comp_sep == 1
	replace sep_anti_double = 1 if num_antibiotics > 1 & num_antibiotics !=. & mrr_wom_del_comp_sep == 1
	

// CHECKS - BASIC & COMP: pulse + BP + temperature
	gen sep_vitsigns = 0 if sep_puls !=. & sep_hr !=. & sep_bp !=. & sep_temp !=. 
	replace sep_vitsigns = 1 if ( sep_puls == 1 | sep_hr == 1 ) & sep_bp == 1 & sep_temp == 1 
	
// LAB - COMPLETE: biometría hemática (Hb + Hto + recuento de plaquetas + leucocitos)
	gen sep_lab = 0 if sep_leuc !=. & sep_plat !=. & sep_hgb !=. & sep_hmt !=. & sep_bio !=. & cone == "comp"
	replace sep_lab = 1 if (( sep_leuc == 1 & sep_plat == 1 & sep_hgb == 1 & sep_hmt == 1 ) | sep_bio == 1 ) & cone == "comp"	
 
// MEDS - BASIC & COMP: Antibiotics
	gen sep_med = 0 if sep_anti !=.
	replace sep_med = 1 if sep_anti == 1 
 
//APPROPRIATE CARE

	//Endometritis postparto o post-cesárea
	gen sep_treat_endo = .
	//BASIC: doble o triple terapia antibiótico en la primera dosis
	replace sep_treat_endo = 0 if sep_postendo == 1 & sep_anti_double !=. & cone == "basic"
	replace sep_treat_endo = 1 if sep_postendo == 1 & sep_anti_double == 1 & cone == "basic"
	//COMP: triple o doble terapia antibiótico en la primera dosis
	replace sep_treat_endo = 0 if sep_postendo == 1 & sep_anti_double !=. & cone == "comp"
	replace sep_treat_endo = 1 if sep_postendo == 1 & sep_anti_double == 1 & cone == "comp"
	
	//Absceso pélvico
	gen sep_treat_abscess = .
	//BASIC: antibiótico + traslado a CONE completo
	replace sep_treat_abscess = 0 if sep_pelvicabscess == 1 & sep_anti !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_abscess = 1 if sep_pelvicabscess == 1 & sep_anti == 1 & wom_sep_disposition == 3 & cone == "basic"
	//COMP: antibiótico + [drenaje o laparotomía o histerectomía o reparación quirúrgica]
	replace sep_treat_abscess = 0 if sep_pelvicabscess == 1 & sep_anti !=. & sep_drenaje !=. & sep_lap !=. & sep_hist !=. & sep_surg !=. & cone == "comp"
	replace sep_treat_abscess = 1 if sep_pelvicabscess == 1 & sep_anti == 1 & ( sep_drenaje == 1 | sep_lap == 1 | sep_hist == 1 | sep_surg == 1 ) & cone == "comp"
	
	//Retención de restos placentarios
	gen sep_treat_reten = .
	//BASIC: antibiótico + traslado a CONE completo
	replace sep_treat_reten = 0 if sep_retain == 1 & sep_anti !=. & wom_sep_disposition !=. & cone == "basic"
	replace sep_treat_reten = 1 if sep_retain == 1 & sep_anti == 1 & wom_sep_disposition == 3 & cone == "basic"
	//COMP: antibiótico + [legrado o laparotomía o histerectomía]
	replace sep_treat_reten = 0 if sep_retain == 1 & sep_anti !=. & sep_legrado !=. & sep_lap !=. & sep_hist !=. & cone == "comp"
	replace sep_treat_reten = 1 if sep_retain == 1 & sep_anti == 1 & ( sep_legrado == 1 | sep_lap == 1 | sep_hist == 1 ) & cone == "comp"
	
	//Fiebre puerperal
	gen sep_treat_fever = .
	//BASIC: antibiótico
	replace sep_treat_fever = 0 if sep_fever == 1 & sep_anti !=. & cone == "basic" 
	replace sep_treat_fever = 1 if sep_fever == 1 & sep_anti == 1 & cone == "basic"
	//COMP: antibiótico
	replace sep_treat_fever = 0 if sep_fever == 1 & sep_anti !=. & cone == "comp"
	replace sep_treat_fever = 1 if sep_fever == 1 & sep_anti == 1 & cone == "comp"
		
	//Overall treatment
	gen sep_treatment = 1 if sep_treat_endo !=. | sep_treat_abscess !=. | sep_treat_reten !=. | sep_treat_fever !=.
	replace sep_treatment = 0 if sep_treat_endo == 0 | sep_treat_abscess == 0 | sep_treat_reten == 0 | sep_treat_fever == 0
	
	
//FINAL CALCULATION
	gen sep_norm = .

	replace sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & cone == "basic"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_treatment != 0 & cone == "basic"
		
	replace sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & sep_lab !=. & cone == "comp"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_lab == 1 & sep_treatment != 0 & cone == "comp"	
}

// INDICATOR CALCULATION ************************************************************
	gen I4080 = 0 if sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.
	replace I4080 = 1 if sep_norm !=0 & pre_norm !=0 & ecl_norm !=0 & hem_norm !=0 & (sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.)

	// Indicator value - NOTE: EVALUATION PERIOD INDICATOR VALUE ONLY APPLICABLE TO COMPLETE LEVEL 
	prop I4080 if time == "pre-evaluation" & tx_area == 1 & cone == "comp"
	prop I4080 if time == "evaluation" & tx_area == 1 & cone == "comp"
