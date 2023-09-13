************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// November 2022 - IHME
// El Salvador Performance Indicator 4080
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

 // MATERNAL COMPLICATIONS RECORDS (4080)
	use "IHME_SMI_BLZ_HFS_2022_MATCOMP_Y2023M08D17.dta", clear

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
	
	//*Evaluation* period date range (admission date) (7/1/2020 - 9/26/2021)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (admission date) (1/1/2019 - 9/26/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Format variables if necessary
	replace wom_gestage = . if wom_gestage ==-1
	
//Manage antibiotics variables here 
	foreach var in ami cli gen amp met peni penicry pip taz {
		rename wom_sep_med_adm_`var' sep_`var'
	}
	rename wom_hem_med_adm_gen hem_gen

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
		
		//cefalexin
		gen `comp'_cefa = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_cefa = 1 if regex(wom_`comp'_med_oan1_name, "cefa") | regex(wom_`comp'_med_ome1_name, "cefa") | regex(wom_`comp'_med_ome2_name, "cefa") | regex(wom_`comp'_med_ome3_name, "cefa")

		//amoxicillin
		gen `comp'_amoxi = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_amoxi = 1 if regex(wom_`comp'_med_oan1_name, "amoxi") | regex(wom_`comp'_med_ome1_name, "amoxi") | regex(wom_`comp'_med_ome2_name, "amoxi") | regex(wom_`comp'_med_ome3_name, "amoxi")
		
		//clindamycin
		cap gen `comp'_cli = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_cli = 1 if regex(wom_`comp'_med_oan1_name, "clinda") | regex(wom_`comp'_med_ome1_name, "clinda") | regex(wom_`comp'_med_ome2_name, "clinda") | regex(wom_`comp'_med_ome3_name, "clinda") | regex(wom_`comp'_med_oan1_name, "climda") | regex(wom_`comp'_med_ome1_name, "climda") | regex(wom_`comp'_med_ome2_name, "climda") | regex(wom_`comp'_med_ome3_name, "climda")
		
		//metronidazole
		cap gen `comp'_met = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_met = 1 if regex(wom_`comp'_med_oan1_name, "metron") | regex(wom_`comp'_med_ome1_name, "metron") | regex(wom_`comp'_med_ome2_name, "metron") | regex(wom_`comp'_med_ome3_name, "metron") | regex(wom_`comp'_med_oan1_name, "flagyl") | regex(wom_`comp'_med_ome1_name, "flagyl") | regex(wom_`comp'_med_ome2_name, "flagyl") | regex(wom_`comp'_med_ome3_name, "flagyl")
		
		//ampicillin
		cap gen `comp'_amp = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_amp = 1 if regex(wom_`comp'_med_oan1_name, "ampic") | regex(wom_`comp'_med_ome1_name, "ampic") | regex(wom_`comp'_med_ome2_name, "ampic") | regex(wom_`comp'_med_ome3_name, "ampic")

		//gentamycin
		cap gen `comp'_gen = 0 if wom_`comp'_med_adm_oan1 !=. & wom_`comp'_med_adm_ome1 !=. & wom_`comp'_med_adm_ome2 !=. & wom_`comp'_med_adm_ome3 !=.
		replace `comp'_gen = 1 if regex(wom_`comp'_med_oan1_name, "genta") | regex(wom_`comp'_med_ome1_name, "genta") | regex(wom_`comp'_med_ome2_name, "genta") | regex(wom_`comp'_med_ome3_name, "genta")

	}

// For each one, check whether it was administered once
	foreach var in ceftr cefa amoxi amp gen ami cli met peni penicry pip taz {
		cap gen hem_`var' =.
		cap gen pre_`var' =.
		cap gen sep_`var' =.
		cap gen ecl_`var' =.
		
		gen allcomps_`var' = 0 if hem_`var' !=. | pre_`var' !=. | sep_`var' !=. | ecl_`var' !=.
		replace allcomps_`var' = 1 if hem_`var' == 1 | pre_`var' == 1 | sep_`var' == 1 | ecl_`var' == 1
	}	
	
