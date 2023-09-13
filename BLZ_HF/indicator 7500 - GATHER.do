************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// September 2022 - IHME
// Belize Performance Indicator 7500
// For detailed indicator definition, see Belize Health Facility and Community Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
************************************

// HEALTH FACILITIES (7500)
	use "IHME_SMI_BLZ_HFS_2022_HFQ_Y2023M08D17.dta", clear

*******************************************************************************************************
// Indicator 7500: Basic and Complete EONC facilities that report, access and use quality data for decision-making from the health information and quality management systems
*******************************************************************************************************

// Denominator: Basic and Complete facilities
	keep if cone == 2 | cone == 3

// Numerator: Basic and Complete EONC facilities should comply with the following three criteria:
	//o	Complete self-monitoring measurements for the past 3-months are available in the health information system with adequate quality:
	//		The target sample of medical records for self-monitoring indicators was collected. 
	//o	The facility (quality improvement team or regional manager or chief of staff and nursing administrator) is able to access data, view reports and generate graphs:
	//		Staff in the health facility are able to demonstrate that they can access data, view reports and generate graphs on the day of the visit
	//o	There is evidence that data is used for decision making 
	//		Quality Improvement Plans were developed for the last three months and there is evidence of planned activities in the latest plan 

// Does the Uncomplicated Deliveries indicator display information (graphs/reports) for the months of April, May, AND June 2022? 
	gen past3months = 0 if dash_obs_uncomp_mon !=.
	replace past3months = 1 if dash_obs_uncomp_mon == 1

// Quality Improvement Plans were developed for the last three months and there is evidence of planned activities in the latest plan 	
	gen qual_plans_3months = 0 if dash_obs_qiu_apr !=. & dash_obs_qiu_may !=. & dash_obs_qiu_jun !=.
	replace qual_plans_3months = 1 if dash_obs_qiu_apr == 1 & dash_obs_qiu_may == 1 & dash_obs_qiu_jun == 1
	
	gen planned_activities = 0 if dash_obs_qiu_junact !=.
	replace planned_activities = 1 if dash_obs_qiu_junact == 1
	
	
// INDICATOR CALCULATION ************************************************************
	gen I7500 = 0 if past3months !=. & qual_plans_3months !=. & planned_activities !=.
	replace I7500 = 1 if past3months == 1 & qual_plans_3months == 1 & planned_activities == 1
	
	// Indicator Value
	prop I7500
