************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 5020
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
***************************************

// COMPLETE VACCINATION FOR AGE  (5020)
// bring in LQAS (household) data
use "IHME_SMI_HHS_BLZ_2022_LQAS_Y2023M08D17.dta", clear
cap rename *, lower

// RESHAPE TO CHILD LEVEL 

	keep interview_loc kids_name_* kids_age_* kids_age_spec_* diarrhea_1 diarrhea_2 diarrhea_3 diarrhea_rx3* diarrhea_rx13* diarrhea4_1* diarrhea_drink* vaccard_*_spec* vaccard_where_* vacany* vacany_bcg* vacany_bcg_spec* vacany_penta* vacany_penta_spec* vacany_polio* vacany_polio_spec* vacany_dpt* vacany_dpt_spec* vacany_mmr* vacany_mmr_spec* vacany_hepb* vacany_hepb_spec* vacany_rota* vacany_rota_spec* vacany_pneum* vacany_pneum_spec* vaccard_where* vaccard_bcg* vaccard_bcg_spec* vaccard_penta* vaccard_penta_spec* vaccard_polio* vaccard_polio_spec* vaccard_dpt* vaccard_dpt_spec* vaccard_mmr* vaccard_mmr_spec* vaccard_hepb* vaccard_hepb_spec* vaccard_rota* vaccard_rota_spec* vaccard_pneum* vaccard_pneum_spec* woman_level_identifier 
	
	reshape long kids_name kids_age kids_age_spec diarrhea diarrhea_rx3 diarrhea_rx13 diarrhea4_1 diarrhea_drink1 diarrhea_drink2 diarrhea_drink3 vacany_1 vacany_bcg vacany_bcg_spec vacany_penta vacany_penta_spec vacany_polio vacany_polio_spec vacany_dpt vacany_dpt_spec vacany_mmr vacany_mmr_spec vacany_hepb vacany_hepb_spec vacany_rota vacany_rota_spec vacany_pneum vacany_pneum_spec vaccard_where vaccard_bcg vaccard_bcg_spec vaccard_penta vaccard_penta_spec vaccard_polio vaccard_polio_spec vaccard_dpt vaccard_dpt_spec vaccard_mmr vaccard_mmr_spec vaccard_hepb vaccard_hepb_spec vaccard_rota vaccard_rota_spec vaccard_pneum vaccard_pneum_spec , i(woman_level_identifier ) j(id_child) string 
	
	
	drop if kids_age_spec == . 
	

** ****************************
** ****************************
** Indicator 5020 
**  Complete vaccination for age 
** ****************************
** ****************************

// IMPORTANT INDICATOR NOTE: Vaccine questions are only asked in household surveys, not in market surveys. 