// For double/triple therapy, check whether two or more antibiotics were administered
	// Number administered
	egen num_antibiotics = anycount(allcomps_ceftr allcomps_cefa allcomps_amoxi allcomps_amp allcomps_gen allcomps_ami allcomps_cli allcomps_met allcomps_peni allcomps_penicry allcomps_pip allcomps_taz), value(1) 
	// At least one?
	gen anti = 0 if num_antibiotics !=.
	replace anti = 1 if num_antibiotics >= 1 & num_antibiotics !=.
	// Two or more?
	gen double_anti = 0 if num_antibiotics !=.
	replace double_anti = 1 if num_antibiotics > 1 & num_antibiotics !=.
	

{ // HEMORRHAGE 4080
/* Pulso/Frecuencia cardiaca + hematócrito + hemoglobina + tiempo de protrombina + tiempo parcial de tromboplastina + conteo de plaquetas + presión arterial + lactato de Ringer/Hartman o solución salina + (manejo adecuado o traslado)
	Opciones de manejo:
•	Si hemorragia posterior al aborto o aborto incompleto (excepto amenaza de aborto): AMEU o curetaje instrumental o traslado 
•	Si embarazo ectópico roto: laparotomía o laparoscopia o salpinguectomía o salpingostomía o fimbriectomía o histerectomía o traslado 
•	Si placenta previa o desprendimiento de placenta: laparotomia o histerectomia o cesárea o desarterialización o traslado 
•	Si ruptura uterina: (laparotomía o histerectomía o reparación quirúrgica o pinzamiento de las arterias uterinas o cesárea) o traslado 
•	Si atonia uterina: uterotónicos (oxitocina u otros) + (compresiones bimanuales o compresiones con material de sutura o masaje uterino o balón de Bacri/hidrostático o pinzamiento de las arterias uterinas o sangrado se detuvo o taponamiento uterino o histerectomía) o traslado [si inversión uterina, los uterotónicos sólo deben ser administrados si la inversión uterina fue resuelta]
•	Si inversión uterina: [Reposición uterina con o sin analgesia o sedante por técnicas no quirúrgicas (maniobra de Johnson) o quirúrgicas (maniobras de Huntington o Haultani) + uterotónicos (oxitocina u otros)] o traslado 
•	Si retención de placenta: extracción manual o histerectomía o traslado 
•	Si retención de restos de placenta o membranas: uterotónicos (oxitocina u otros) + extracción manual con analgesia o legrado digital o (legrado o curetaje con Cureta de Wallish) o traslado 
•	Casos de laceraciones o desgarros deben ser excluidos
 */

// Shorten varnames here
	foreach var in bp puls hr {
		rename wom_hem_check_reg_`var' hem_`var'
	}

	foreach var in hgb hmt plat pt ptt {
		rename wom_hem_lab_reg_`var' hem_`var'
	}

	foreach var in oxi lact hart sal miso metr out {
		rename wom_hem_med_adm_`var' hem_`var'
	}

	foreach var in abort abort2 abort3 retain retainpart restos placent previa previa2 premature placenta rupture rupturev rupturec atony hipo ectopic ectopicroto descerv descanal desvulvo inversion {
		rename wom_hem_cause_`var' hem_`var'
	}

	foreach var in ameu cavidad legrado csec hist lap suture surg suture2 drenaje salpin masaje biman aorta tap balon manual rep utart oth {
		rename wom_hem_procedures_`var' hem_`var'
	}

// CHECKS: Pulso/Frecuencia cardiaca + presión arterial 
	gen hem_vitsigns = 0 if hem_puls !=. & hem_hr !=. & hem_bp !=. 
	replace hem_vitsigns = 1 if ( hem_puls == 1 | hem_hr == 1 ) & hem_bp == 1 

// LAB: hematócrito + hemoglobina + conteo de plaquetas  + tiempo de protrombina + tiempo parcial de tromboplastina 
	gen hem_lab = 0 if hem_hmt !=. & hem_hgb !=. & hem_plat !=. & hem_pt !=. & hem_ptt !=.
	replace hem_lab = 1 if hem_hmt == 1 & hem_hgb == 1 & hem_plat == 1 & hem_pt == 1 & hem_ptt == 1
	
// MEDS: lactato de Ringer/Hartman o solución salina
	gen hem_med = 0 if hem_lact !=. & hem_hart !=. & hem_sal !=. 
	replace hem_med = 1 if ( hem_lact == 1 | hem_hart == 1 | hem_sal == 1 ) 

// APPROPRIATE TREATMENT

	// Hemorragia posterior al aborto o aborto incompleto (excepto amenaza de aborto): AMEU o curetaje instrumental o traslado
	gen hem_treat_abort = 0 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & hem_ameu !=. & hem_legrado !=. & wom_hem_disposition !=.
	replace hem_treat_abort = 1 if ( hem_abort == 1 | hem_abort2 == 1 | hem_abort3 == 1 ) & ( hem_ameu == 1 | hem_legrado == 1 | wom_hem_disposition == 3 )
	
	// Embarazo ectópico roto: laparotomía o laparoscopia o salpinguectomía o salpingostomía o fimbriectomía o histerectomía o traslado 
	gen hem_treat_ectopic = 0 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & hem_lap !=. & hem_salpin !=. & hem_surg !=. & hem_hist !=. & wom_hem_disposition !=.
	replace hem_treat_ectopic = 1 if ( hem_ectopic == 1 | hem_ectopicroto == 1 ) & ( hem_lap == 1 | hem_salpin == 1 | hem_surg == 1 | hem_hist == 1 | wom_hem_disposition == 3 )
	
	// Placenta previa o desprendimiento de placenta: laparotomia o histerectomia o cesárea o desarterialización o traslado 
	gen  hem_treat_previa = 0 if ( hem_previa == 1 | hem_previa2 == 1 | hem_premature == 1 | hem_placenta == 1 ) & hem_lap !=. & hem_hist !=. & hem_utart !=. & hem_csec !=. & wom_hem_result !=. & wom_hem_disposition !=.
	replace hem_treat_previa = 1 if ( hem_previa == 1 | hem_previa2 == 1 | hem_premature == 1 | hem_placenta == 1 ) & ( hem_lap == 1 & hem_hist == 1 & hem_utart == 1 & hem_csec == 1 | wom_hem_result == 2 | wom_hem_result == 3 | wom_hem_disposition == 3 )
	
	//Ruptura uterina: laparotomía o histerectomía o reparación quirúrgica o pinzamiento de las arterias uterinas o cesárea o traslado 
	gen hem_treat_rupture = 0 if hem_rupture == 1 & hem_lap !=. & hem_hist !=. & hem_surg !=. & hem_utart !=. & hem_csec !=. & wom_hem_result !=. & wom_hem_disposition !=.
	replace hem_treat_rupture = 1 if hem_rupture == 1 & ( hem_lap == 1 | hem_hist == 1 | hem_surg == 1 | hem_utart == 1 | hem_csec == 1 | wom_hem_result == 2 | wom_hem_result == 3 | wom_hem_disposition == 3 ) 
	
	//Atonía uterina: uterotónicos (oxitocina u otros) + (compresiones bimanuales o compresiones con material de sutura o masaje uterino o balón de Bacri/hidrostático o pinzamiento de las arterias uterinas o sangrado se detuvo o taponamiento uterino o histerectomía) o traslado
	gen hem_treat_atony = 0 if hem_atony == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_biman !=. & hem_suture2 !=. & hem_masaje !=. & hem_balon !=. & hem_utart !=. & hem_utart !=. & hem_tap !=. & hem_hist !=. & wom_hem_disposition !=.
	replace hem_treat_atony = 1 if hem_atony == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & ( hem_biman == 1 | hem_suture2 == 1 | hem_masaje == 1 | hem_balon == 1 | hem_utart == 1 | hem_tap == 1 | hem_hist == 1 | wom_hem_disposition == 3 )
	
	//Inversión uterina: uterotónicos (oxitocina u otros) + (Reposición uterina con o sin analgesia o sedante por técnicas no quirúrgicas (maniobra de Johnson) o quirúrgicas (maniobras de Huntington o Haultani) o traslado
	gen hem_treat_inv = 0 if hem_inversion == 1 & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_rep !=. & hem_hist !=. & wom_hem_disposition !=.
	replace hem_treat_inv = 1 if hem_inversion == 1 & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & (( hem_rep == 1 & ( wom_hem_reposition_sed == 1 | wom_hem_reposition_sed == 2 | wom_hem_reposition_sed == 3 )) | wom_hem_disposition == 3 )
	
	//Retención de placenta: extracción manual o histerectomía o traslado 
	gen hem_treat_placenta = 0 if ( hem_retain == 1 | hem_retainpart == 1 ) & hem_manual !=. & hem_hist !=. & wom_hem_disposition !=.
	replace hem_treat_placenta = 1 if ( hem_retain == 1 | hem_retainpart == 1 ) & ( hem_manual == 1 | hem_hist == 1 | wom_hem_disposition == 3 )
	
	//Retención de restos de placenta o membranas: uterotónicos (oxitocina u otros) + extracción manual con analgesia o legrado digital o (legrado o curetaje con Cureta de Wallish) o traslado 
	gen hem_treat_rest = 0 if ( hem_restos == 1 | hem_placent == 1 ) & hem_oxi !=. & hem_miso !=. & hem_metr !=. & hem_manual !=. & hem_legrado !=. & wom_hem_disposition !=.
	replace hem_treat_rest = 1 if ( hem_restos == 1 | hem_placent == 1 ) & ( hem_oxi == 1 | hem_miso == 1 | hem_metr == 1 ) & ( hem_manual == 1 | hem_legrado == 1 | wom_hem_disposition == 3 )
	
	//Overall treatment
	gen hem_treatment = 1 if hem_treat_abort !=. | hem_treat_ectopic !=. | hem_treat_previa !=. | hem_treat_rupture !=. | hem_treat_atony !=. | hem_treat_inv !=. | hem_treat_placenta !=. | hem_treat_rest !=.
	replace hem_treatment = 0 if hem_treat_abort == 0 | hem_treat_ectopic == 0 | hem_treat_previa == 0 | hem_treat_rupture == 0 | hem_treat_atony == 0 | hem_treat_inv == 0 | hem_treat_placenta == 0 | hem_treat_rest == 0
	
	
//FINAL CALCULATION
	gen hem_norm = 0 if hem_vitsigns !=. & hem_med !=. & hem_lab !=.
	replace hem_norm = 1 if hem_vitsigns == 1 & hem_med == 1 & hem_lab == 1 & hem_treatment != 0

	//Casos de laceraciones o desgarros deben ser excluidos
	replace hem_norm = . if hem_descerv == 1 | hem_descanal == 1 | hem_desvulvo == 1
}

