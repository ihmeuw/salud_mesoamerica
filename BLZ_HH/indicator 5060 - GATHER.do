************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 5060
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
***************************************

// TREATMENT OF DIARRHEA WITH ORS AND ZINC  (5060)
// bring in LQAS (household) data
use "IHME_SMI_HHS_BLZ_2022_LQAS_Y2023M08D17.dta", clear

// RESHAPE TO CHILD LEVEL 

	keep interview_loc kids_name_* kids_age_* kids_age_spec_* diarrhea_1 diarrhea_2 diarrhea_3 diarrhea_rx3* diarrhea_rx13* diarrhea4_1* diarrhea_drink* vaccard_*_spec* vaccard_where_* vacany* vacany_bcg* vacany_bcg_spec* vacany_penta* vacany_penta_spec* vacany_polio* vacany_polio_spec* vacany_dpt* vacany_dpt_spec* vacany_mmr* vacany_mmr_spec* vacany_hepb* vacany_hepb_spec* vacany_rota* vacany_rota_spec* vacany_pneum* vacany_pneum_spec* vaccard_where* vaccard_bcg* vaccard_bcg_spec* vaccard_penta* vaccard_penta_spec* vaccard_polio* vaccard_polio_spec* vaccard_dpt* vaccard_dpt_spec* vaccard_mmr* vaccard_mmr_spec* vaccard_hepb* vaccard_hepb_spec* vaccard_rota* vaccard_rota_spec* vaccard_pneum* vaccard_pneum_spec* woman_level_identifier 
	
	reshape long kids_name kids_age kids_age_spec diarrhea diarrhea_rx3 diarrhea_rx13 diarrhea4_1 diarrhea_drink1 diarrhea_drink2 diarrhea_drink3 vacany_1 vacany_bcg vacany_bcg_spec vacany_penta vacany_penta_spec vacany_polio vacany_polio_spec vacany_dpt vacany_dpt_spec vacany_mmr vacany_mmr_spec vacany_hepb vacany_hepb_spec vacany_rota vacany_rota_spec vacany_pneum vacany_pneum_spec vaccard_where vaccard_bcg vaccard_bcg_spec vaccard_penta vaccard_penta_spec vaccard_polio vaccard_polio_spec vaccard_dpt vaccard_dpt_spec vaccard_mmr vaccard_mmr_spec vaccard_hepb vaccard_hepb_spec vaccard_rota vaccard_rota_spec vaccard_pneum vaccard_pneum_spec , i(woman_level_identifier ) j(id_child) string 
	
	
	drop if kids_age_spec == . 
	
	
** ****************************
** ****************************
** Indicator 5060
**  ORS & zinc
** ****************************
** ****************************

	
	
// Determine treatments 
	gen diar_ors=.
	replace diar_ors=1 if diarrhea==1 & (diarrhea_drink1==1 | diarrhea_drink2==1 |  diarrhea_drink3==1)
	replace diar_ors=0 if diarrhea==1 & (diarrhea_drink1!=1 & diarrhea_drink2!=1 &  diarrhea_drink3!=1)
	
	gen diar_zinc=.
	replace diar_zinc=1 if diarrhea==1 & (diarrhea_rx3==1 | diarrhea_rx13==1)
	replace diar_zinc=0 if diarrhea==1 & ((diarrhea_rx3!=1 & diarrhea_rx13!=1 & diarrhea4==1) | diarrhea4!=1)

		gen diarrx_any = .
		replace diarrx_any = 1 if diarrhea_drink1==1 | diarrhea_drink2==1 | diarrhea_drink3==1 | diarrhea4==1
		replace diarrx_any = 0 if diarrhea_drink1==0 & diarrhea_drink2==0 & diarrhea_drink3==0 & diarrhea4==0
	
// Compute summary indicator 
	gen diar_ors_zinc=.
	replace diar_ors_zinc=1 if diar_ors==1 & diar_zinc==1
	replace diar_ors_zinc=0 if (diar_ors==0 | diar_zinc==0) 
	
// INDICATOR CALCULATION ************************************************************
	prop diar_ors_zinc 
	
