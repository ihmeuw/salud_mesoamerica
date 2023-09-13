************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Nicaragua Performance Indicator 7500
// For detailed indicator definition, see Nicaragua Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
************************************

// HEALTH FACILITIES (7500)
	use "IHME_SMI_NIC_HFS_2022_HFQ_Y2023M08D17.dta", clear

*******************************************************************************************************
// Indicator 7500: Hospitales regionales, departamentales y primarios que gestionan la información con calidad para la toma de decisiones.
*******************************************************************************************************

// Denominator: Total de hospitales regionales, departamentales, y primarios 
	keep if fac_type == 4 | fac_type == 5 | fac_type == 6

// 1. Se encontró 4 de 6 planes de mejora en los últimos 6 meses en el hospital
	egen total_months_obs = anycount(dash_obs_jan dash_obs_feb dash_obs_mar dash_obs_apr dash_obs_may dash_obs_jun), value(1) 
	
// 2. Para un mes seleccionado aleatoriamente (en los últimos 6 meses) se verifica que se ha identificado alguna brecha en relación a complicaciones obstétricas y neonatales ya sea relacionadas con el manejo de la complicación, o con los sistemas de apoyo (como falta de insumos, capacitación del personal, sistema de información o/y registro, aspectos de gestión) y además se verifica que se ha dado seguimiento a alguno de los problemas identificados en el mes siguiente.
	foreach month in jan feb mar apr may jun {
		gen gap_followup_`month' = 0 if   dash_obs_`month' !=.
		replace gap_followup_`month' = 1 if dash_obs_`month'act ==1 & dash_obs_`month'plan ==1 & dash_obs_`month'date ==1
	}
	
	//Randomly select one month
	set seed 2022 //Randomly chosen seed number assures the same month is chosen for each calculation
	gen random_month = runiformint(1,6)
	
	// Requirements met for the randomly selected month
	gen random_month_pass = 0 if gap_followup_jan !=. & gap_followup_feb!=. & gap_followup_mar !=. & gap_followup_apr !=. & gap_followup_may !=. & gap_followup_jun !=.
	replace random_month_pass = 1 if gap_followup_jan == 1 & random_month == 1
	replace random_month_pass = 1 if gap_followup_feb == 1 & random_month == 2	
	replace random_month_pass = 1 if gap_followup_mar == 1 & random_month == 3
	replace random_month_pass = 1 if gap_followup_apr == 1 & random_month == 4
	replace random_month_pass = 1 if gap_followup_may == 1 & random_month == 5
	replace random_month_pass = 1 if gap_followup_jun == 1 & random_month == 6
	
	//At least one month passes
	gen at_least_one_month_pass = 0 if gap_followup_jan !=. & gap_followup_feb!=. & gap_followup_mar !=. & gap_followup_apr !=. & gap_followup_may !=. & gap_followup_jun !=.
	replace at_least_one_month_pass = 1 if gap_followup_jan ==1 | gap_followup_feb==1 | gap_followup_mar ==1 | gap_followup_apr ==1 | gap_followup_may ==1 | gap_followup_jun ==1
	
	//All months pass - not used for indicator
	gen all_months_pass = 0 if gap_followup_jan !=. & gap_followup_feb!=. & gap_followup_mar !=. & gap_followup_apr !=. & gap_followup_may !=. & gap_followup_jun !=.
	replace all_months_pass = 1 if gap_followup_jan ==1 & gap_followup_feb==1 & gap_followup_mar ==1 & gap_followup_apr ==1 & gap_followup_may ==1 & gap_followup_jun ==1
	tab all_months_pass tx_area, m
	
// INDICATOR CALCULATION ************************************************************
	gen I7500 = 0 if total_months_obs !=. & random_month_pass !=. 
	replace I7500 = 1 if total_months_obs >= 4 & total_months_obs !=. & random_month_pass == 1
	
	// Indicator Value
	prop I7500 if tx_area == 1