{ // PRE-ECLAMPSIA 4080 
/* PA sistólica + PA diastólica + pulso + frecuencia respiratoria + reflejo rotuliano patelar + lactato de Ringer o solución salina + sulfato de magnesio (dosis de carga de acuerdo a protocolo*) + (si PA sistólica>=160 o PA diastólica>=110: hidralazina o labetalol o nifedipina) + (si la edad gestacional 24-35 semanas: dexametasona o betametasona) + detección de proteína en orina + conteo de plaquetas + aspartato aminotransferasa + alanina aminotransferasa  */

// Shorten varnames here
	foreach var in bp hr puls resp pat {
		rename wom_pre_check_reg_`var' pre_`var'
	}

	foreach var in plat asp ala lac creat acid tgo tgp prot {
		rename wom_pre_lab_reg_`var' pre_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_pre_med_adm_`var' pre_`var'
	}

// CHECKS: PA sistólica + PA diastólica + pulso + frecuencia respiratoria + reflejo rotuliano patelar
	gen pre_vitsigns = 0 if pre_bp !=. & pre_puls !=. & pre_hr !=. & pre_resp !=. & pre_pat !=.
	replace pre_vitsigns = 1 if pre_bp == 1 & ( pre_puls == 1 | pre_hr == 1 ) & pre_resp == 1 & pre_pat == 1 	
 
// LAB: detección de proteína en orina + conteo de plaquetas + aspartato aminotransferasa + alanina aminotransferasa
	gen pre_lab = 0 if pre_prot !=. & pre_plat !=. & pre_asp !=. & pre_ala !=. 
	replace pre_lab = 1 if pre_prot == 1 & pre_plat == 1 & pre_asp == 1 & pre_ala == 1

// MEDS: lactato de Ringer o solución salina + sulfato de magnesio (dosis de carga de acuerdo a protocolo*) + (si PA sistólica>=160 o PA diastólica>=110: hidralazina o labetalol o nifedipina) + (si la edad gestacional 24-35 semanas: dexametasona o betametasona)
	gen pre_ringlacsal = 0 if pre_lact !=. & pre_hart !=. & pre_sal !=. 
	replace pre_ringlacsal = 1 if pre_lact == 1 | pre_hart == 1 | pre_sal == 1 
	
	//hidralazina o labetalol o nifedipina (si PA sistólica>=160 o PA diastólica>=110)
	gen pre_bp_above = 0 if wom_pre_check_bp_110 !=. & wom_pre_check_num_bp_dias !=. & wom_pre_check_num_bp_sys !=.
	replace pre_bp_above = 1 if wom_pre_check_bp_110 == 1 | ( wom_pre_check_num_bp_dias >= 110 & wom_pre_check_num_bp_dias !=. ) | ( wom_pre_check_num_bp_sys >= 160 & wom_pre_check_num_bp_sys !=. )
	
	gen pre_hydra = 0 if pre_bp_above == 1 & pre_hid !=. & pre_lol !=. & pre_nif !=. 
	replace pre_hydra = 1 if pre_bp_above == 1 & ( pre_hid == 1 | pre_lol == 1 | pre_nif == 1 ) 
	
	//dexametasona o betametasona (si la edad gestacional 24-35 semanas)
	gen pre_dexbet = 0 if wom_gestage >= 24 & wom_gestage <= 35 & wom_gestage !=. & pre_dex !=. & pre_bet !=.
	replace pre_dexbet = 1 if wom_gestage >= 24 & wom_gestage <= 35 & wom_gestage !=. & ( pre_dex == 1 | pre_bet == 1 )
	
	gen pre_med = 0 if pre_ringlacsal !=. & pre_mgs !=. 
	replace pre_med = 1 if pre_ringlacsal == 1 & pre_mgs == 1 & pre_hydra != 0 & pre_dexbet != 0
	

//FINAL CALCULATION
	gen pre_norm = 0 if pre_vitsigns !=. & pre_lab !=. & pre_med !=. 
	replace pre_norm = 1 if pre_vitsigns == 1 & pre_lab == 1 & pre_med == 1
}		

