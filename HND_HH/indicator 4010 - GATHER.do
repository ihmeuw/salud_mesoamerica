************************************
// STATA/SE 17.0
// Salud Mesoamerica Initiative
// Third Operation Evaluation
// February 2023 - IHME
// Honduras Performance Indicator 4010
// For detailed indicator definition, see Honduras Household and Health Facility Survey Report Appendix B https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
***************************************

// INSTITUTIONAL DELIVERY (4010)
// bring in module 2B data
	use "IHME_SMI_HND_HHS_2022_MOD2B_Y2023M08D17.dta", clear
	
// Recreate tx_area
gen tx_area = 1
replace tx_area = 0 if arm == "Comparison"

// Create cmi_text_ variable
gen cmi_text_ = 0
gen del_name_text_=lower(del_name_text2)
replace cmi_text_=1 if regexm(del_name_text_,"materno infantil")
replace cmi_text_=2 if regexm(del_name_text_,"clinica materno")
replace cmi_text_=3 if regexm(del_name_text_,"clinica materno infantil")
replace cmi_text_=4 if regexm(del_name_text_,"cm i")
replace cmi_text_=4 if regexm(del_name_text_,"cmi")
replace cmi_text_=5 if regexm(del_name_text_,"clinica  materno  infantil  publica")
replace cmi_text_=6 if regexm(del_name_text_,"clinica  materno  infantil")
replace cmi_text_=7 if regexm(del_name_text_,"clinica  materno  in fantil  publica")
replace cmi_text_=8 if regexm(del_name_text_,"hospital")
replace cmi_text_=9 if regexm(del_name_text_,"clinica materna")
replace cmi_text_=9 if regexm(del_name_text_,"clinica  matetno  infantil  publica")
replace cmi_text_=9 if regexm(del_name_text_,"materno infa til")
replace cmi_text_=9 if regexm(del_name_text_,"materno taulabe")
			
replace cmi_text_=9 if regexm(del_name_text_,"hombro") //14 cases of "Hombro a Hombro" which is a gestor of 2 CMIs in intervention area (Intibuca)
replace cmi_text_=9 if regexm(del_name_text_,"jaral")  //67 cases of "el jaral" which is gestor of SMI Hector Bueso Arias, Sta Rita Copan
replace cmi_text_=9 if regexm(del_name_text_,"bueso arias") //3 cases - same SMI ^
	
***********************************************************************************
**  Indicator 4010: Delivery in Servicio Materno-Infantil or hospital with skilled personnel (Dr, nurse, aux nurse)
***********************************************************************************

	gen mostrecentbirth_last2yrs = lb_last2years ==1 & lb_mostrecent==1	 

	
	gen del_sba_=. // 3rd operation counts aux nurse as skilled
	replace del_sba=1 if (del_doc==1|del_pronur==1|del_auxnur==1) 
	replace del_sba=0 if (del_doc==0&del_pronur==0&del_auxnur==0)
	la var del_sba "delivery attended by doctor or professional nurse or auxiliary nurse "
	
	// location of delivery  
	gen del_fac_cmi_hosp_=. 
	replace del_fac_cmi_hosp=1 if del_where==3 | del_where==7 //Hospitals
	replace del_fac_cmi_hosp=0 if del_where!=3 & del_where!=7 & del_where!=. & del_where>=0
	
	foreach value in 120104	130204	100301	20312	150201	150401	131103	170616	51206	101101	21509	82101	52003	121801	101603 132502 42003	 { //SMIs at 3rd operation 
		replace del_fac_cmi_hosp=1 if del_name==`value' 
	}

	*HONDURAS ONLY: Adjust delivery location for SMIs (aka CMIs) entered through other-specify - these need to be counted for the indicator    	
	replace del_fac_cmi_hosp=1 if cmi_text_ >=1 & cmi_text_!=. //correct for the ones manually screened for CMI entered in other-specify at 3rd operation 


	*for indicator: includes SBA, and births in SMI or hospital
	gen del_fac_sba_cmi_hosp_=.
	replace del_fac_sba_cmi_hosp=1 if del_fac_cmi_hosp==1&del_sba==1
	replace del_fac_sba_cmi_hosp=0 if del_fac_cmi_hosp==1&del_sba==0
	replace del_fac_sba_cmi_hosp=0 if del_fac_cmi_hosp==0&del_sba==1
	replace del_fac_sba_cmi_hosp=0 if del_fac_cmi_hosp==0&del_sba==0
	
// INDICATOR CALCULATION ************************************************************
	cap rename wtseg wtSEG
	svyset wtSEG [pweight=weight_woman], strata(tx_area) 
	
	di in red _newline "Indicator: Women (15-49) who had an in-facility delivery with skilled personnel in their most recent pregnancy in the last two years"
	tab del_fac_sba_cmi_hosp if  mostrecentbirth_last2yrs==1 & tx_area ==1	
	svy, subpop(if mostrecentbirth_last2yrs==1): prop del_fac_sba_cmi_hosp, over(tx_area)	

	******************		
	
	