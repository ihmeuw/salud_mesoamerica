************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 4070
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
************************************

 // NEONATAL COMPLICATIONS RECORDS (4070)
	use "IHME_SMI_BLZ_HFS_2022_NEOCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4070: Neonatal complications (sepsis, asphyxia, prematurity, and low birth weight) managed according to the norm in the last two years
***************************************************************************************

//NOTE: neonatal complications disposition specified: Died 2 hours after birth in the ambulance. -> Case excluded.
	drop if neo_disposition_spec == "Died 2 hours after birth in the ambulance"


// Denominator: Total number of neonatal complications records in our sample  
	
	// Must have a complication
	drop if mrr_neo_comp_no == 1
	tab mrr_neo_comp, m
	
	//Basic and Complete
	cap gen cone = ""
	replace cone = "amb" if fac_type == 1
	replace cone = "basic" if fac_type == 2
	replace cone = "comp" if fac_type == 3
	
	keep if cone == "basic" | cone == "comp"

{ //Date restrictions 
	gen record_date = date(neo_adm_dates_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (7/16/2020 - 7/15/2022)
	replace time = "evaluation" if record_date >= date("2020-7-16", "YMD") & record_date <= date("2022-7-15", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 7/15/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-7-15", "YMD")

	//Keep only eligible records
	drop if time == ""
}	


// Format variables if necessary
	destring neo_*_check_num_ap5, replace
		
// Rename some variables
	foreach var in amp amik sulb pip clind gen metron peni penicry taz difenil diaze {
		rename neo_lbw_med_adm_`var' lbw_`var'
	}
		
	foreach var in amp amik sulb pip clind gen metron peni penicry taz ors difenil diaze {
		rename neo_pre_med_adm_`var' pre_`var'
	}

	foreach var in amp amik sulb pip gen {
		rename neo_asp_med_adm_`var' asp_`var'
	}		
		
	foreach var in amp amik sulb pip clind gen metron peni penicry taz {
		rename neo_sep_med_adm_`var' sep_`var'
	}
	

//Manage antibiotics variables here
	tab1 *med*name

// Generate antibiotics variables from 'other specify'
	foreach comp in lbw asp sep pre {
		//format
		foreach type in oan ome1 ome2 {
			tostring  neo_`comp'_med_`type'_name, replace
			replace neo_`comp'_med_`type'_name = "" if neo_`comp'_med_`type'_name == "."
			replace neo_`comp'_med_`type'_name = lower(neo_`comp'_med_`type'_name)
		}

		//amoxicillin
		gen `comp'_amoxi = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_amoxi = 1 if regex(neo_`comp'_med_oan_name, "amoxi") | regex(neo_`comp'_med_ome1_name, "amoxi") | regex(neo_`comp'_med_ome2_name, "amoxi")

		//cefotaxime
		gen `comp'_cefotax = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_cefotax = 1 if regex(neo_`comp'_med_oan_name, "cefot") | regex(neo_`comp'_med_ome1_name, "cefot") | regex(neo_`comp'_med_ome2_name, "cefot")
		
		//cefuroxime
		gen `comp'_cefuro = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_cefuro = 1 if regex(neo_`comp'_med_oan_name, "cefur") | regex(neo_`comp'_med_ome1_name, "cefur") | regex(neo_`comp'_med_ome2_name, "cefur")
		
		//cloxacillin 
		gen `comp'_cloxa = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_cloxa = 1 if regex(neo_`comp'_med_oan_name, "clox") | regex(neo_`comp'_med_ome1_name, "clox") | regex(neo_`comp'_med_ome2_name, "clox")
		
		//vancomicin 
		gen `comp'_vanco = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_vanco = 1 if regex(neo_`comp'_med_oan_name, "vanco") | regex(neo_`comp'_med_ome1_name, "vanco") | regex(neo_`comp'_med_ome2_name, "vanco")
		
		//ceftazidime 
		gen `comp'_ceftaz = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_ceftaz = 1 if regex(neo_`comp'_med_oan_name, "ceftaz") | regex(neo_`comp'_med_ome1_name, "ceftaz") | regex(neo_`comp'_med_ome2_name, "ceftaz")
		
		//chloramphenicol
		gen `comp'_chloram = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_chloram = 1 if regex(neo_`comp'_med_oan_name, "chloram") | regex(neo_`comp'_med_ome1_name, "chloram") | regex(neo_`comp'_med_ome2_name, "chloram")
	}

	//metronidazol
	gen asp_metron = 1 if regex(neo_asp_med_oan_name, "flagyl")

	
// For each one, check whether it was administered once
	foreach var in amoxi cefotax cefuro cloxa vanco ceftaz chloram amp amik sulb pip clind gen metron peni penicry taz {
		cap gen lbw_`var' =.
		cap gen pre_`var' =.
		cap gen sep_`var' =.
		cap gen asp_`var' =.
		
		gen allcomps_`var' = 0 if lbw_`var' !=. | pre_`var' !=. | sep_`var' !=. | asp_`var' !=.
		replace allcomps_`var' = 1 if lbw_`var' == 1 | pre_`var' == 1 | sep_`var' == 1 | asp_`var' == 1
	}	
	
// One antibiotic administered?
	gen anti = 0 if allcomps_amoxi !=. | allcomps_cefotax !=. | allcomps_cefuro !=. | allcomps_cloxa !=. | allcomps_vanco !=. | allcomps_ceftaz !=. | allcomps_chloram !=. | allcomps_amp !=. | allcomps_amik !=. | allcomps_sulb !=. | allcomps_pip !=. | allcomps_clind !=. | allcomps_gen !=. | allcomps_metron !=. | allcomps_peni !=. | allcomps_penicry !=. | allcomps_taz !=.
	replace anti = 1 if allcomps_amoxi ==1 | allcomps_cefotax ==1 | allcomps_cefuro ==1 | allcomps_cloxa ==1 | allcomps_vanco ==1 | allcomps_ceftaz ==1 | allcomps_chloram ==1 | allcomps_amp ==1 | allcomps_amik ==1 | allcomps_sulb ==1 | allcomps_pip ==1 | allcomps_clind ==1 | allcomps_gen ==1 | allcomps_metron ==1 | allcomps_peni ==1 | allcomps_penicry ==1 | allcomps_taz ==1


// For double/triple therapy, check whether two or more antibiotics were administered
	// Number administered
	egen num_antibiotics = anycount(allcomps_amoxi allcomps_cefotax allcomps_cefuro allcomps_cloxa allcomps_vanco allcomps_ceftaz allcomps_chloram allcomps_amp allcomps_amik allcomps_sulb allcomps_pip allcomps_clind allcomps_gen allcomps_metron allcomps_peni allcomps_penicry allcomps_taz), value(1) 
	// Two or more?
	gen double_anti = 0 if num_antibiotics !=.
	replace double_anti = 1 if num_antibiotics > 1 & num_antibiotics !=.



{ // ASPHYXIA 4070 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in hr resp ap1 ap5 puls {
		rename neo_asp_check_reg_`var' asp_`var'
	}
	rename neo_asp_check_num_ap5 asp_num_ap5
	rename neo_asp_lab_reg_oxy lab_oxy
		
	foreach var in inc wrap warmsheet lamp warmer kang plastic bacin {
		rename neo_asp_proc_heat_`var' asp_`var'
	}
		
	foreach var in intub compression {
		rename neo_asp_proc_oth_`var' asp_`var'
	}
		
	foreach var in ambu posvent ventmec bolsa 100 maskoxy mask maskres headbox cone helmet campcef cyl cylcap cpap tank nasal cath canula vent {
		rename neo_asp_proc_oxy_`var' asp_`var'
	}

// CHECKS - BASIC & COMPLETE: Passive hypothermia + Heart rate + Respiratory rate + APGAR score at 1 minute + APGAR score at 5 minutes [NOTE at 3rd operation: we did not capture passive hypothermia]
	gen asp_vitsigns = 0 if asp_puls !=. & asp_hr !=. & asp_resp !=. & asp_ap1 !=. & asp_ap5 !=. 
	replace asp_vitsigns = 1 if (asp_puls == 1 | asp_hr == 1 ) & asp_resp == 1 & asp_ap1 == 1 & asp_ap5 == 1
 
//BASIC: 	if APGAR score at 5 minutes ≤7 [ Oxygen (mask or head box or cone or hood or nasal cannula or mechanic ventilation or oxygen tank) or Ambu (Positive pressure ventilation) + Transfer to Complete (unless neonate deceased)]
//COMPLETE: if APGAR score at 5 minutes ≤7 [ Oxygen (mask or head box or cone or hood or nasal cannula or mechanic ventilation or oxygen tank) or Ambu (Positive pressure ventilation) or endotraqueal intubation or chest compressions + Oxygen saturation ]
 
// APGAR at 5 minutes <= 7?
	gen asp_apgar5_lte7 = 0 if asp_num_ap5 !=.
	replace asp_apgar5_lte7 = 1 if asp_num_ap5 <= 7 & asp_num_ap5 !=.
	
// OXYGEN ADMINISTRATION (if APGAR score <=7 at 5 minutes) 
	gen asp_oxy = 0 if asp_apgar5_lte7 == 1 & asp_ventmec !=. & asp_bolsa!=. & asp_100 !=. & asp_maskoxy !=. & asp_mask !=. & asp_maskres !=. & asp_headbox !=. & asp_cone !=. & asp_helmet !=. & asp_campcef !=. & asp_cyl !=. & asp_cylcap !=. & asp_cpap !=. & asp_tank !=. & asp_nasal !=. & asp_cath !=. & asp_canula !=. & asp_vent !=.
	replace asp_oxy = 1 if asp_apgar5_lte7 == 1 & (asp_ventmec == 1 | asp_bolsa == 1 | asp_100 == 1 | asp_maskoxy == 1 | asp_mask == 1 | asp_maskres == 1 | asp_headbox == 1 | asp_cone == 1 | asp_helmet == 1 | asp_campcef == 1 | asp_cyl == 1 | asp_cylcap == 1 | asp_cpap == 1 | asp_tank == 1 | asp_nasal == 1 | asp_cath == 1 | asp_canula == 1 | asp_vent == 1 )
	
// AMBU (if APGAR score <=7 at 5 minutes)
	//BASIC: Ambu (Positive pressure ventilation)
	gen asp_ambuvent = 0 if asp_apgar5_lte7 == 1 & asp_ambu !=. & asp_posvent !=. & cone == "basic"
	replace asp_ambuvent = 1 if asp_apgar5_lte7 == 1 & (asp_ambu == 1 | asp_posvent == 1 ) & cone == "basic"
	//COMPLETE: Ambu (Positive pressure ventilation) or endotraqueal intubation or chest compressions
	replace asp_ambuvent = 0 if asp_apgar5_lte7 == 1 & asp_ambu !=. & asp_intub !=. & asp_compression !=. & asp_posvent !=. & cone == "comp"
	replace asp_ambuvent =1 if asp_apgar5_lte7 == 1 & (asp_ambu == 1 | asp_intub == 1 | asp_compression == 1 | asp_posvent == 1 ) & cone == "comp"
 
// BASIC: referred unless child died 
	gen asp_ref = 0 if asp_apgar5_lte7 == 1 & neo_disposition !=. & neo_disposition != 1 & cone == "basic" 
	replace asp_ref = 1 if asp_apgar5_lte7 == 1 & neo_disposition == 3 & neo_ref_typeto == 3 & cone == "basic"
	
//COMPLETE: OXYGEN SATURATION 
	gen asp_lab = 0 if asp_apgar5_lte7 == 1 & lab_oxy !=. & cone == "comp"
	replace asp_lab = 1 if asp_apgar5_lte7 == 1 & lab_oxy == 1 & cone == "comp"


// FINAL CALCULATION
	gen asp_norm = .

	replace asp_norm = 0 if asp_vitsigns !=. & cone == "basic"
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_oxy !=0 & asp_ambuvent !=0 & asp_ref !=0 & cone == "basic"

	replace asp_norm = 0 if asp_vitsigns !=. & cone == "comp"
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_oxy !=0 & asp_ambuvent !=0 & asp_lab !=0 & cone == "comp"

	// Only applies if birth was in the hospital
	replace asp_norm = . if neo_birth_where !=1 & neo_birth_where !=.
}		

{ // SEPSIS 4070 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in temp puls hr resp abd {
		rename neo_sep_check_reg_`var' sep_`var'
	}

	foreach var in oxy cbc plq leuc abs hgb hemat proc band {
		rename neo_sep_lab_reg_`var' sep_`var'
	}
	
// CHECKS
	//BASIC: Temperature + Heart rate + Respiratory rate
	gen sep_vitsigns = 0 if sep_temp !=. & sep_hr !=. & sep_puls !=. & sep_resp !=. & cone == "basic"
	replace sep_vitsigns = 1 if sep_temp == 1 & (sep_hr == 1 | sep_puls == 1 ) & sep_resp == 1 & cone == "basic"
	//COMPLETE: Temperature + Heart rate + Respiratory rate + Abdominal exam 
	replace sep_vitsigns = 0 if sep_temp !=. & sep_hr !=. & sep_puls !=. & sep_resp !=. & sep_abd !=. & cone == "comp"
	replace sep_vitsigns = 1 if sep_temp == 1 & (sep_hr == 1 | sep_puls == 1 ) & sep_resp == 1 & sep_abd == 1 & cone == "comp"
	
// LAB - COMPLETE: Oxygen saturation + Complete blood count (platelets + leukocytes + neutrophil count + hemoglobin + hematocrit) + Protein C Reactive 
	gen sep_lab = 0 if sep_oxy !=. & sep_proc !=. & sep_cbc !=. & sep_plq !=. & sep_leuc !=. & sep_abs !=. & sep_band !=. & sep_hgb !=. & sep_hemat !=. & cone == "comp"
	replace sep_lab = 1 if sep_oxy == 1 & sep_proc == 1 & (sep_cbc == 1 | (sep_plq == 1 & sep_leuc == 1 & (sep_abs == 1 | sep_band == 1 ) & sep_hgb == 1 & sep_hemat == 1 )) & cone == "comp"

// MEDS: Antibiotics double therapy
	gen sep_med = 0 if double_anti !=. & mrr_neo_comp_sep == 1
	replace sep_med = 1 if double_anti == 1 & mrr_neo_comp_sep == 1
	
// BASIC: REFERRED TO COMPLETE (if hemodynamic failture or shock) 
	gen sep_ref = 0 if (neo_sep_other_comp_hemo == 1 | neo_sep_other_comp_shock == 1 ) & neo_disposition !=. & neo_disposition != 1 & cone == "basic"
	replace sep_ref = 1 if (neo_sep_other_comp_hemo == 1 | neo_sep_other_comp_shock == 1 ) & neo_disposition == 3 & cone == "basic" 	


// FINAL CALCULATION
	gen sep_norm = .

	replace sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & cone == "basic"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med == 1 & sep_ref != 0 & cone == "basic"

	replace sep_norm = 0 if sep_vitsigns !=. & sep_lab !=. & sep_med !=. & cone == "comp"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_lab == 1 & sep_med == 1 & cone == "comp"
}	

{ // PREMATURITY 4070 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in wt hr puls resp head skin {
		rename neo_pre_check_reg_`var' pre_`var'
	}

	foreach var in gly oxy {
		rename neo_pre_lab_reg_`var' pre_`var'
	}
		
	foreach var in inc wrap warmsheet lamp warmer kang plastic bacin servo servocuna {
		rename neo_pre_proc_heat_`var' pre_`var'
	}

// GEST AGE CALCULATION (Capurro or Ballard)
	gen pre_calc = 0 if neo_pre_gest_method_1 !=. & neo_pre_gest_method_2 !=. & neo_pre_gest_method_3 !=. & neo_pre_gest_method_4 !=. & neo_pre_gest_method_5 !=.
	replace pre_calc = 1 if neo_pre_gest_method_3 == 1 | neo_pre_gest_method_5 == 1 
	
// CLASSIFICATION (if born in the facility)
	gen pre_class = 0 if neo_pre_classification !=.  
	replace pre_class = 1 if neo_pre_classification == 1 |  neo_pre_classification == 2 | neo_pre_classification == 3
	replace pre_class = . if neo_birth_where !=1 & neo_birth_where !=.
	
// CHECKS: Weight + Heart rate + Respiratory rate + Glycemia + Head circumference + Skin color
	gen pre_vitsigns = 0 if pre_wt !=. & pre_hr !=. & pre_puls !=. & pre_resp !=. & pre_head !=. & pre_skin !=.
	replace pre_vitsigns = 1 if pre_wt == 1 & (pre_hr == 1 | pre_puls == 1 ) & pre_resp == 1 & pre_head == 1 & pre_skin == 1
	
// LAB
	//BASIC: Glycemia
	gen pre_lab = 0 if pre_gly !=. & cone == "basic"
	replace pre_lab = 1 if pre_gly == 1 & cone == "basic"
	//COMPLETE:  Glycemia + Oxygen saturation
	replace pre_lab = 0 if pre_gly !=. & pre_oxy !=. & cone == "comp"
	replace pre_lab = 1 if pre_oxy == 1 & pre_gly == 1 & cone == "comp"

// HEAT APPLICATION
	tostring neo_pre_proc_htoth_spec, replace
	replace neo_pre_proc_htoth_spec = "" if neo_pre_proc_htoth_spec == "."
	gen pre_heat = 0 if pre_inc !=. & pre_wrap !=. & pre_warmsheet !=. & pre_lamp !=. & pre_warmer !=. & pre_kang !=. & pre_plastic !=. & pre_bacin !=. & pre_servo !=. & pre_servocuna !=.
	replace pre_heat = 1 if pre_inc == 1 | pre_wrap == 1 | pre_warmsheet == 1 | pre_lamp == 1 | pre_warmer == 1 | pre_kang == 1 | pre_plastic == 1 | pre_bacin == 1 | pre_servo == 1 | pre_servocuna == 1 | neo_pre_proc_htoth_spec !=""

// BREASTFEEDING or GLUCOSE
	gen pre_food = 0 if neo_pre_babyfood_bf !=. & neo_pre_babyfood_glucoseiv !=. & neo_pre_babyfood_oral !=. 
	replace pre_food = 1 if neo_pre_babyfood_bf == 1 | neo_pre_babyfood_glucoseiv == 1 | neo_pre_babyfood_oral == 1 

// BASIC: if complications are present (respiratory: pneumonia) or metabolic(hypoglycemia if glucose=< 40mg/dl } or <=34 weeks of gestation: Transfer to Complete
	tab neo_pre_lab_num_gly 
	destring neo_pre_lab_num_gly, replace	
	destring neo_gestages_spec, replace	
	gen pre_ref = 0 if neo_disposition !=. & neo_disposition != 1 & cone == "basic" & (neo_pre_other_comp_pneu == 1 | (neo_pre_lab_num_gly !=. & neo_pre_lab_num_gly <=40 ) | (neo_gestages_spec !=. & neo_gestages_spec <=34 ))
	replace pre_ref = 1 if neo_disposition == 3 & cone == "basic" & (neo_pre_other_comp_pneu == 1  | (neo_pre_lab_num_gly !=. & neo_pre_lab_num_gly <=40 ) | (neo_gestages_spec !=. & neo_gestages_spec <=34 ))

 // APPROPRIATE TREATMENT - COMPLETE: (if pneumonia: antibiotics) or (if hypoglycemia if glucose=< 40mg/dl: glucose IV) 
	gen pre_treat_pneu = 0 if neo_pre_other_comp_pneu == 1 & anti !=. & cone == "comp"
	replace pre_treat_pneu = 1 if neo_pre_other_comp_pneu == 1 & anti == 1 & cone == "comp"
	
	gen pre_treat_hypo = 0 if neo_pre_lab_num_gly <=40 & neo_pre_lab_num_gly !=. & neo_pre_babyfood_glucoseiv !=. & cone == "comp"
	replace pre_treat_hypo = 1 if neo_pre_lab_num_gly <=40 & neo_pre_lab_num_gly !=. & neo_pre_babyfood_glucoseiv == 1 & cone == "comp"

	//Overall
	gen pre_treat = .	
	replace pre_treat = 1 if pre_treat_pneu !=. | pre_treat_hypo !=.
	replace pre_treat = 0 if pre_treat_pneu == 0 | pre_treat_hypo == 0 	
	

//FINAL CALCULATION
	gen pre_norm =.

	replace pre_norm = 0 if pre_calc !=. & pre_vitsigns !=. & pre_lab !=. & pre_heat !=. & pre_food !=. & cone == "basic"
	replace pre_norm = 1 if pre_calc == 1 & pre_class != 0 & pre_vitsigns == 1 & pre_lab == 1 & pre_heat == 1 & pre_food == 1 & pre_ref != 0 & cone == "basic"

	replace pre_norm = 0 if pre_calc !=. & pre_vitsigns !=. & pre_lab !=. & pre_heat !=. & pre_food !=. & cone == "comp"
	replace pre_norm = 1 if pre_calc == 1 & pre_class != 0 & pre_vitsigns == 1 & pre_lab == 1 & pre_heat == 1 & pre_food == 1 & pre_treat != 0 & cone == "comp"

	// Only applies if gestational age < 37 weeks
	destring neo_gestages_spec, replace
	replace pre_norm = . if neo_gestages_spec !=. & neo_gestages_spec >= 37
}	

