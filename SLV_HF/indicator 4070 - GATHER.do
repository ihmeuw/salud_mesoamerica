************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 4070
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

 // NEONATAL COMPLICATIONS RECORDS (4070)
	use "IHME_SMI_BLZ_HFS_2022_NEOCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4070: Neonatal complications (sepsis, asphyxia, prematurity, and low birth weight) managed according to the norm in the last two years
***************************************************************************************
	
// Denominator: Total number of neonatal complications records in our sample   
	
	// Must have a complication
	drop if mrr_neo_comp_no == 1
	tab mrr_neo_comp, m
		
	//Basic and Complete
	keep if cone == 2 | cone == 3
	rename cone cone_numeric
	gen cone = "basic" if cone_numeric == 2
	replace cone = "comp" if cone_numeric == 3

{ //Date restrictions
	gen record_date = date(neo_adm_dates_date, "YMD")
	cap gen time =""
	
	//*Evaluation* period date range (admission date) (7/1/2020 - 9/26/2021)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (admission date) (1/1/2019 - 9/26/2019)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Adjustments
	destring neo_pre_check_num_wt, replace
	replace neo_pre_check_num_wt =. if neo_pre_check_num_wt == -1
	destring neo_lbw_check_num_wt, replace
	replace neo_lbw_check_num_wt =. if neo_lbw_check_num_wt == -1

//Variable renaming
	foreach var in amp amik sulb pip clind gen metron peni penicry taz feno lev lido pento tio difenil diaze {
		rename neo_lbw_med_adm_`var' lbw_`var'
	}
		
	foreach var in amp amik sulb pip clind gen metron peni penicry taz ors feno lev lido pento tio difenil diaze {
		rename neo_pre_med_adm_`var' pre_`var'
	}

	rename neo_asp_med_adm_gen asp_genta
	foreach var in amp amik sulb pip {
		rename neo_asp_med_adm_`var' asp_`var'
	}		
		
	foreach var in amp amik sulb pip clind gen metron peni penicry taz {
		rename neo_sep_med_adm_`var' sep_`var'
	}
		
	foreach comp in asp lbw pre sep {
		foreach type in oan ome1 ome2 ome3 {
			cap qui replace neo_`comp'_med_`type'_name = lower(neo_`comp'_med_`type'_name)
		}
	}

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
		replace `comp'_cefotax = 1 if regex(neo_`comp'_med_oan_name, "cefot") | regex(neo_`comp'_med_ome1_name, "cefot") | regex(neo_`comp'_med_ome2_name, "cefot") | regex(neo_`comp'_med_oan_name, "cetot") | regex(neo_`comp'_med_ome1_name, "cetot") | regex(neo_`comp'_med_ome2_name, "cetot")
		
		//cefuroxime
		gen `comp'_cefuro = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_cefuro = 1 if regex(neo_`comp'_med_oan_name, "cefur") | regex(neo_`comp'_med_ome1_name, "cefur") | regex(neo_`comp'_med_ome2_name, "cefur")
		
		//ceftriaxone
		gen `comp'_ceftr = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_ceftr = 1 if regex(neo_`comp'_med_oan_name, "ceftr") | regex(neo_`comp'_med_ome1_name, "ceftr") | regex(neo_`comp'_med_ome2_name, "ceftr")
		
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
		
		//oxacilin
		gen `comp'_oxacil = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_oxacil = 1 if regex(neo_`comp'_med_oan_name, "oxacilina") | regex(neo_`comp'_med_ome1_name, "oxacilina") | regex(neo_`comp'_med_ome2_name, "oxacilina")
	}
	//metronidazole
	gen asp_metron = 1 if regex(neo_asp_med_oan_name, "flagyl")

// For each one, check whether it was administered once
	foreach var in amoxi cefotax cefuro cloxa vanco ceftaz chloram oxacil ceftr amp amik sulb pip clind gen metron peni penicry taz {
		cap gen lbw_`var' =.
		cap gen pre_`var' =.
		cap gen sep_`var' =.
		cap gen asp_`var' =.
		
		gen allcomps_`var' = 0 if lbw_`var' !=. | pre_`var' !=. | sep_`var' !=. | asp_`var' !=.
		replace allcomps_`var' = 1 if lbw_`var' == 1 | pre_`var' == 1 | sep_`var' == 1 | asp_`var' == 1
	}	
	
// For double/triple therapy, check whether two or more antibiotics were administered
	// Number administered
	egen num_antibiotics = anycount(allcomps_amoxi allcomps_cefotax allcomps_cefuro allcomps_cloxa allcomps_vanco allcomps_ceftaz allcomps_chloram allcomps_oxacil allcomps_ceftr allcomps_amp allcomps_amik allcomps_sulb allcomps_pip allcomps_clind allcomps_gen allcomps_metron allcomps_peni allcomps_penicry allcomps_taz), value(1) 
	
	// One antibiotic administered?
	gen anti = 0 if num_antibiotics !=.
	replace anti = 1 if num_antibiotics >= 1 & num_antibiotics !=.
	
	// Two or more?
	gen double_anti = 0 if num_antibiotics !=.
	replace double_anti = 1 if num_antibiotics > 1 & num_antibiotics !=.

	// Check for any more
	 tab1 neo_*_med_*_name if anti == 0
 
// Anti-convulsive
	gen anticonv = 0 if (pre_feno !=. & pre_lev !=. & pre_lido !=. & pre_pento !=. & pre_tio !=. & pre_difenil !=. & pre_diaze !=. & mrr_neo_comp_pre == 1 ) | (mrr_neo_comp_lbw == 1 & lbw_feno !=. & lbw_lev !=. & lbw_lido !=. & lbw_pento !=. & lbw_tio !=. & lbw_difenil !=. & lbw_diaze !=. )
	replace anticonv = 1 if pre_feno == 1 |  pre_lev == 1 |  pre_lido == 1 |  pre_pento == 1 |  pre_tio == 1 |  pre_difenil == 1 |  pre_diaze == 1 |  lbw_feno == 1 |  lbw_lev == 1 |  lbw_lido == 1 |  lbw_pento == 1 |  lbw_tio == 1 |  lbw_difenil == 1 |  lbw_diaze == 1

	// Check for any more
	tab1 neo_*_med_*_name if anticonv == 0
 

{ // ASPHYXIA 4070 
/* [sólo si el nacimiento ocurrió en el hospital]: Calor (cobijas o calor radiante o incubadora o mamá canguro u otros métodos) + frecuencia cardiaca + frecuencia respiratoria + APGAR a 1 minuto + APGAR a 5 minutos + Si el APGAR a 5 minutos ≤3: [ventilación a presión positiva (AMBU con mascarilla o intubación endotraqueal o ventilación mecánica) + Aplicación de oxígeno posterior a la reanimación (ventilación a presión positiva o mascarilla o campana cefálica o casco cefálico) + saturación de oxígeno + soluciones parenterales]  */

// Shorten varnames here
	foreach var in puls hr resp ap1 ap5  {
		rename neo_asp_check_reg_`var' asp_`var'
	}
	
	foreach var in oxy gly {
		rename neo_asp_lab_reg_`var' asp_`var'
	}

	foreach var in ambu posvent helmet ventmec 100 maskoxy mask maskres camp cyl cylcap cpap big nasal cath canula vent campcef {
		rename neo_asp_proc_oxy_`var' asp_`var'
	}

	foreach var in inc wrap lamp kang plastic bacin servo servocuna {
		rename neo_asp_proc_heat_`var' asp_`var'
	}
	
	foreach var in sec intub massage {
		rename neo_asp_proc_oth_`var' asp_`var'
	}	
	
// Create variable for severe asphyxia (Apgar at 5 minutes <= 3)
	tab neo_asp_check_num_ap5
	destring neo_asp_check_num_ap5, replace
	
	gen asp_severe = 0 if asp_ap5 !=.
	replace asp_severe = 1 if neo_asp_check_num_ap5 <= 3 & neo_asp_check_num_ap5 !=.	

// CHECKS: frecuencia cardiaca + frecuencia respiratoria + APGAR a 1 minuto + APGAR a 5 minutos
	gen asp_vitsigns = 0 if asp_hr !=. & asp_puls !=. & asp_resp !=. & asp_ap1 !=. & asp_ap5 !=. 
	replace asp_vitsigns = 1 if (asp_hr == 1 | asp_puls == 1 ) & asp_resp == 1 & asp_ap1 == 1 & asp_ap5 == 1 
	
// LAB: saturación de oxígeno [si el APGAR a 5 minutos ≤3]
	gen asp_lab = 0 if asp_oxy !=. & asp_severe == 1
	replace asp_lab = 1 if asp_oxy == 1 & asp_severe == 1

// HEAT APPLICATION: cobijas o calor radiante o incubadora o mamá canguro u otros métodos
	gen asp_heatapp = 0 if asp_inc !=. & asp_wrap !=. & asp_lamp !=. & asp_kang !=.  & asp_plastic !=. & asp_bacin !=. & asp_servo !=. & asp_servocuna !=.
	replace asp_heatapp = 1 if asp_inc == 1 | asp_wrap == 1 | asp_lamp == 1 | asp_kang == 1 | asp_plastic == 1 | asp_bacin == 1 | asp_servo == 1 | asp_servocuna == 1

// OXYGEN APPLICATION: ventilación a presión positiva o mascarilla o campana cefálica o casco cefálico [si el APGAR a 5 minutos ≤3]
	gen asp_oxyapp = 0 if asp_posvent !=. & asp_ventmec !=. & asp_helmet !=. & asp_100 !=. & asp_maskoxy !=. & asp_mask !=. & asp_maskres !=. & asp_camp !=. & asp_campcef !=. & asp_cyl !=. & asp_cylcap !=. & asp_cpap !=. & asp_big !=. & asp_nasal !=. & asp_cath !=. & asp_canula !=. & asp_vent !=. & asp_severe == 1
	replace asp_oxyapp = 1 if (asp_posvent == 1 | asp_ventmec == 1 | asp_helmet == 1 | asp_100 == 1 |  asp_maskoxy == 1 | asp_mask == 1 | asp_maskres == 1 | asp_camp == 1 | asp_campcef == 1 | asp_cyl == 1 | asp_cylcap == 1 | asp_cpap == 1 | asp_big == 1 | asp_nasal == 1 | asp_cath == 1 | asp_canula == 1 | asp_vent == 1 ) & asp_severe == 1

// OTHER PROCEDURES: AMBU con mascarilla o intubación endotraqueal o ventilación mecánica [si el APGAR a 5 minutos ≤3]
	gen asp_othapp = 0 if asp_posvent !=. & asp_ambu !=. & asp_massage !=. & asp_intub !=. & asp_severe == 1
	replace asp_othapp = 1 if (asp_posvent == 1 | asp_ambu == 1 | asp_massage == 1 | asp_intub == 1 ) & asp_severe == 1
	
	
// FINAL CALCULATION
	gen asp_norm =.	
	replace asp_norm = 0 if asp_vitsigns !=. & asp_heatapp !=. & asp_severe != 1
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_heatapp == 1 & asp_severe != 1

	replace asp_norm = 0 if asp_vitsigns !=. & asp_lab !=. & asp_heatapp !=. & asp_oxyapp !=. & asp_othapp !=. & asp_severe == 1
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_lab == 1 & asp_heatapp == 1 & asp_oxyapp == 1 & asp_othapp == 1 & asp_severe == 1

	// Only in-facility [sólo si el nacimiento ocurrió en el hospital]
	replace asp_norm =. if neo_birth_where != 1
}

{ // SEPSIS 4070
/* temperatura + pulso + frecuencia cardiaca + frecuencia respiratoria + hemograma completo + relación banda neutrófilos + Proteina C-Reactiva + Hemocultivo + saturación de oxígeno + biometría hemática (plaquetas + conteo de leucocitos + hemoglobina + hematocrito) + tratamiento con antibióticos (esquema*) 
*El esquema de antibiótico es: [ampicilina + aminoglucósido (gentamicina o amikacina)] o [ampicilina + cefotaxima] o (antibiótico terapia con espectro para anaerobias y gram negativo) */

// Shorten varnames here
	foreach var in temp hr resp puls abd  {
		rename neo_sep_check_reg_`var' sep_`var'
	}

	rename neo_sep_lab_reg_cbc sep_bio
	foreach var in oxy plq leuc hgb hemat bl proc abs band {
		rename neo_sep_lab_reg_`var' sep_`var'
	}
	
// CHECKS: temperatura + pulso + frecuencia cardiaca + frecuencia respiratoria
	gen sep_vitsigns = 0 if sep_resp !=. & sep_temp !=. & sep_puls !=. & sep_hr !=.
	replace sep_vitsigns = 1 if sep_resp == 1 & sep_temp == 1 & (sep_puls == 1 | sep_hr == 1 ) 
	
// LAB: biometría hemática (plaquetas + conteo de leucocitos + hemoglobina + hematocrito) + relación banda neutrófilos + Proteina C-Reactiva + Hemocultivo + saturación de oxígeno
	gen sep_lab = 0 if sep_oxy !=. & sep_bio !=. & sep_plq !=. & sep_leuc !=. & sep_hgb !=. & sep_hemat !=. & sep_bl !=. & sep_proc !=. & sep_band !=. & sep_abs !=. 
	replace sep_lab = 1 if sep_oxy == 1 & ( sep_bio == 1 | (sep_plq == 1 & sep_leuc == 1 & sep_hgb == 1 & sep_hemat == 1 )) & sep_bl == 1 & sep_proc == 1 & ( sep_abs == 1 | sep_band == 1 ) 

// MEDS: antibiotics
	gen sep_med = 0 if double_anti !=. & mrr_neo_comp_sep == 1
	replace sep_med = 1 if double_anti == 1 & mrr_neo_comp_sep == 1


// FINAL CALCULATION
	gen sep_norm = 0 if sep_vitsigns !=. & sep_lab !=. & sep_med !=.
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_lab == 1 & sep_med == 1
}	

{ // PREMATURITY 4070 [Edad gestacional < 37 semanas]
/* edad gestacional (Capurro o Ballard) + [si el bebé nació en la unidad: clasificación del recién nacido según edad gestacional (pequeño, grande o adecuado) + APGAR] + peso + frecuencia cardiaca + frecuencia respiratoria + glicemia (tira reactiva o examen) + saturación de oxígeno + circunferencia cefálica + calor (cobijas o calor radiante o incubadora o mamá canguro u otros métodos) + Si menor de 34 semanas: dexametasona (excepto si llega en expulsivo o se aplicaron esteroides para maduración pulmonar previamente) + alimentación temprana precoz (lactancia materna) o líquidos glucosados IV o sucedáneos + (si neumonía: antibióticos) o (si diarrea: solución IV + antibióticos) o (si convulsiones: anticonvulsivo) o (si hipoglucemia: lactancia materna o sucedáneo o glucosa IV)  */

// Shorten varnames here
	foreach var in wt hr puls resp sil dow head ap1 ap5 skin {
		rename neo_pre_check_reg_`var' pre_`var'
	}

	foreach var in oxy gly {
		rename neo_pre_lab_reg_`var' pre_`var'
	}

	foreach var in ambu ventmec 100 maskoxy mask maskres camp helmet cyl cylcap cpap big nasal cath canula vent {
		rename neo_pre_proc_oxy_`var' pre_`var'
	}		
		
	foreach var in inc wrap lamp kang plastic bacin servo servocuna {
		rename neo_pre_proc_heat_`var' pre_`var'
	}
	
// GESTATIONAL AGE CALCULATION (Capurro/Ballard) 
	gen pre_calc = 0 if neo_pre_gest_method_1 != . & neo_pre_gest_method_2 != . & neo_pre_gest_method_3 != . & neo_pre_gest_method_4 != . & neo_pre_gest_method_5 != . & neo_pre_gest_method_995 != .
	replace pre_calc = 1 if neo_pre_gest_method_3 == 1 | neo_pre_gest_method_5 == 1 

// CLASSIFICATION [si el bebé nació en la unidad]
	gen pre_class = 0 if neo_pre_classification !=. 
	replace pre_class = 1 if neo_pre_classification == 1 | neo_pre_classification == 2 | neo_pre_classification == 3 
	replace pre_class = . if neo_birth_where != 1
	
// CHECKS: peso + frecuencia cardiaca + frecuencia respiratoria + circunferencia cefálica
	gen pre_vitsigns = 0 if pre_hr !=. & pre_puls !=. & pre_resp !=. & pre_wt !=. & pre_head !=.  
	replace pre_vitsigns = 1 if (pre_hr == 1 | pre_puls == 1 ) & pre_resp == 1 & pre_wt == 1  & pre_head == 1 
	
// APGAR [si el bebé nació en la unidad]
	gen pre_apgar = 0 if pre_ap1 !=. & pre_ap5 !=.
	replace pre_apgar = 1 if ( pre_ap1 == 1 | pre_ap5 == 1 )
	replace pre_apgar =. if neo_birth_where != 1
	
// LAB: glicemia (tira reactiva o examen) +  saturación de oxígeno
	gen pre_lab = 0 if pre_gly !=. & pre_oxy !=.
	replace pre_lab = 1 if pre_gly == 1 & pre_oxy == 1
	
// HEAT APPLICATION: cobijas o calor radiante o incubadora o mamá canguro u otros métodos
	gen pre_heatapp = 0 if pre_wrap !=. &  pre_lamp !=. & pre_inc !=. & pre_kang !=. & pre_plastic !=. & pre_bacin !=. & pre_servo !=. & pre_servocuna !=.
	replace pre_heatapp = 1 if pre_wrap == 1 | pre_lamp == 1 | pre_inc == 1 | pre_kang == 1 | pre_plastic == 1 | pre_bacin == 1 | pre_servo == 1 | pre_servocuna == 1 | neo_pre_proc_htoth_spec !=""

// GLUCOSE: alimentación temprana precoz (lactancia materna) o líquidos glucosados IV o sucedáneos 
	gen pre_glucose = 0 if neo_pre_babyfood_bf !=. & neo_pre_babyfood_glucoseiv !=. & neo_pre_babyfood_oral !=.
	replace pre_glucose = 1 if ( neo_pre_babyfood_bf == 1 | neo_pre_babyfood_glucoseiv == 1 | neo_pre_babyfood_oral == 1 )
 
// APPROPRIATE TREATMENT OF ASSOCIATED COMPLICATIONS
	// Pneumonia: antibióticos 
	gen pre_pneutreat = 0 if neo_pre_other_comp_pneu == 1 & anti !=.
	replace pre_pneutreat = 1 if neo_pre_other_comp_pneu == 1 & anti == 1
	
	// Diarrhea: solución IV + antibióticos
	gen pre_diatreat = 0 if neo_pre_other_comp_dia == 1 & neo_pre_babyfood_iv !=. & neo_pre_babyfood_oral !=. & pre_ors !=.
	replace pre_diatreat = 1 if neo_pre_other_comp_dia == 1 & ( neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | pre_ors == 1 ) 
	
	// Seizures: anticonvulsivo
	gen pre_convtreat = 0 if neo_pre_other_comp_conv == 1 & anticonv !=.
	replace pre_convtreat = 1 if neo_pre_other_comp_conv == 1 & anticonv == 1
	
	// Hypoglycemia: lactancia materna o sucedáneo o glucosa IV
	gen pre_hypotreat = 0 if neo_pre_other_comp_hipo == 1 &  neo_pre_babyfood_iv !=. & neo_pre_babyfood_oral !=. & neo_pre_babyfood_bf !=.
	replace pre_hypotreat = 1 if neo_pre_other_comp_hipo == 1 & ( neo_pre_babyfood_bf == 1 | neo_pre_babyfood_glucoseiv == 1 | neo_pre_babyfood_oral == 1 ) 	

	//Treatment overall
	gen pre_treatment = 1 if pre_pneutreat !=. | pre_diatreat !=. | pre_convtreat !=. | pre_hypotreat !=.
	replace pre_treatment = 0 if pre_pneutreat == 0 | pre_diatreat == 0 | pre_convtreat == 0 | pre_hypotreat == 0


// FINAL CALCULATION
	gen pre_norm = 0 if pre_vitsigns !=. & pre_calc !=. & pre_heatapp !=. & pre_lab !=. & pre_glucose !=.
	replace pre_norm = 1 if pre_calc == 1 & pre_class != 0 & pre_vitsigns == 1 & pre_apgar != 0 & pre_heatapp == 1 & pre_lab == 1 & pre_glucose == 1 & pre_treatment != 0

	//Exclude if gestational age is >= 37 weeks
	tab neo_gestages_spec
	destring neo_gestages_spec, replace
		
	replace pre_norm = . if neo_gestages_spec !=. & neo_gestages_spec >=37
}

{ // LOW BIRTH WEIGHT 4070 (Peso < 2500 gr)
/* edad gestacional (Capurro o Ballard) + peso + [si el bebé nació en la unidad: clasificación del peso + APGAR] + frecuencia cardiaca + frecuencia respiratoria + longitud + circunferencia cefálica + Alimentación temprana o precoz (lactancia materna) o líquidos glucosados IV o sucedáneos + (si neumonía: antibióticos) + (si diarrea: solución IV + antibióticos) + (si convulsiones: anticonvulsivo) + (si hipoglicemia: lactancia materna o sucedáneo o glucosa IV) */

// Shorten varnames here
	foreach var in wt ht hr puls resp sil dow head ap1 ap5 skin {
		rename neo_lbw_check_reg_`var' lbw_`var'
	}

	foreach var in oxy gly {
		rename neo_lbw_lab_reg_`var' lbw_`var'
	}

	foreach var in ambu ventmec 100 maskoxy mask maskres camp helmet cyl cylcap cpap big nasal cath canula vent {
		rename neo_lbw_proc_oxy_`var' lbw_`var'
	}		
		
	foreach var in inc wrap lamp kang plastic bacin servo servocuna {
		rename neo_lbw_proc_heat_`var' lbw_`var'
	}
	
// GESTATIONAL AGE CALCULATION (Capurro/Ballard) 
	gen lbw_calc = 0 if neo_lbw_gest_method_1 != . & neo_lbw_gest_method_2 != . & neo_lbw_gest_method_3 != . & neo_lbw_gest_method_4 != . & neo_lbw_gest_method_5 != . & neo_lbw_gest_method_995 != .
	replace lbw_calc = 1 if neo_lbw_gest_method_3 == 1 | neo_lbw_gest_method_5 == 1 

// CLASSIFICATION [si el bebé nació en la unidad]
	gen lbw_class = 0 if neo_lbw_classification !=. 
	replace lbw_class = 1 if neo_lbw_classification == 1 | neo_lbw_classification == 2 | neo_lbw_classification == 3 
	replace lbw_class = . if neo_birth_where != 1
	
// CHECKS: peso + frecuencia cardiaca + frecuencia respiratoria + longitud + circunferencia cefálica
	gen lbw_vitsigns = 0 if lbw_hr !=. & lbw_puls !=. & lbw_resp !=. & lbw_wt !=. & lbw_head !=. & lbw_ht !=.
	replace lbw_vitsigns = 1 if (lbw_hr == 1 | lbw_puls == 1 ) & lbw_resp == 1 & lbw_wt == 1  & lbw_head == 1 & lbw_ht == 1
	
// APGAR [si el bebé nació en la unidad]
	gen lbw_apgar = 0 if lbw_ap1 !=. & lbw_ap5 !=.
	replace lbw_apgar = 1 if ( lbw_ap1 == 1 | lbw_ap5 == 1 )
	replace lbw_apgar =. if neo_birth_where != 1

// GLUCOSE: alimentación temprana precoz (lactancia materna) o líquidos glucosados IV o sucedáneos
	gen lbw_glucose = 0 if neo_lbw_babyfood_bf !=. & neo_lbw_babyfood_glucoseiv !=. & neo_lbw_babyfood_oral !=.
	replace lbw_glucose = 1 if ( neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_glucoseiv == 1 | neo_lbw_babyfood_oral == 1 ) 
 
// APPROPRIATE TREATMENT OF ASSOCIATED COMPLICATIONS
	// Pneumonia: antibióticos 
	gen lbw_pneutreat = 0 if neo_lbw_other_comp_pneu == 1 & anti !=.
	replace lbw_pneutreat = 1 if neo_lbw_other_comp_pneu == 1 & anti == 1
	
	// Diarrhea: solución IV 
	gen lbw_diatreat = 0 if neo_lbw_other_comp_dia == 1 & neo_lbw_babyfood_iv !=. & neo_lbw_babyfood_oral !=. 
	replace lbw_diatreat = 1 if neo_lbw_other_comp_dia == 1 & ( neo_lbw_babyfood_iv == 1 | neo_lbw_babyfood_oral == 1 ) 
	
	// Seizures: anticonvulsivo
	gen lbw_convtreat = 0 if neo_lbw_other_comp_conv == 1 & anticonv !=.
	replace lbw_convtreat = 1 if neo_lbw_other_comp_conv == 1 & anticonv == 1
	
	// Hypoglycemia: lactancia materna o sucedáneo o glucosa IV
	gen lbw_hypotreat = 0 if neo_lbw_other_comp_hipo == 1 &  neo_lbw_babyfood_iv !=. & neo_lbw_babyfood_oral !=. & neo_lbw_babyfood_bf !=.
	replace lbw_hypotreat = 1 if neo_lbw_other_comp_hipo == 1 & ( neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_glucoseiv == 1 | neo_lbw_babyfood_oral == 1 ) 	

	//Treatment overall
	gen lbw_treatment = 1 if lbw_pneutreat !=. | lbw_diatreat !=. | lbw_convtreat !=. | lbw_hypotreat !=.
	replace lbw_treatment = 0 if lbw_pneutreat == 0 | lbw_diatreat == 0 | lbw_convtreat == 0 | lbw_hypotreat == 0


// FINAL CALCULATION
	gen lbw_norm = 0 if lbw_calc !=. & lbw_vitsigns !=. & lbw_glucose !=.  
	replace lbw_norm = 1 if lbw_calc == 1 & lbw_class != 0 & lbw_vitsigns == 1 & lbw_glucose == 1 & lbw_apgar != 0 & lbw_treatment != 0

	//Exclude if weight is >= 2500 grams
	replace lbw_norm = . if neo_lbw_check_num_wt !=. & neo_lbw_check_num_wt >= 2500
}	


// INDICATOR CALCULATION ************************************************************
	gen I4070 = 0 if sep_norm !=. | pre_norm !=. | asp_norm !=. | lbw_norm !=.
	replace I4070 = 1 if sep_norm !=0 & pre_norm !=0 & asp_norm !=0	& lbw_norm !=0 & (sep_norm !=. | pre_norm !=. | asp_norm !=. | lbw_norm !=.)

	// Indicator value
	prop I4070 if time == "pre-evaluation" & tx_area == 1
	prop I4070 if time == "evaluation" & tx_area == 1
