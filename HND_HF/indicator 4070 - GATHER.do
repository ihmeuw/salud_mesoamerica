************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Honduras Performance Indicator 4070
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

 // NEONATAL COMPLICATIONS RECORDS (4070)
	use "IHME_SMI_HND_HFS_2022_NEOCOMP_Y2023M08D17.dta", clear

***************************************************************************************
// Indicator 4070: Neonatal complications (sepsis, asphyxia, prematurity) managed according to the norm in the last two years
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
	
// Generate antibiotics variables from 'other specify'
	foreach comp in lbw asp sep pre {
		//format
		foreach type in oan ome1 ome2 {
			tostring  neo_`comp'_med_`type'_name, replace
			cap qui replace neo_`comp'_med_`type'_name = lower(neo_`comp'_med_`type'_name)
			replace neo_`comp'_med_`type'_name = "" if neo_`comp'_med_`type'_name == "."
			replace neo_`comp'_med_`type'_name = lower(neo_`comp'_med_`type'_name)
		}

		//amoxicillin
		gen `comp'_amoxi = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_amoxi = 1 if regex(neo_`comp'_med_oan_name, "amoxi") | regex(neo_`comp'_med_ome1_name, "amoxi") | regex(neo_`comp'_med_ome2_name, "amoxi")
		
		//azitromicin
		gen `comp'_azitro = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_azitro = 1 if regex(neo_`comp'_med_oan_name, "azitro") | regex(neo_`comp'_med_ome1_name, "azitro") | regex(neo_`comp'_med_ome2_name, "azitro")
		
		//cefixime
		gen `comp'_cefix = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_cefix = 1 if regex(neo_`comp'_med_oan_name, "cefix") | regex(neo_`comp'_med_ome1_name, "cefix") | regex(neo_`comp'_med_ome2_name, "cefix")

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
		
		//imipenem
		gen `comp'_imip = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_imip = 1 if regex(neo_`comp'_med_oan_name, "imipene") | regex(neo_`comp'_med_ome1_name, "imipene") | regex(neo_`comp'_med_ome2_name, "imipene")
		
		//meropenem
		gen `comp'_mero = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_mero = 1 if regex(neo_`comp'_med_oan_name, "meropen") | regex(neo_`comp'_med_ome1_name, "meropen") | regex(neo_`comp'_med_ome2_name, "meropen")
		
		//levofloxacin
		gen `comp'_levo = 0 if neo_`comp'_med_adm_oan !=. & neo_`comp'_med_adm_ome1 !=. & neo_`comp'_med_adm_ome2 !=.
		replace `comp'_levo = 1 if regex(neo_`comp'_med_oan_name, "levoflox") | regex(neo_`comp'_med_ome1_name, "levoflox") | regex(neo_`comp'_med_ome2_name, "levoflox")
		
		//recategorize
		cap gen `comp'_penicry =.
		cap replace `comp'_penicry = 1 if regex(neo_`comp'_med_ome1_name, "penicilina cristalina")
		cap gen `comp'_amp =.
		cap replace `comp'_amp = 1 if regex(neo_`comp'_med_oan_name, "terabiol") | regex(neo_`comp'_med_ome1_name, "terabiol")	
		cap gen `comp'_sulb =.
		cap replace `comp'_sulb = 1 if regex(neo_`comp'_med_oan_name, "terabiol") | regex(neo_`comp'_med_ome1_name, "terabiol")	
		cap gen `comp'_taz =.
		cap replace `comp'_taz = 1 if regex(neo_`comp'_med_oan_name, "tazo")		
	}
	
// For each one, check whether it was administered once
	foreach var in amp amik sulb pip clind gen metron peni penicry taz amoxi azitro cefix cefotax cefuro cloxa vanco ceftaz chloram imip mero levo {
		cap gen lbw_`var' =.
		cap gen pre_`var' =.
		cap gen sep_`var' =.
		cap gen asp_`var' =.
		
		gen allcomps_`var' = 0 if lbw_`var' !=. | pre_`var' !=. | sep_`var' !=. | asp_`var' !=.
		replace allcomps_`var' = 1 if lbw_`var' == 1 | pre_`var' == 1 | sep_`var' == 1 | asp_`var' == 1
	}	
	