//Recall section: indicate that at least one dose was given if the mother recalls that the vaccine was given, but does not know or declines to report on the number of doses received (RECALL)

	
foreach vac in "bcg" "penta" "polio" "dpt" "mmr" "hepb" "rota" "pneum" { 
		replace vacany_`vac'_spec = 1 if vacany_`vac'==1 & vacany_`vac'_spec==-1
		replace vacany_`vac'_spec = 1 if vacany_`vac'==1 & vacany_`vac'_spec==-2
	}
		
		foreach vac in bcg penta polio dpt mmr hepb rota pneum  {
		replace vacany_`vac' =. if vacany_`vac' <0
		replace vacany_`vac'_spec = 0 if vacany_`vac' ==0
		}	
		
	// More specific variables to generate, beyond the indicators themselves - the indicator is for any vaccine compliance, but here we also can break down into card or recall
	
	// 1. 1 dose of hepatitis B at birth- required since 2018
	gen hepb_compliant_recall = 0 if kids_age_spec!=. & interview_loc==2 //vaccine section only applies for HH interviews 
	replace hepb_compliant_recall = 1 if kids_age_spec<=1 & interview_loc==2 // All children that are younger than or equal to 1 month in age receive a value of 1 because they are automatically compliant.
	replace hepb_compliant_recall = 1 if kids_age_spec>1 & kids_age_spec!=. & ( (vacany_hepb_spec>=1 & vacany_hepb_spec!=.) | (vacany_hepb==1) ) & interview_loc==2 
	replace hepb_compliant_recall = . if kids_age_spec>1 & kids_age_spec!=. & (vacany_hepb_spec==.) & interview_loc==2  //this will stay missing if vacany==0, but this definition is consistent with the other countries
	replace hepb_compliant_recall = 0 if kids_age_spec>1 & kids_age_spec!=. & vacany_hepb==0  & interview_loc==2 	
	
	// 2. 1 dose of BCG <3 months
	gen bcg_compliant_recall = 0 if kids_age_spec!=. & interview_loc==2 //vaccine section only applies for HH interviews 
	replace bcg_compliant_recall = 1 if kids_age_spec<=3 & interview_loc==2 // All children that are younger than or equal to 3 months in age receive a value of 1 because they are automatically compliant.
	replace bcg_compliant_recall = 1 if kids_age_spec>3 & kids_age_spec!=. & ( (vacany_bcg_spec>=1 & vacany_bcg_spec!=.) | (vacany_bcg==1) ) & interview_loc==2 
	replace bcg_compliant_recall = . if kids_age_spec>3 & kids_age_spec!=. & (vacany_bcg_spec==.) & interview_loc==2  //this will stay missing if vacany==0, but this definition is consistent with the other countries
	replace bcg_compliant_recall = 0 if kids_age_spec>3 & kids_age_spec!=. & vacany_bcg==0  & interview_loc==2 
	
	// 3. OPV at 2 months, 4 months, 6 months, booster 4-5 yrs (this booster will not be included in the compliance calculation, because 5-yr olds can get it and still be compliant, and we do not capture these kids) 	
	gen opv_compliant_recall = 0 if kids_age_spec!=. & interview_loc==2 
	replace opv_compliant_recall = 1 if kids_age_spec<=2 & interview_loc==2 
	replace opv_compliant_recall = 1 if (kids_age_spec>2 & kids_age_spec<=4) & ( (vacany_polio_spec>=1 & vacany_polio_spec!=.) | (vacany_polio==1)) & interview_loc==2 
	replace opv_compliant_recall = . if (kids_age_spec>2 & kids_age_spec<=4) & (vacany_polio_spec==.)  & interview_loc==2 
	replace opv_compliant_recall = 1 if (kids_age_spec>4 & kids_age_spec<=6) & ( (vacany_polio_spec>=2 & vacany_polio_spec!=.)) & interview_loc==2 
	replace opv_compliant_recall = . if (kids_age_spec>4 & kids_age_spec<=6) & (vacany_polio_spec==.)  & interview_loc==2 
	replace opv_compliant_recall = 1 if (kids_age_spec>6 & kids_age_spec!=.) & ( (vacany_polio_spec>=3 & vacany_polio_spec!=.) ) & interview_loc==2 
	replace opv_compliant_recall = . if (kids_age_spec>6 & kids_age_spec!=.) & (vacany_polio_spec==.)  & interview_loc==2 
	replace opv_compliant_recall = 0 if kids_age_spec>2 & kids_age_spec!=. & vacany_polio==0  & interview_loc==2 
	
	// 4. Pentavalent at 2, 4, and 6 months 	
	gen pent_compliant_recall = 0 if kids_age_spec!=. & interview_loc==2 
	replace pent_compliant_recall = 1 if kids_age_spec<=2 & interview_loc==2 
	replace pent_compliant_recall = 1 if (kids_age_spec>2 & kids_age_spec<=4) & ( (vacany_penta_spec>=1 & vacany_penta_spec!=.) | (vacany_penta==1)) & interview_loc==2 
	replace pent_compliant_recall = . if (kids_age_spec>2 & kids_age_spec<=4) & (vacany_penta_spec==.)  & interview_loc==2 
	replace pent_compliant_recall = 1 if (kids_age_spec>4 & kids_age_spec<=6) & ( (vacany_penta_spec>=2 & vacany_penta_spec!=.) ) & interview_loc==2 
	replace pent_compliant_recall = . if (kids_age_spec>4 & kids_age_spec<=6) & (vacany_penta_spec==.)  & interview_loc==2 
	replace pent_compliant_recall = 1 if (kids_age_spec>6 & kids_age_spec!=.) & ( (vacany_penta_spec>=3 & vacany_penta_spec!=.) ) & interview_loc==2 
	replace pent_compliant_recall = . if (kids_age_spec>6 & kids_age_spec!=.) & (vacany_penta_spec==.) & interview_loc==2 
	replace pent_compliant_recall = 0 if kids_age_spec>2 & kids_age_spec!=. & vacany_penta==0  & interview_loc==2 
		
	* 5. MMR at 1 year, 18mo 	
	gen mmr_compliant_recall = 0 if kids_age_spec!=. & interview_loc==2 
	replace mmr_compliant_recall = 1 if kids_age_spec<=12 & interview_loc==2 
	replace mmr_compliant_recall = 1 if (kids_age_spec>12 & kids_age_spec<=18) & ( (vacany_mmr_spec>=1 & vacany_mmr_spec!=.) | (vacany_mmr==1) ) & interview_loc==2 
	replace mmr_compliant_recall = . if (kids_age_spec>12 & kids_age_spec<=18) & (vacany_mmr_spec==.)  & interview_loc==2 
	replace mmr_compliant_recall = 1 if (kids_age_spec>18 & kids_age_spec!=.) & ( (vacany_mmr_spec>=2 & vacany_mmr_spec!=.) ) & interview_loc==2 
	replace mmr_compliant_recall = . if (kids_age_spec>18 & kids_age_spec!=.) & (vacany_mmr_spec==.) & interview_loc==2 
	replace mmr_compliant_recall = 0 if kids_age_spec>12 & kids_age_spec!=. & vacany_mmr==0  & interview_loc==2 
		
	* 6. DPT booster 4-5 yrs (this booster will not be included in the compliance calculation, because 5-yr olds can get it and still be compliant, and we do not capture these kids)  
	

// Compute summary indicator - does not require DPT because it's included in penta
	gen vac_compliant_recall = 0
	replace vac_compliant_recall = 1 if hepb_compliant_recall==1 & bcg_compliant_recall==1 & opv_compliant_recall==1 & pent_compliant_recall==1 &  mmr_compliant_recall==1 
	replace vac_compliant_recall = . if hepb_compliant_recall==. | bcg_compliant_recall==. | opv_compliant_recall==. | pent_compliant_recall==. |  mmr_compliant_recall==. 
		
	
//exclude children not interviewed in HH (only ones that should be asked about vaccine)
local market  bcg_compliant_recall opv_compliant_recall pent_compliant_recall mmr_compliant_recall mmr_compliant hepb_compliant_recall
foreach var in `market' {
	replace `var' = . if interview_loc !=2
	}	
	
// INDICATOR CALCULATION ************************************************************
	prop vac_compliant_recall
	