{ // LOW BIRTH WEIGHT 4070 ~~~~~~~~~~~~~~~~~~~~~~~~~~
// Shorten varnames here
	foreach var in wt hr puls resp head skin ht {
		rename neo_lbw_check_reg_`var' lbw_`var'
	}

	foreach var in gly oxy {
		rename neo_lbw_lab_reg_`var' lbw_`var'
	}
		
	foreach var in inc wrap warmsheet lamp warmer kang plastic bacin servo servocuna {
		rename neo_lbw_proc_heat_`var' lbw_`var'
	}
	
// GEST AGE CALCULATION (Capurro or Ballard)
	gen lbw_calc = 0 if neo_lbw_gest_method_1 !=. & neo_lbw_gest_method_2 !=. & neo_lbw_gest_method_3 !=. & neo_lbw_gest_method_4 !=. & neo_lbw_gest_method_5 !=.
	replace lbw_calc = 1 if (neo_lbw_gest_method_3 == 1 | neo_lbw_gest_method_5 == 1 ) 
	
// CLASSIFICATION (if born in the facility)
	gen lbw_class = 0 if neo_lbw_classification !=.  
	replace lbw_class = 1 if neo_lbw_classification == 1 |  neo_lbw_classification == 2 | neo_lbw_classification == 3
	replace lbw_class = . if neo_birth_where !=1 & neo_birth_where !=.
	
// CHECKS
	gen lbw_vitsigns = 0 if lbw_wt !=. & lbw_hr !=. & lbw_puls !=. & lbw_resp !=. & lbw_head !=. & lbw_skin !=. & lbw_ht !=.
	replace lbw_vitsigns = 1 if lbw_wt == 1 & (lbw_hr == 1 | lbw_puls == 1 ) & lbw_resp == 1 & lbw_head == 1 & lbw_skin == 1 & lbw_ht == 1 

// HEAT
	tostring neo_lbw_proc_htoth_spec, replace
	replace neo_lbw_proc_htoth_spec = "" if neo_lbw_proc_htoth_spec == "."
	gen lbw_heat = 0 if lbw_inc !=. & lbw_wrap !=. & lbw_warmsheet !=. & lbw_lamp !=. & lbw_warmer !=. & lbw_kang !=. & lbw_plastic !=. & lbw_bacin !=. & lbw_servo !=. & lbw_servocuna !=.
	replace lbw_heat = 1 if lbw_inc == 1 | lbw_wrap == 1 | lbw_warmsheet == 1 | lbw_lamp == 1 | lbw_warmer == 1 | lbw_kang == 1 | lbw_plastic == 1 | lbw_bacin == 1 | lbw_servo == 1 | lbw_servocuna == 1 | neo_lbw_proc_htoth_spec !=""

// BREASTFEEDING or GLUCOSE
	gen lbw_food = 0 if neo_lbw_babyfood_bf !=. & neo_lbw_babyfood_glucoseiv !=. & neo_lbw_babyfood_oral !=. 
	replace lbw_food = 1 if neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_glucoseiv == 1 | neo_lbw_babyfood_oral == 1 

// BASIC: if complications are present respiratory(pneumonia) or metabolic(hypoglycemia if glucose=< 40mg/dl)} or weight less than 1500g: Transfer to Complete
	tab neo_lbw_lab_num_gly 
	destring neo_lbw_lab_num_gly, replace

	gen lbw_ref = 0 if neo_disposition !=. & neo_disposition != 1 & cone == "basic" & (neo_lbw_other_comp_pneu == 1 | (neo_lbw_lab_num_gly !=. & neo_lbw_lab_num_gly <=40 ) | (neo_birth_weight_grams !=. & neo_birth_weight_grams <1500 ))
	replace lbw_ref = 1 if neo_disposition == 3 & cone == "basic" & (neo_lbw_other_comp_pneu == 1 | (neo_lbw_lab_num_gly !=. & neo_lbw_lab_num_gly <=40 ) | (neo_birth_weight_grams !=. & neo_birth_weight_grams <1500 ))

 // APPROPRIATE TREATMENT - COMPLETE: (if pneumonia: antibiotics) or (if hypoglycemia if glucose=< 40mg/dl: glucose IV) 
	gen lbw_treat_pneu = 0 if neo_lbw_other_comp_pneu == 1 & anti !=. & cone == "comp"
	replace lbw_treat_pneu = 1 if neo_lbw_other_comp_pneu == 1 & anti == 1 & cone == "comp"
	
	gen lbw_treat_hypo = 0 if neo_lbw_lab_num_gly <40 & neo_lbw_lab_num_gly !=. & neo_lbw_babyfood_glucoseiv !=. & cone == "comp"
	replace lbw_treat_hypo = 1 if neo_lbw_lab_num_gly <40 & neo_lbw_lab_num_gly !=. & neo_lbw_babyfood_glucoseiv == 1 & cone == "comp"

	//Overall
	gen lbw_treat = .	
	replace lbw_treat = 1 if lbw_treat_pneu !=. | lbw_treat_hypo !=.
	replace lbw_treat = 0 if lbw_treat_pneu == 0 | lbw_treat_hypo == 0	
	
	
//FINAL CALCULATION
	gen lbw_norm = 0 if lbw_calc !=. & lbw_vitsigns !=. & lbw_heat !=. & lbw_food !=. & cone == "basic"
	replace lbw_norm = 1 if lbw_calc == 1 & lbw_class != 0 & lbw_vitsigns == 1 & lbw_heat == 1 & lbw_food == 1 & lbw_ref != 0 & cone == "basic"

	replace lbw_norm = 0 if lbw_calc !=. & lbw_vitsigns !=. & lbw_heat !=. & lbw_food !=. & cone == "comp"
	replace lbw_norm = 1 if lbw_calc == 1 & lbw_class != 0 & lbw_vitsigns == 1 & lbw_heat == 1 & lbw_food == 1 & lbw_treat != 0 & cone == "comp"

	//Only applies if Weight < 2500g
	destring neo_birth_weight_grams, replace
	replace lbw_norm = . if neo_birth_weight_grams !=. & neo_birth_weight_grams >2500 
}	


// INDICATOR CALCULATION ************************************************************
	gen I4070 = 0 if sep_norm !=. | lbw_norm !=. | pre_norm !=. | asp_norm !=.
	replace I4070 = 1 if sep_norm !=0 & lbw_norm !=0 & pre_norm !=0 & asp_norm !=0 & (sep_norm !=. | lbw_norm !=. | pre_norm !=. | asp_norm !=.)	

	// Indicator value
	prop I4070 if time == "pre-evaluation"
	prop I4070 if time == "evaluation" 
