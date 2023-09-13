************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// Feburary 2023 - IHME
// Honduras Performance Indicator 2010
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// CONTRACEPTIVE COVERAGE (2010)
// bring in module 2A data
	use "IHME_SMI_HND_HHS_2022_MOD2A_Y2023M08D17.dta", clear
	
// Rename heard back to useeever_ to match code
	foreach var in m1_fst m2_mst m3_iud m4_inj m5_imp m6_ocp m7_con m8_fco m9_dia m10_spo m11_lam m12_rhy m13_wdr m15_omo m16_otr {
		rename `var'_heard `var'_useever_
	}
	
// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"
	
***********************************************************************************
**  Indicator 2010: Use of modern contraceptive method among women in need of contraception
***********************************************************************************

*create variable for women using modern contraceptive method
gen using_modern_contra_ = (fp_nouse2_hyst==1 | m1_fst_usenow==1 | m2_mst_usenow==1 | m3_iud_usenow==1 | ///
	m4_inj_usenow==1 | m5_imp_usenow==1 | m6_ocp_usenow==1 | m7_con_usenow==1 | m8_fco_usenow==1 | m9_dia_usenow==1 | ///
	m10_spo_usenow==1 | m15_omo_usenow==1)
	replace using_modern_contra = . if m1_fst_heard2==. 
	
*create variable for women "in need of contraception"
	gen in_need_of_contra_ = . 
	replace in_need_of_contra_ = 1 if (m1_fst_heard2!=. | m1_fst_useever!=.) & preg1!=1 & fp_nouse2_nosex!=1 & fp_nouse2_vir!=1 & fp_nouse2_meno!=1 & fp_nouse2_preg!=1 & fp_nouse2_wantpr!=1 & fp_preg_desire !=1 & fp_nouse2_infert !=1 
	replace in_need_of_contra_ = 0 if (m1_fst_heard2!=. | m1_fst_useever!=.) & (preg1==1 | fp_nouse2_nosex==1 | fp_nouse2_vir==1 | fp_nouse2_meno==1 | fp_nouse2_preg==1 | fp_nouse2_wantpr==1 | fp_preg_desire ==1 | fp_nouse2_infert ==1)
	
	
// INDICATOR CALCULATION ************************************************************
	cap rename wtseg wtSEG
	svyset wtSEG [pweight=weight_woman], strata(tx_area) 

	di in red _newline "Indicator 2010: Contraceptive prevalence"
	tab using_modern_contra tx_area if in_need_of_contra ==1 
	svy, subpop(if in_need_of_contra_==1): prop using_modern_contra_, over(tx_area)		
******************		