// For double/triple therapy, check whether two or more antibiotics were administered
// Number administered
	egen num_antibiotics = anycount(allcomps_amp allcomps_amik allcomps_sulb allcomps_pip allcomps_clind allcomps_gen allcomps_metron allcomps_peni allcomps_penicry allcomps_taz allcomps_amoxi allcomps_azitro allcomps_cefix allcomps_cefotax allcomps_cefuro allcomps_cloxa allcomps_vanco allcomps_ceftaz allcomps_chloram allcomps_imip allcomps_mero allcomps_levo), value(1) 
	
	// At least one?
	gen anti = 0 if num_antibiotics !=.
	replace anti = 1 if num_antibiotics >= 1 & num_antibiotics !=.
	
	// Two or more?
	gen double_anti = 0 if num_antibiotics !=.
	replace double_anti = 1 if num_antibiotics > 1 & num_antibiotics !=.

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

	foreach var in inc wrap lamp kang plastic bacin servo servocuna {
		rename neo_asp_proc_heat_`var' asp_`var'
	}
	
	foreach var in sec intub massage {
		rename neo_asp_proc_oth_`var' asp_`var'
	}
	
// Create variable for severe asphyxia
	tab neo_asp_check_num_ap5
	destring neo_asp_check_num_ap5, replace
	
	gen asp_severe = 0 if asp_ap5 !=.
	replace asp_severe = 1 if neo_asp_check_num_ap5 <= 3 & neo_asp_check_num_ap5 !=.
	

// CHECKS - BASIC & COMP: HR + respiratory rate + APGAR at 1 minute + APGAR at 5 minutes 
	gen asp_vitsigns = 0 if asp_hr !=. & asp_puls !=. & asp_resp !=. & asp_ap1 !=. & asp_ap5 !=. 
	replace asp_vitsigns = 1 if (asp_hr == 1 | asp_puls == 1 ) & asp_resp == 1 & asp_ap1 == 1 & asp_ap5 == 1 
	
// LAB - BASIC & COMP: osygen saturation (only if severe at basic facilities)
	gen  asp_lab = 0 if asp_oxy !=. & ( asp_severe == 1 | cone == "comp")
	replace asp_lab = 1 if asp_oxy == 1 & ( asp_severe == 1 | cone == "comp")
	
// HEAT APPLICATION - BASIC & COMP: envuelto en manta o toalla o sabanas o lámpara de calor radiante o incubadora o madre canguro [Accepting any kind]
	gen asp_heatapp = 0 if asp_inc !=. & asp_wrap !=. &  asp_lamp !=. & asp_kang !=. & asp_plastic !=. & asp_bacin !=. & asp_servo !=. & asp_servocuna !=.
	replace asp_heatapp = 1 if asp_wrap == 1 | asp_lamp == 1 | asp_inc == 1 | asp_kang == 1 | asp_plastic == 1 | asp_bacin == 1 | asp_servo == 1 | asp_servocuna == 1 | neo_asp_proc_htoth_spec !=""
	
// OXYGEN APPLICATION - BASIC & COMP: Aplicación de oxígeno (mascarilla o campana cefálica o bigotera o cánula o puntas nasales, otro) si asfixia severa 
	gen asp_oxyapp = 0 if asp_ventmec !=. & asp_helmet !=. & asp_100 !=. & asp_maskoxy !=. & asp_mask !=. & asp_maskres !=. & asp_camp !=. & asp_cyl !=. & asp_cylcap !=. & asp_cpap !=. & asp_big !=. & asp_nasal !=. & asp_cath !=. & asp_canula !=. & asp_vent !=. & asp_severe == 1
	replace asp_oxyapp = 1 if (asp_ventmec == 1 | asp_helmet == 1 | asp_100 == 1 | asp_maskoxy == 1 | asp_mask == 1 | asp_maskres == 1 | asp_camp == 1 | asp_cyl == 1 | asp_cylcap == 1 | asp_cpap == 1 | asp_big == 1 | asp_nasal == 1 | asp_cath == 1 | asp_canula == 1 | asp_vent == 1 ) & asp_severe == 1
 
