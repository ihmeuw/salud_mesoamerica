************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Nicaragua Performance Indicator 4070
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

 // NEONATAL COMPLICATIONS RECORDS (4070)
	use "IHME_SMI_NIC_HFS_2022_NEOCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4070: Neonatal complications (sepsis, asphyxia, prematurity, low birth weight) managed according to the norm in the last two years
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
	
	//*Evaluation* period date range (7/1/2020 - 6/30/2022)
	replace time = "evaluation" if record_date >= date("2020-7-1", "YMD") & record_date <= date("2022-6-30", "YMD")
	
	//*Pre-evaluation* period date range (1/1/2019 - 6/30/2020)
	replace time = "pre-evaluation" if record_date >= date("2019-1-1", "YMD") & record_date <= date("2020-6-30", "YMD")

	//Keep only eligible records
	drop if time == ""
}	

// Adjustments
	replace neo_pre_check_num_wt =. if neo_pre_check_num_wt == -1
	replace neo_lbw_check_num_wt =. if neo_lbw_check_num_wt == -1

//Variable renaming
	foreach var in amp amik sulb pip clind gen metron peni penicry taz ors feno lev lido pento tio difenil diaze {
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

// All encompassing antibiotics variable
	gen anti = 0 if (lbw_amp !=. & lbw_amik !=. & lbw_sulb !=. & lbw_pip !=. & lbw_clind !=. & lbw_gen !=. & lbw_metron !=. & lbw_peni !=. & lbw_penicry !=. & lbw_taz !=. & mrr_neo_comp_lbw == 1 ) | (mrr_neo_comp_pre == 1 & pre_amp !=. & pre_amik !=. & pre_sulb !=. & pre_pip !=. & pre_clind !=. & pre_gen !=. & pre_metron !=. & pre_peni !=. & pre_penicry !=. & pre_taz !=. ) | (mrr_neo_comp_asp == 1 & asp_amp !=. & asp_amik !=. & asp_sulb !=. & asp_pip !=. & asp_genta !=. ) | (mrr_neo_comp_sep == 1 & sep_amp !=. & sep_amik !=. & sep_sulb !=. & sep_pip !=. & sep_clind !=. & sep_gen !=. & sep_metron !=. & sep_peni !=. & sep_penicry !=. & sep_taz !=. )
	replace anti = 1 if lbw_amp == 1 | lbw_amik == 1 | lbw_sulb == 1 | lbw_pip == 1 | lbw_clind == 1 | lbw_gen == 1 | lbw_metron == 1 | lbw_peni == 1 | lbw_penicry == 1 | lbw_taz == 1 | pre_amp == 1 | pre_amik == 1 | pre_sulb == 1 | pre_pip == 1 | pre_clind == 1 | pre_gen == 1 | pre_metron == 1 | pre_peni == 1 | pre_penicry == 1 | pre_taz == 1 | asp_amp == 1 | asp_amik == 1 | asp_sulb == 1 | asp_pip == 1 | asp_genta == 1 | sep_amp == 1 | sep_amik == 1 | sep_sulb == 1 | sep_pip == 1 | sep_clind == 1 | sep_gen == 1 | sep_metron == 1 | sep_peni == 1 | sep_penicry == 1 | sep_taz == 1 
	replace anti = 1 if regex(neo_sep_med_oan_name, "amoxi") | regex(neo_sep_med_oan_name, "cefotax") | regex(neo_sep_med_oan_name, "ceft") | regex(neo_sep_med_oan_name, "clox") | regex(neo_sep_med_oan_name, "penem") | regex(neo_sep_med_oan_name, "vanco") | regex(neo_sep_med_ome1_name, "cefadro") | regex(neo_sep_med_ome1_name, "cefix") |	regex(neo_sep_med_ome1_name, "cefotax") | regex(neo_sep_med_ome1_name, "cefox") | regex(neo_sep_med_ome1_name, "cipro") | 	regex(neo_sep_med_ome1_name, "penem") | regex(neo_sep_med_ome1_name, "penen") | regex(neo_sep_med_ome1_name, "vanco") | regex(neo_sep_med_ome2_name, "ceft") |	regex(neo_sep_med_ome2_name, "cefotax") | regex(neo_sep_med_ome2_name, "cipro") | regex(neo_sep_med_ome2_name, "penem") | regex(neo_sep_med_ome2_name, "penen") | regex(neo_sep_med_ome2_name, "vanco") | regex(neo_asp_med_oan_name, "amoxi") | regex(neo_asp_med_oan_name, "cefotax") | regex(neo_asp_med_oan_name, "ceft") | regex(neo_asp_med_oan_name, "cefalex") | regex(neo_asp_med_oan_name, "penem") | regex(neo_asp_med_oan_name, "penic") | regex(neo_asp_med_oan_name, "vanco") | regex(neo_asp_med_ome1_name, "amoxi") | regex(neo_asp_med_ome1_name, "cipro") | regex(neo_asp_med_ome1_name, "vanco") | regex(neo_asp_med_ome2_name, "cefitax") | regex(neo_lbw_med_ome1_name, "ceftr") | regex(neo_lbw_med_ome1_name, "penem") | regex(neo_lbw_med_ome1_name, "vanco") | regex(neo_lbw_med_ome2_name, "cefotax") | regex(neo_lbw_med_ome2_name, "cipro") | regex(neo_pre_med_ome1_name, "amoxi") | regex(neo_pre_med_ome1_name, "cefotax") | regex(neo_pre_med_ome1_name, "ceft") | regex(neo_pre_med_ome1_name, "penem") | regex(neo_pre_med_ome1_name, "vanco") | regex(neo_pre_med_ome2_name, "cefotax") | regex(neo_pre_med_ome2_name, "cipro") | regex(neo_lbw_med_oan_name, "amoxi") | regex(neo_lbw_med_oan_name, "cefotax") | regex(neo_lbw_med_oan_name, "cefox") | regex(neo_lbw_med_oan_name, "ceft") | regex(neo_lbw_med_oan_name, "genta") | regex(neo_lbw_med_oan_name, "penem") | regex(neo_lbw_med_oan_name, "vanco") | regex(neo_pre_med_oan_name, "amoxi") | regex(neo_pre_med_oan_name, "cefotax") | regex(neo_pre_med_oan_name, "cefox") | regex(neo_pre_med_oan_name, "penem") | regex(neo_pre_med_oan_name, "vanco")

// Check for any more
	tab1 neo_*_med_*_name if anti == 0

// Anti-convulsive
	gen anticonv = 0 if (pre_feno !=. & pre_lev !=. & pre_lido !=. & pre_pento !=. & pre_tio !=. & pre_difenil !=. & pre_diaze !=. & mrr_neo_comp_pre == 1 ) | (mrr_neo_comp_lbw == 1 & lbw_feno !=. & lbw_lev !=. & lbw_lido !=. & lbw_pento !=. & lbw_tio !=. & lbw_difenil !=. & lbw_diaze !=. )
	replace anticonv = 1 if pre_feno == 1 | pre_lev == 1 | pre_lido == 1 | pre_pento == 1 | pre_tio == 1 | pre_difenil == 1 | pre_diaze == 1 | lbw_feno == 1 | lbw_lev == 1 | lbw_lido == 1 | lbw_pento == 1 | lbw_tio == 1 | lbw_difenil == 1 | lbw_diaze == 1


{ // ASPHYXIA 4070 

// Shorten varnames here
	foreach var in puls hr resp ap1 ap5 {
		rename neo_asp_check_reg_`var' asp_`var'
	}

	foreach var in oxy gly {
		rename neo_asp_lab_reg_`var' asp_`var'
	}

	foreach var in ambu posvent helmet ventmec 100 maskoxy mask maskres camp cyl cylcap cpap big nasal cath canula vent {
		rename neo_asp_proc_oxy_`var' asp_`var'
	}

	foreach var in inc wrap warmsheet lamp kang kangfam plastic bacin servo servocuna {
		rename neo_asp_proc_heat_`var' asp_`var'
	}
	
	foreach var in sec intub massage {
		rename neo_asp_proc_oth_`var' asp_`var'
	}
	
// Create variable for severe asphyxia
	destring neo_asp_check_num_ap5, replace
	
	gen asp_severe = 0 if asp_ap5 !=.
	replace asp_severe = 1 if neo_asp_check_num_ap5 <= 3 & neo_asp_check_num_ap5 !=.
	

// CHECKS - BASIC & COMP: HR + respiratory rate + APGAR at 1 minute + APGAR at 5 minutes 
	gen asp_vitsigns = 0 if asp_hr !=. & asp_puls !=. & asp_resp !=. & asp_ap1 !=. & asp_ap5 !=. 
	replace asp_vitsigns = 1 if (asp_hr == 1 | asp_puls == 1 ) & asp_resp == 1 & asp_ap1 == 1 & asp_ap5 == 1 
	
// LAB - BASIC & COMP: glycemia (not severe) / glycemia & oxygen (severe)
	gen asp_lab = 0 if asp_gly !=. & asp_severe != 1
	replace asp_lab = 1 if asp_gly == 1 & asp_severe != 1 
	
	replace asp_lab = 0 if asp_gly !=. & asp_oxy !=. & asp_severe == 1
	replace asp_lab = 1 if asp_gly == 1 & asp_oxy == 1 & asp_severe == 1
	
// HEAT APPLICATION - BASIC & COMP: envuelto en manta o toalla o sabanas o lámpara de calor radiante o incubadora o madre canguro [Accepting any kind]
	gen asp_heatapp = 0 if asp_inc !=. & asp_wrap !=. & asp_warmsheet !=. & asp_lamp !=. & asp_kang !=. & asp_kangfam !=. & asp_plastic !=. & asp_bacin !=. & asp_servo !=. & asp_servocuna !=.
	replace asp_heatapp = 1 if asp_wrap == 1 | asp_warmsheet ==1 | asp_lamp == 1 | asp_inc == 1 | asp_kang == 1 | asp_kangfam == 1 | asp_plastic == 1 | asp_bacin == 1 | asp_servo == 1 | asp_servocuna == 1 | neo_asp_proc_htoth_spec !=""
	
// OXYGEN APPLICATION - BASIC & COMP: Aplicación de oxígeno (mascarilla o campana cefálica o bigotera o cánula o puntas nasales, otro) si asfixia severa 
	gen asp_oxyapp = 0 if asp_ventmec !=. & asp_helmet !=. & asp_100 !=. & asp_maskoxy !=. & asp_mask !=. & asp_maskres !=. & asp_camp !=. & asp_cyl !=. & asp_cylcap !=. & asp_cpap !=. & asp_big !=. & asp_nasal !=. & asp_cath !=. & asp_canula !=. & asp_vent !=. & asp_severe == 1
	replace asp_oxyapp = 1 if (asp_ventmec == 1 | asp_helmet == 1 | asp_100 == 1 | asp_maskoxy == 1 | asp_mask == 1 | asp_maskres == 1 | asp_camp == 1 | asp_cyl == 1 | asp_cylcap == 1 | asp_cpap == 1 | asp_big == 1 | asp_nasal == 1 | asp_cath == 1 | asp_canula == 1 | asp_vent == 1 ) & asp_severe == 1
 
// OTHER PROCEDURES - BASIC & COMPLETE: Ambu (Ventilación a Presión Positiva) o masaje cardiaco o intubación endotraqueal si asfixia severa 
	gen asp_othapp = 0 if asp_posvent !=. & asp_ambu !=. & asp_massage !=. & asp_intub !=. & asp_severe == 1
	replace asp_othapp = 1 if (asp_posvent == 1 | asp_ambu == 1 | asp_massage == 1 | asp_intub == 1 ) & asp_severe == 1

// EVALUATED APPROPRIATELY (doctor for all)
	gen asp_doc = 0 if neo_asp_con_ever !=. 
	replace asp_doc = 1 if neo_asp_con_ever == 1 

// BASIC FACILITIES REFERRED TO COMPLETE if severe asphyxia
	gen asp_ref = 0 if neo_disposition !=. & cone == "basic" & asp_severe == 1
	replace asp_ref = 1 if neo_disposition == 3 & cone == "basic" & asp_severe == 1
	replace asp_ref = . if neo_disposition == 1

// FINAL CALCULATION	
	gen asp_norm = .
	//Basic, not severe
	replace asp_norm = 0 if asp_vitsigns !=. & asp_lab !=. & asp_heatapp !=. & asp_doc !=. & cone == "basic" & asp_severe != 1
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_lab == 1 & asp_heatapp == 1 & asp_doc == 1 & cone == "basic" & asp_severe != 1
	//Basic, severe
	replace asp_norm = 0 if asp_vitsigns !=. & asp_lab !=. & asp_heatapp !=. & asp_oxyapp !=. & asp_othapp !=. & asp_doc !=. & cone == "basic" & asp_severe == 1
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_lab == 1 & asp_heatapp == 1 & asp_oxyapp ==1 & asp_othapp ==1 & asp_doc == 1 & asp_ref != 0 & cone == "basic" & asp_severe == 1 
	//Complete, not severe
	replace asp_norm = 0 if asp_vitsigns !=. & asp_lab !=. & asp_heatapp !=. & asp_doc !=. & regex(cone, "comp") & asp_severe != 1
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_lab == 1 & asp_heatapp == 1 & asp_doc == 1 & regex(cone, "comp") & asp_severe != 1
	//Complete, severe
	replace asp_norm = 0 if asp_vitsigns !=. & asp_lab !=. & asp_heatapp !=. & asp_oxyapp !=. & asp_othapp !=. & asp_doc !=. & regex(cone, "comp") & asp_severe == 1 
	replace asp_norm = 1 if asp_vitsigns == 1 & asp_lab == 1 & asp_heatapp == 1 & asp_oxyapp == 1 & asp_othapp == 1 & asp_doc == 1 & regex(cone, "comp") & asp_severe == 1 

	//Exclude referrals
	replace asp_norm = . if neo_adm_reffrom == 1
}		

{ // SEPSIS 4070

// Shorten varnames here
	foreach var in temp hr resp puls abd {
		rename neo_sep_check_reg_`var' sep_`var'
	}

	rename neo_sep_lab_reg_cbc sep_bio
	foreach var in oxy plq leuc hgb hemat bl proc abs band {
		rename neo_sep_lab_reg_`var' sep_`var'
	}
	
// CHECKS - BASIC & COMPLETE: temperature + hr/pulse + respiratory rate + abdominal examination
	gen sep_vitsigns = 0 if sep_hr !=. & sep_resp !=. & sep_temp !=. & sep_puls !=. & sep_abd !=.
	replace sep_vitsigns = 1 if sep_resp == 1 & sep_temp == 1 & (sep_puls == 1 | sep_hr == 1 ) & sep_abd == 1
	
// LAB - COMPLETE: oxygen saturation + Biometría hemática (plaquetas + leucocitos+ hemoglobina + hematócrito) + Hemocultivo + Proteína C Reactiva + Relación banda neutrófilos/relacion absoluta de neutrofilos
	gen sep_lab = 0 if sep_oxy !=. & sep_bio !=. & sep_plq !=. & sep_leuc !=. & sep_hgb !=. & sep_hemat !=. & sep_bl !=. & sep_proc !=. & sep_band !=. & sep_abs !=. & cone == "comp"
	replace sep_lab = 1 if sep_oxy == 1 & ( sep_bio == 1 | (sep_plq == 1 & sep_leuc == 1 & sep_hgb == 1 & sep_hemat == 1 )) & sep_bl == 1 & sep_proc == 1 & ( sep_abs == 1 | sep_band == 1 ) & cone == "comp"	

// MEDS - BASIC & COMPLETE: antibiotics
	gen sep_med = 0 if anti !=.
	replace sep_med = 1 if anti == 1 

// EVALUATED APPROPRIATELY (doctor for basic faciliteis and a specialist for complete facilities)
	gen sep_doc = 0 if neo_sep_con_ever !=. & cone == "basic"
	replace sep_doc = 1 if neo_sep_con_ever == 1 & cone == "basic"
	
	replace sep_doc = 0 if neo_sep_special_ever !=. & cone == "comp"
	replace sep_doc = 1 if (neo_sep_special_ever == 1 | neo_sep_special_ever == 2 | neo_sep_special_ever == 995 ) & cone == "comp"
	
// BASIC FACILITIES REFERRED TO COMPLETE if septic shock
	gen sep_ref = 0 if neo_disposition !=. & cone == "basic" & neo_sep_other_comp_shock == 1 
	replace sep_ref = 1 if neo_disposition == 3 & cone == "basic" & neo_sep_other_comp_shock == 1 

// FINAL CALCULATION
	gen sep_norm = .

	replace sep_norm = 0 if sep_vitsigns !=. & sep_med !=. & sep_doc !=. & cone == "basic"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_med ==1 & sep_doc == 1 & sep_ref != 0 & cone == "basic"

	replace sep_norm = 0 if sep_vitsigns !=. & sep_lab !=. & sep_med !=. & sep_doc !=. & cone == "comp"
	replace sep_norm = 1 if sep_vitsigns == 1 & sep_lab == 1 & sep_med == 1 & sep_doc == 1 & cone == "comp"
}	

{ // PREMATURITY 4070 

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
		
	foreach var in inc wrap warmsheet lamp kang kangfam plastic bacin servo servocuna {
		rename neo_pre_proc_heat_`var' pre_`var'
	}
	
// GEST AGE CALCULATION (Capurro/Ballard) - BASIC & COMPLETE
	gen pre_calc = 0 if neo_pre_gest_method_1 != . & neo_pre_gest_method_2 != . & neo_pre_gest_method_3 != . & neo_pre_gest_method_4 != . & neo_pre_gest_method_5 != . & neo_pre_gest_method_995 != .
	replace pre_calc = 1 if neo_pre_gest_method_3 == 1 | neo_pre_gest_method_5 == 1 
	replace pre_calc = . if neo_adm_reffrom == 1 
	
// CLASSIFICATION - BASIC & COMPLETE
	gen pre_class = 0 if neo_pre_classification !=. 
	replace pre_class = 1 if neo_pre_classification == 1 | neo_pre_classification == 2 | neo_pre_classification == 3 
	replace pre_class = . if neo_adm_reffrom == 1
	
// CHECKS - BASIC & COMPLETE: weight + HR + Resp + Silverman-Anderson + head circumference + any APGAR/skincheck
	gen pre_vitsigns = 0 if pre_hr !=. & pre_puls !=. & pre_resp !=. & pre_wt !=. & pre_sil !=. & pre_dow !=. & pre_head !=. & pre_ap1 !=. & pre_ap5 !=. & pre_skin !=. 
	replace pre_vitsigns = 1 if (pre_hr == 1 | pre_puls == 1 ) & pre_resp == 1 & pre_wt == 1 & (pre_sil == 1 | pre_dow == 1 ) & pre_head == 1 & ( pre_ap1 == 1 | pre_ap5 == 1 | pre_skin == 1 ) 
	
// LAB - BASIC & COMPLETE: Glycemia 
	gen pre_lab = 0 if pre_gly !=. 
	replace pre_lab = 1 if pre_gly == 1 
	
// HEAT APPLICATION - BASIC & COMPLETE: envuelto en manta o toalla o sabanas o lámpara de calor radiante o incubadora o madre canguro o bolsa plástica transparente [Any is accepted]
	gen pre_heatapp = 0 if pre_wrap !=. & pre_warmsheet !=. & pre_lamp !=. & pre_inc !=. & pre_kang !=. & pre_kangfam !=. & pre_plastic !=. & pre_bacin !=. & pre_servo !=. & pre_servocuna !=.
	replace pre_heatapp = 1 if pre_wrap == 1 | pre_warmsheet == 1 | pre_lamp == 1 | pre_inc == 1 | pre_kang == 1 | pre_kangfam == 1 | pre_plastic == 1 | pre_bacin == 1 | pre_servo == 1 | pre_servocuna == 1 | neo_pre_proc_htoth_spec !=""

// GLUCOSE - BASIC & COMPLETE: BF / oral serum / IV 
	gen pre_glucose = 0 if neo_pre_babyfood_bf !=. & neo_pre_babyfood_glucoseiv !=. & neo_pre_babyfood_oral !=.
	replace pre_glucose = 1 if neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | neo_pre_babyfood_glucoseiv == 1	

// EVALUATED APPROPRIATELY
	gen pre_doc = 0 if neo_pre_con_ever !=. 
	replace pre_doc = 1 if neo_pre_con_ever == 1 
	
// BASIC FACILITIES TRANSFERRED TO COMPLETE
	destring neo_pre_check_num_wt, replace
	gen pre_ref = 0 if neo_disposition !=. & ( neo_pre_check_num_wt < 1500 & neo_pre_check_num_wt !=. ) & cone == "basic"
	replace pre_ref = 1 if neo_disposition == 3 & ( neo_pre_check_num_wt < 1500 & neo_pre_check_num_wt !=. ) & cone == "basic"
	
// APPROPRIATE TREATMENT OF ASSOCIATED COMPLICATIONS	
	
	// Pneumonia: antibiotics (or referral to complete)
	gen pre_pneutreat = 0 if neo_pre_other_comp_pneu == 1 
	replace pre_pneutreat = 1 if neo_pre_other_comp_pneu == 1 & (neo_disposition == 3 | anti == 1 ) & cone == "basic"
	replace pre_pneutreat = 1 if neo_pre_other_comp_pneu == 1 & anti == 1 & cone == "comp"
	
	// Diarrhea: IV solution + antibiotics (or referral to complete)
	gen pre_diatreat = 0 if neo_pre_other_comp_dia == 1 
	replace pre_diatreat = 1 if neo_pre_other_comp_dia == 1 & (neo_disposition == 3 | neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | pre_ors == 1 ) & cone == "basic"
	replace pre_diatreat = 1 if neo_pre_other_comp_dia == 1 & ( neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | pre_ors == 1 ) & cone == "comp"
	
	// Seizures: anticonvulsants (or referral to complete)
	gen pre_convtreat = 0 if neo_pre_other_comp_conv == 1 
	replace pre_convtreat = 1 if neo_pre_other_comp_conv == 1 & (neo_disposition == 3 | anticonv == 1 ) & cone == "basic"
	replace pre_convtreat = 1 if neo_pre_other_comp_conv == 1 & anticonv == 1 & cone == "comp"
	
	// Hypoglycemia: glucose IV (or referral to complete)
	gen pre_hypotreat = 0 if neo_pre_other_comp_hipo == 1 
	replace pre_hypotreat = 1 if neo_pre_other_comp_hipo == 1 & (neo_disposition == 3 | neo_pre_babyfood_glucoseiv == 1 ) & cone == "basic"
	replace pre_hypotreat = 1 if neo_pre_other_comp_hipo == 1 & neo_pre_babyfood_glucoseiv == 1 & cone == "comp"	

	//Treatment overall
	gen pre_treatment = 1 if pre_pneutreat !=. | pre_diatreat !=. | pre_convtreat !=. | pre_hypotreat !=.
	replace pre_treatment = 0 if pre_pneutreat == 0 | pre_diatreat == 0 | pre_convtreat == 0 | pre_hypotreat == 0


// FINAL CALCULATION
	gen pre_norm = .

	replace pre_norm = 0 if pre_vitsigns !=. & pre_heatapp !=. & pre_lab !=. & pre_glucose !=. & pre_doc !=. & cone == "basic"
	replace pre_norm = 1 if pre_calc !=0 & pre_class !=0 & pre_vitsigns == 1 & pre_heatapp ==1 & pre_lab == 1 & pre_glucose == 1 & pre_doc == 1 & pre_ref !=0 & pre_treatment !=0 & cone == "basic"

	replace pre_norm = 0 if pre_vitsigns !=. & pre_lab !=. & pre_heatapp !=. & pre_glucose !=. & pre_doc !=. & cone == "comp"
	replace pre_norm = 1 if pre_calc !=0 & pre_class !=0 & pre_vitsigns == 1 & pre_lab == 1 & pre_heatapp == 1 & pre_glucose == 1 & pre_doc == 1 & pre_treatment !=0 & cone == "comp"

	//Exclude if gestational age is >= 37 weeks
	replace pre_norm = . if neo_gestages_spec !=. & neo_gestages_spec >=37
}

{ // LOW BIRTH WEIGHT 4070

// Shorten varnames here
	foreach var in wt hr puls resp sil dow head ap1 ap5 skin {
		rename neo_lbw_check_reg_`var' lbw_`var'
	}

	foreach var in oxy gly {
		rename neo_lbw_lab_reg_`var' lbw_`var'
	}

	foreach var in ambu ventmec 100 maskoxy mask maskres camp helmet cyl cylcap cpap big nasal cath canula vent {
		rename neo_lbw_proc_oxy_`var' lbw_`var'
	}		
		
	foreach var in inc wrap warmsheet lamp kang kangfam plastic bacin servo servocuna {
		rename neo_lbw_proc_heat_`var' lbw_`var'
	}
	
// GEST AGE CALCULATION (Capurro/Ballard) - BASIC & COMPLETE
	gen lbw_calc = 0 if neo_lbw_gest_method_1 != . & neo_lbw_gest_method_2 != . & neo_lbw_gest_method_3 != . & neo_lbw_gest_method_4 != . & neo_lbw_gest_method_5 != . & neo_lbw_gest_method_995 != .
	replace lbw_calc = 1 if neo_lbw_gest_method_3 == 1 | neo_lbw_gest_method_5 == 1 
	replace lbw_calc = . if neo_adm_reffrom == 1 
	
// CLASSIFICATION - BASIC & COMPLETE
	gen lbw_class = 0 if neo_lbw_classification !=. 
	replace lbw_class = 1 if neo_lbw_classification == 1 | neo_lbw_classification == 2 | neo_lbw_classification == 3 
	replace lbw_class = . if neo_adm_reffrom == 1
	
// CHECKS - BASIC & COMPLETE: weight + HR + Resp + Silverman-Anderson + head circumference + any APGAR/skincheck
	gen lbw_vitsigns = 0 if lbw_hr !=. & lbw_puls !=. & lbw_resp !=. & lbw_wt !=. & lbw_sil !=. & lbw_dow !=. & lbw_head !=. & lbw_ap1 !=. & lbw_ap5 !=. & lbw_skin !=. 
	replace lbw_vitsigns = 1 if (lbw_hr == 1 | lbw_puls == 1 ) & lbw_resp == 1 & lbw_wt == 1 & (lbw_sil == 1 | lbw_dow == 1 ) & lbw_head == 1 & ( lbw_ap1 == 1 | lbw_ap5 == 1 | lbw_skin == 1 ) 
	
// LAB - BASIC & COMPLETE: Glycemia 
	gen lbw_lab = 0 if lbw_gly !=. 
	replace lbw_lab = 1 if lbw_gly == 1 
	
// HEAT APPLICATION - BASIC & COMPLETE: envuelto en manta o toalla o sabanas o lámpara de calor radiante o incubadora o madre canguro o bolsa plástica transparente [Any is accepted]
	gen lbw_heatapp = 0 if lbw_wrap !=. & lbw_warmsheet !=. & lbw_lamp !=. & lbw_inc !=. & lbw_kang !=. & lbw_kangfam !=. & lbw_plastic !=. & lbw_bacin !=. & lbw_servo !=. & lbw_servocuna !=.
	replace lbw_heatapp = 1 if lbw_wrap == 1 | lbw_warmsheet == 1 | lbw_lamp == 1 | lbw_inc == 1 | lbw_kang == 1 | lbw_kangfam == 1 | lbw_plastic == 1 | lbw_bacin == 1 | lbw_servo == 1 | lbw_servocuna == 1 | neo_lbw_proc_htoth_spec !=""

// GLUCOSE - BASIC & COMPLETE: BF / oral serum / IV 
	gen lbw_glucose = 0 if neo_lbw_babyfood_bf !=. & neo_lbw_babyfood_glucoseiv !=. & neo_lbw_babyfood_oral !=.
	replace lbw_glucose = 1 if neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_oral == 1 | neo_lbw_babyfood_glucoseiv == 1	

// EVALUATED APPROPRIATELY
	gen lbw_doc = 0 if neo_lbw_con_ever !=. 
	replace lbw_doc = 1 if neo_lbw_con_ever == 1 
	
// BASIC FACILITIES TRANSFERRED TO COMPLETE
	destring neo_lbw_check_num_wt, replace
	gen lbw_ref = 0 if neo_disposition !=. & ( neo_lbw_check_num_wt < 1500 & neo_lbw_check_num_wt !=. ) & cone == "basic"
	replace lbw_ref = 1 if neo_disposition == 3 & ( neo_lbw_check_num_wt < 1500 & neo_lbw_check_num_wt !=. ) & cone == "basic"
	
// APPROPRIATE TREATMENT OF ASSOCIATED COMPLICATIONS	
	
	// Pneumonia: antibiotics (or referral to complete)
	gen lbw_pneutreat = 0 if neo_lbw_other_comp_pneu == 1 
	replace lbw_pneutreat = 1 if neo_lbw_other_comp_pneu == 1 & (neo_disposition == 3 | anti == 1 ) & cone == "basic"
	replace lbw_pneutreat = 1 if neo_lbw_other_comp_pneu == 1 & anti == 1 & cone == "comp"
	
	// Diarrhea: IV solution (or referral to complete)
	gen lbw_diatreat = 0 if neo_lbw_other_comp_dia == 1 
	replace lbw_diatreat = 1 if neo_lbw_other_comp_dia == 1 & (neo_disposition == 3 | neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_oral == 1 | lbw_ors == 1 ) & cone == "basic"
	replace lbw_diatreat = 1 if neo_lbw_other_comp_dia == 1 & ( neo_lbw_babyfood_bf == 1 | neo_lbw_babyfood_oral == 1 | lbw_ors == 1 ) & cone == "comp"
	
	// Seizures: anticonvulsants (or referral to complete)
	gen lbw_convtreat = 0 if neo_lbw_other_comp_conv == 1 
	replace lbw_convtreat = 1 if neo_lbw_other_comp_conv == 1 & (neo_disposition == 3 | anticonv == 1 ) & cone == "basic"
	replace lbw_convtreat = 1 if neo_lbw_other_comp_conv == 1 & anticonv == 1 & cone == "comp"
	
	// Hypoglycemia: glucose IV (or referral to complete)
	gen lbw_hypotreat = 0 if neo_lbw_other_comp_hipo == 1 
	replace lbw_hypotreat = 1 if neo_lbw_other_comp_hipo == 1 & (neo_disposition == 3 | neo_lbw_babyfood_glucoseiv == 1 ) & cone == "basic"
	replace lbw_hypotreat = 1 if neo_lbw_other_comp_hipo == 1 & neo_lbw_babyfood_glucoseiv == 1 & cone == "comp"	

	//Treatment overall
	gen lbw_treatment = 1 if lbw_pneutreat !=. | lbw_diatreat !=. | lbw_convtreat !=. | lbw_hypotreat !=.
	replace lbw_treatment = 0 if lbw_pneutreat == 0 | lbw_diatreat == 0 | lbw_convtreat == 0 | lbw_hypotreat == 0


// FINAL CALCULATION
	gen lbw_norm = .

	replace lbw_norm = 0 if lbw_vitsigns !=. & lbw_heatapp !=. & lbw_lab !=. & lbw_glucose !=. & lbw_doc !=. & cone == "basic"
	replace lbw_norm = 1 if lbw_calc !=0 & lbw_class !=0 & lbw_vitsigns == 1 & lbw_heatapp ==1 & lbw_lab == 1 & lbw_glucose == 1 & lbw_doc == 1 & lbw_ref !=0 & lbw_treatment !=0 & cone == "basic"

	replace lbw_norm = 0 if lbw_vitsigns !=. & lbw_lab !=. & lbw_heatapp !=. & lbw_glucose !=. & lbw_doc !=. & cone == "comp"
	replace lbw_norm = 1 if lbw_calc !=0 & lbw_class !=0 & lbw_vitsigns == 1 & lbw_lab == 1 & lbw_heatapp == 1 & lbw_glucose == 1 & lbw_doc == 1 & lbw_treatment !=0 & cone == "comp"
}	


// INDICATOR CALCULATION ************************************************************
	gen I4070 = 0 if sep_norm !=. | pre_norm !=. | asp_norm !=. | lbw_norm !=.
	replace I4070 = 1 if sep_norm !=0 & pre_norm !=0 & asp_norm !=0	& lbw_norm !=0 & (sep_norm !=. | pre_norm !=. | asp_norm !=. | lbw_norm !=.)

	// Indicator value
	prop I4070 if time == "pre-evaluation" & tx_area == 1
	prop I4070 if time == "evaluation" & tx_area == 1