{ // ECLAMPSIA 4080
/* PA sistólica + PA diastólica + pulso + frecuencia respiratoria + reflejo rotuliano patelar + lactato de Ringer o solución salina + sulfato de magnesio (dosis de carga de acuerdo a protocolo*) + (si PA sistólica>=160 o PA diastólica>=110: hidralazina o labetalol o nifedipina) + (si la edad gestacional 24-35 semanas: dexametasona o betametasona) + detección de proteína en orina + conteo de plaquetas + aspartato aminotransferasa + alanina aminotransferasa  */

// Shorten varnames here
	foreach var in bp hr puls resp pat {
		rename wom_ecl_check_reg_`var' ecl_`var'
	}

	foreach var in plat asp ala lac creat acid tgo tgp prot {
		rename wom_ecl_lab_reg_`var' ecl_`var'
	}

	foreach var in mgs hid nif bet dex sal lact hart lol {
		rename wom_ecl_med_adm_`var' ecl_`var'
	}

// CHECKS: PA sistólica + PA diastólica + pulso + frecuencia respiratoria + reflejo rotuliano patelar
	gen ecl_vitsigns = 0 if ecl_bp !=. & ecl_puls !=. & ecl_hr !=. & ecl_resp !=. & ecl_pat !=.
	replace ecl_vitsigns = 1 if ecl_bp == 1 & ( ecl_puls == 1 | ecl_hr == 1 ) & ecl_resp == 1 & ecl_pat == 1 	
 
// LAB: detección de proteína en orina + conteo de plaquetas + aspartato aminotransferasa + alanina aminotransferasa
	gen ecl_lab = 0 if ecl_prot !=. & ecl_plat !=. & ecl_asp !=. & ecl_ala !=. 
	replace ecl_lab = 1 if ecl_prot == 1 & ecl_plat == 1 & ecl_asp == 1 & ecl_ala == 1

// MEDS: lactato de Ringer o solución salina + sulfato de magnesio (dosis de carga de acuerdo a protocolo*) + (si PA sistólica>=160 o PA diastólica>=110: hidralazina o labetalol o nifedipina) + (si la edad gestacional 24-35 semanas: dexametasona o betametasona)
	gen ecl_ringlacsal = 0 if ecl_lact !=. & ecl_hart !=. & ecl_sal !=. 
	replace ecl_ringlacsal = 1 if ecl_lact == 1 | ecl_hart == 1 | ecl_sal == 1 
	
	//hidralazina o labetalol o nifedipina (i PA sistólica>=160 o PA diastólica>=110)
	gen ecl_bp_above = 0 if wom_ecl_check_bp_110 !=. & wom_ecl_check_num_bp_dias !=. & wom_ecl_check_num_bp_sys !=.
	replace ecl_bp_above = 1 if wom_ecl_check_bp_110 == 1 | ( wom_ecl_check_num_bp_dias >= 110 & wom_ecl_check_num_bp_dias !=. ) | ( wom_ecl_check_num_bp_sys >= 160 & wom_ecl_check_num_bp_sys !=. )
	
	gen ecl_hydra = 0 if ecl_bp_above == 1 & ecl_hid !=. & ecl_lol !=. & ecl_nif !=. 
	replace ecl_hydra = 1 if ecl_bp_above == 1 & ( ecl_hid == 1 | ecl_lol == 1 | ecl_nif == 1 ) 
	
	//dexametasona o betametasona (si la edad gestacional 24-35 semanas)
	gen ecl_dexbet = 0 if wom_gestage >= 24 & wom_gestage <= 35 & wom_gestage !=. & ecl_dex !=. & ecl_bet !=.
	replace ecl_dexbet = 1 if wom_gestage >= 24 & wom_gestage <= 35 & wom_gestage !=. & ( ecl_dex == 1 | ecl_bet == 1 )
	
	gen ecl_med = 0 if ecl_ringlacsal !=. & ecl_mgs !=. 
	replace ecl_med = 1 if ecl_ringlacsal == 1 & ecl_mgs == 1 & ecl_hydra != 0 & ecl_dexbet != 0
	

//FINAL CALCULATION
	gen ecl_norm = 0 if ecl_vitsigns !=. & ecl_lab !=. & ecl_med !=. 
	replace ecl_norm = 1 if ecl_vitsigns == 1 & ecl_lab == 1 & ecl_med == 1
}		