// OTHER PROCEDURES - BASIC & COMPLETE: Ambu (Ventilación a Presión Positiva) o masaje cardiaco o intubación endotraqueal si asfixia severa 
	gen asp_othapp = 0 if asp_posvent !=. & asp_ambu !=. & asp_massage !=. & asp_intub !=. & asp_severe == 1
	replace asp_othapp = 1 if (asp_posvent == 1 | asp_ambu == 1 | asp_massage == 1 | asp_intub == 1 ) & asp_severe == 1

// EVALUATED APPROPRIATELY (doctor for basic, specialist for complete)
	gen asp_doc = 0 if neo_asp_con_ever !=. & cone == "basic"
	replace asp_doc = 1 if neo_asp_con_ever == 1 & cone == "basic"
	
	replace asp_doc = 0 if neo_asp_special_ever !=. & cone == "comp"
	replace asp_doc = 1 if (neo_asp_special_ever == 1 | neo_asp_special_ever == 2 | neo_asp_special_ever == 995 ) & cone == "comp"

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

	foreach var in oxy bio plq leuc hgb hemat bl proc abs band {
		rename neo_sep_lab_reg_`var' sep_`var'
	}
	
// CHECKS - BASIC & COMPLETE: temperature + hr/pulse + respiratory rate 
	gen sep_vitsigns = 0 if sep_hr !=. & sep_resp !=. & sep_temp !=. & sep_puls !=.
	replace sep_vitsigns = 1 if sep_resp == 1 & sep_temp == 1 & (sep_puls == 1 | sep_hr == 1 )
	
// LAB - COMPLETE: oxygen saturation + Biometría hemática (plaquetas + leucocitos+ hemoglobina + hematócrito) + Hemocultivo + Proteína C Reactiva + Relación banda neutrófilos/relacion absoluta de neutrofilos
	gen sep_lab = 0 if sep_oxy !=. & sep_bio !=. & sep_plq !=. & sep_leuc !=. & sep_hgb !=. & sep_hemat !=. & sep_bl !=. & sep_proc !=. & sep_band !=. & sep_abs !=. & cone == "comp"
	replace sep_lab = 1 if sep_oxy == 1 & ( sep_bio == 1 | (sep_plq == 1 & sep_leuc == 1 & sep_hgb == 1 & sep_hemat == 1 )) & sep_bl == 1 & sep_proc == 1 & ( sep_abs == 1 | sep_band == 1 ) & cone == "comp"	

// MEDS - BASIC: antibiotics // COMPLETE: double therapy antibiotic
	gen sep_med = 0 if anti !=. & cone == "basic"
	replace sep_med = 1 if anti == 1 & cone == "basic"
	
	replace sep_med = 0 if double_anti !=. & cone == "comp"
	replace sep_med = 1 if double_anti == 1 & cone == "comp"

// EVALUATED APPROPRIATELY (doctor for basic faciliteis and a specialist for complete facilities)
	gen sep_doc = 0 if neo_sep_con_ever !=. & cone == "basic"
	replace sep_doc = 1 if neo_sep_con_ever == 1 & cone == "basic"
	
	replace sep_doc = 0 if neo_sep_special_ever !=. & cone == "comp"
	replace sep_doc = 1 if (neo_sep_special_ever == 1 | neo_sep_special_ever == 2 | neo_sep_special_ever == 995 ) & cone == "comp"
	
