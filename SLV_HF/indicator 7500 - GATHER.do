************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// El Salvador Performance Indicator 7500
// For detailed indicator definition, see El Salvador Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
************************************

// HEALTH FACILITIES (7500)
	use "IHME_SMI_SLV_HFS_2022_HFQ_Y2023M08D17.dta", clear

*******************************************************************************************************
// Indicator 7500: Establecimientos de Salud que utilizan información de calidad para la toma de decisiones y la mejora de la calidad
*******************************************************************************************************

// Denominator: Establecimientos de Salud del Primer Nivel de Atención
	keep if cone == 1
	

//1. Primero se revisa la disponibilidad de las actas de las reuniones mensuales de los 3 meses previos a la medición en los Establecimiento de Salud.
	gen actas_disp = 0 if actas_obs_may !=. & actas_obs_jun !=. & actas_obs_jul !=.
	replace actas_disp = 1 if actas_obs_may == 1 & actas_obs_jun == 1 & actas_obs_jul == 1


//2. Después, se selecciona aleatoriamente un acta seleccionada (entre las actas de los últimos 3 meses) y se revisa: existe el resumen del análisis de la información, el resumen de la discusión realizada y evidencia escrita de por lo menos un acuerdo tomado que puede ser de aspectos operativos, de gestión, de referencia, entre otros.
	// resumen del análisis de la información
	tab actas_rev_analysis
	// resumen de la discusión realizada	
	tab actas_rev_summary
	// evidencia escrita de por lo menos un acuerdo tomado
	tab actas_rev_agree
	// all
	gen actas_rev = 0 if actas_rev_analysis !=. & actas_rev_summary !=. & actas_rev_agree !=.
	replace actas_rev = 1 if actas_rev_analysis == 1 & actas_rev_summary == 1 & actas_rev_agree == 1
	
	
//3. Finalmente, se revisa el acta subsecuente al acta seleccionada para revisar que se hizo seguimiento a los acuerdos tomadas en la reunión anterior (en caso de que se seleccionen actas del último mes o quincena, se tomará el acta previa)	
	tab acta_seg
	
// INDICATOR CALCULATION ************************************************************
	gen I7500 = 0 if actas_disp !=. 
	replace I7500 = 1 if actas_disp == 1 & actas_rev == 1 & acta_seg == 1
	
	//Indicator Value
	prop I7500 if tx_area == 1
	