{ // SEPSIS 4080
/* temperatura + pulso + presión arterial + biometría hemática (hemoglobina + hematócrito + conteo de plaquetas + conteo de leucocitos) + administración de antibióticos (doble terapia en la 1ª dosis*) + manejo adecuado
Opciones de manejo:
•	Si aborto séptico: AMEU o legrado instrumental o histerectomía o traslado
•	Si perforación uterina: laparotomía o laparoscopía o histerectomía o reparación quirúrgica o traslado 
•	Si absceso pélvico: laparotomía o drenado o histerectomía o traslado
•	Si endometritis postparto: Dilatación cervical o legrado instrumental o histerectomía o traslado
•	Si retención de productos de la concepción: Legrado instrumental o laparotomía o histerectomía o traslado
•	Si fiebre puerperal o puerperio mórbido: administración de antibióticos o traslado */

// Shorten varnames here
	foreach var in temp hr puls bp {
		rename wom_sep_check_reg_`var' sep_`var'
	}

	foreach var in leuc plat hgb hmt bio {
		rename wom_sep_lab_reg_`var' sep_`var'
	}

	foreach var in abort abort2 perf corio pelvicabscess ectinfect pelviper canaltear epistoinfect postendo fever product /* retain */ {
		rename wom_sep_cause_`var' sep_`var'
	}

	foreach var in ameu cavidad legrado hist lap suture surg drenaje salpin {
		rename wom_sep_procedures_`var' sep_`var'
	}

// CHECKS: temperatura + pulso + presión arterial
	gen sep_vitsigns = 0 if sep_puls !=. & sep_hr !=. & sep_bp !=. & sep_temp !=. 
	replace sep_vitsigns = 1 if ( sep_puls == 1 | sep_hr == 1 ) & sep_bp == 1 & sep_temp == 1 
	
// LAB: biometría hemática (hemoglobina + hematócrito + conteo de plaquetas + conteo de leucocitos)
	gen sep_lab = 0 if sep_leuc !=. & sep_plat !=. & sep_hgb !=. & sep_hmt !=. & sep_bio !=.
	replace sep_lab = 1 if ( sep_leuc == 1 & sep_plat == 1 & sep_hgb == 1 & sep_hmt == 1 ) | sep_bio == 1 
 
// MEDS: administración de antibióticos (doble terapia en la 1ª dosis*)
	gen sep_med = 0 if double_anti !=. & mrr_wom_del_comp_sep == 1
	replace sep_med = 1 if double_anti == 1 & mrr_wom_del_comp_sep == 1 
 
//APPROPRIATE CARE

	//Si aborto séptico: AMEU o legrado instrumental o histerectomía o traslado
	gen sep_treat_abort = 0 if ( sep_abort == 1 | sep_abort2 == 1 ) & sep_ameu !=. & sep_legrado !=. & sep_hist !=. & wom_sep_disposition !=.
	replace sep_treat_abort = 1 if ( sep_abort == 1 | sep_abort2 == 1 ) & ( sep_ameu == 1 | sep_legrado == 1 | sep_hist == 1 | wom_sep_disposition == 3 ) 
	
	//Si perforación uterina: laparotomía o laparoscopía o histerectomía o reparación quirúrgica o traslado 
	gen sep_treat_perf = 0 if sep_perf == 1 & sep_lap !=. & sep_hist !=. & sep_surg !=. & wom_sep_disposition !=.
	replace sep_treat_perf = 0 if sep_perf == 1 & ( sep_lap == 1 | sep_hist == 1 | sep_surg == 1 | wom_sep_disposition == 3 ) 
	
	//Si absceso pélvico: laparotomía o drenado o histerectomía o traslado
	gen sep_treat_abscess = 0 if sep_pelvicabscess == 1 & sep_lap !=. & sep_hist !=. & sep_drenaje !=. & wom_sep_disposition !=.
	replace sep_treat_abscess = 0 if sep_pelvicabscess == 1 & ( sep_lap == 1 | sep_hist == 1 | sep_drenaje == 1 | wom_sep_disposition == 3 ) 

	//Si endometritis postparto: Dilatación cervical o legrado instrumental o histerectomía o traslado
	gen sep_treat_endo = 0 if sep_postendo == 1 & sep_legrado !=. & sep_hist !=. & wom_sep_disposition !=.
	replace sep_treat_endo = 1 if sep_postendo == 1 & ( sep_legrado == 1 | sep_hist == 1 | wom_sep_disposition == 3 )

	//Si retención de productos de la concepción: Legrado instrumental o laparotomía o histerectomía o traslado
	gen sep_treat_reten = 0 if sep_product == 1 & sep_legrado !=. & sep_lap !=. & sep_hist !=. & wom_sep_disposition !=.
	replace sep_treat_reten = 1 if sep_product == 1 & ( sep_legrado == 1 | sep_lap == 1 | sep_hist == 1 | wom_sep_disposition == 3 )

	//Si fiebre puerperal o puerperio mórbido: administración de antibióticos o traslado 	
	gen sep_treat_fev = 0 if sep_fever == 1 & anti !=. & wom_sep_disposition !=.
	replace sep_treat_fev = 1 if sep_fever == 1 & ( anti == 1 | wom_sep_disposition == 3 )
	
	//Overall treatment
	gen  sep_treatment = 1 if sep_treat_abort !=. | sep_treat_perf !=. | sep_treat_abscess !=. | sep_treat_endo !=. | sep_treat_reten !=. | sep_treat_fev !=.
	replace sep_treatment = 0 if sep_treat_abort == 0 | sep_treat_perf == 0 | sep_treat_abscess == 0 | sep_treat_endo == 0 | sep_treat_reten == 0 | sep_treat_fev == 0
	
	
//FINAL CALCULATION
	gen sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & sep_lab !=. 
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_lab == 1 & sep_treatment != 0
}

// INDICATOR CALCULATION ************************************************************
	gen I4080 = 0 if sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.
	replace I4080 = 1 if sep_norm !=0 & pre_norm !=0 & ecl_norm !=0 & hem_norm !=0 & (sep_norm !=. | pre_norm !=. | ecl_norm !=. | hem_norm !=.)

	// Indicator value
	prop I4080 if time == "pre-evaluation" & tx_area == 1
	prop I4080 if time == "evaluation" & tx_area == 1