// BASIC FACILITIES REFERRED TO COMPLETE
	gen sep_ref = 0 if neo_disposition !=. & cone == "basic" 
	replace sep_ref = 1 if neo_disposition == 3 & cone == "basic" 

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
		
	foreach var in inc wrap lamp kang plastic bacin servo servocuna {
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
	
// LAB - COMPLETE: Glycemia + oxygen saturation
	gen pre_lab = 0 if pre_gly !=. & pre_oxy !=. & cone == "comp"
	replace pre_lab = 1 if pre_gly == 1 & pre_oxy == 1 & cone == "comp"
	
// HEAT APPLICATION - BASIC & COMPLETE: envuelto en manta o toalla o sabanas o lámpara de calor radiante o incubadora o madre canguro o bolsa plástica transparente [Any is accepted]
	gen pre_heatapp = 0 if pre_wrap !=. & pre_lamp !=. & pre_inc !=. & pre_kang !=. & pre_plastic !=. & pre_bacin !=. & pre_servo !=. & pre_servocuna !=.
	replace pre_heatapp = 1 if pre_wrap == 1 | pre_lamp == 1 | pre_inc == 1 | pre_kang == 1 | pre_plastic == 1 | pre_bacin == 1 | pre_servo == 1 | pre_servocuna == 1 | neo_pre_proc_htoth_spec !=""

// GLUCOSE - BASIC & COMPLETE: BF / oral serum / IV 
	gen pre_glucose = 0 if neo_pre_babyfood_bf !=. & neo_pre_babyfood_glucoseiv !=. & neo_pre_babyfood_oral !=.
	replace pre_glucose = 1 if neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | neo_pre_babyfood_glucoseiv == 1	

// EVALUATED APPROPRIATELY (doctor for basic faciliteis and a specialist for complete facilities)
	gen pre_doc = 0 if neo_pre_con_ever !=. & cone == "basic"
	replace pre_doc = 1 if neo_pre_con_ever == 1 & cone == "basic"
	
	replace pre_doc = 0 if neo_pre_special_ever !=. & cone == "comp"
	replace pre_doc = 1 if (neo_pre_special_ever == 1 | neo_pre_special_ever == 2 | neo_pre_special_ever == 995 ) & cone == "comp"
	
// BASIC FACILITIES TRANSFERRED TO COMPLETE if weight <2000 g or complications
	destring neo_pre_check_num_wt, replace
	gen pre_ref = 0 if neo_disposition !=. & cone == "basic" & ((neo_pre_check_num_wt !=. & neo_pre_check_num_wt <2000 ) | neo_pre_other_comp_pneu == 1 | neo_pre_other_comp_dia == 1 | neo_pre_other_comp_conv == 1 | neo_pre_other_comp_hipo == 1 )
	replace pre_ref = 1 if neo_disposition == 3 & cone == "basic" & ((neo_pre_check_num_wt !=. & neo_pre_check_num_wt <2000 ) | neo_pre_other_comp_pneu == 1 | neo_pre_other_comp_dia == 1 | neo_pre_other_comp_conv == 1 | neo_pre_other_comp_hipo == 1 )
	
// APPROPRIATE TREATMENT OF ASSOCIATED COMPLICATIONS	
	
	// Pneumonia: antibiotics
	gen pre_pneutreat = 0 if neo_pre_other_comp_pneu == 1 & anti !=. & cone == "comp"
	replace pre_pneutreat = 1 if neo_pre_other_comp_pneu == 1 & anti == 1 & cone == "comp"
	
	// Diarrhea: IV solution or antibiotics
	gen pre_diatreat = 0 if neo_pre_other_comp_dia == 1 & anti !=. & neo_pre_babyfood_bf !=. & neo_pre_babyfood_oral !=. & pre_ors !=. &  cone == "comp" 
	replace pre_diatreat = 1 if neo_pre_other_comp_dia == 1 & (anti == 1 | neo_pre_babyfood_bf == 1 | neo_pre_babyfood_oral == 1 | pre_ors == 1 ) & cone == "comp"
	
	// Seizures: anticonvulsants
	gen pre_convtreat = 0 if neo_pre_other_comp_conv == 1 & anticonv !=. & cone == "comp"
	replace pre_convtreat = 1 if neo_pre_other_comp_conv == 1 & anticonv == 1 & cone == "comp"
	
	// Hypoglycemia: glucose IV
	gen pre_hypotreat = 0 if neo_pre_other_comp_hipo == 1 & neo_pre_babyfood_glucoseiv !=. & cone == "comp"	
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


// INDICATOR CALCULATION ************************************************************
	gen I4070 = 0 if sep_norm !=. | pre_norm !=. | asp_norm !=.
	replace I4070 = 1 if sep_norm !=0 & pre_norm !=0 & asp_norm !=0	& (sep_norm !=. | pre_norm !=. | asp_norm !=.)

	// Indicator value - NOTE: EVALUATION PERIOD INDICATOR VALUE ONLY APPLICABLE TO COMPLETE LEVEL 
	prop I4070 if time == "pre-evaluation" & tx_area == 1 & cone == "comp"
	prop I4070 if time == "evaluation" & tx_area == 1 & cone == "comp"
	
