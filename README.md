# salud_mesoamerica

***********************************************************************************
**  Institute for Health Metrics and Evaluation -- Salud Mesoamerica Initiative  **
**  2022-23 3rd Operation Household and Health Facility Indicators Code Release  **
***********************************************************************************

The codes provided in this repository allow the user to replicate estimates for 3rd Operation (2022) performance indicators for each country 
	(Belize [BLZ], El Salvador[SLV], Honduras[HND], Nicaragua[NIC]).
Codes are .do files prepared in STATA/SE 17.0.

ABBREVIATIONS in directories: 
HH = Household (or community) survey
HF = Health Facility survey
Countries are abbreviated by 3-letter ISO code.

----
Data
----
The codes can be run with datasets provided through the Global Health Data Exchange (URLs below).
The data must be converted to .dta or read in from .csv in order to use the codes provided. 
Please note that the filename provided in each code references a particular survey module.

Belize Salud Mesoamérica Initiative Third Follow-Up Household Survey 2022		https://ghdx.healthdata.org/record/ihme-data/belize-salud-mesoamérica-initiative-third-follow-household-survey-2022
El Salvador Salud Mesoamérica Initiative Third Follow-Up Household Survey 2022		https://ghdx.healthdata.org/record/ihme-data/el-salvador-salud-mesoamérica-initiative-third-follow-household-survey-2022
Honduras Salud Mesoamérica Initiative Third Follow-Up Household Survey 2022		https://ghdx.healthdata.org/record/ihme-data/honduras-salud-mesoamérica-initiative-third-follow-household-survey-2022
Nicaragua Salud Mesoamérica Initiative Third Follow-Up Household Survey 2022		https://ghdx.healthdata.org/record/ihme-data/nicaragua-salud-mesoamérica-initiative-third-follow-household-survey-2022
Belize Salud Mesoamérica Initiative Third Follow-Up Health Facility Survey 2022		https://ghdx.healthdata.org/record/ihme-data/belize-salud-mesoamérica-initiative-third-follow-health-facility-survey-2022
El Salvador Salud Mesoamérica Initiative Third Follow-Up Health Facility Survey 2022	https://ghdx.healthdata.org/record/ihme-data/el-salvador-salud-mesoamérica-initiative-third-follow-health-facility-survey-2022
Honduras Salud Mesoamérica Initiative Third Follow-Up Health Facility Survey 2022	https://ghdx.healthdata.org/record/ihme-data/honduras-salud-mesoamérica-initiative-third-follow-health-facility-survey-2022
Nicaragua Salud Mesoamérica Initiative Third Follow-Up Health Facility Survey 2022	https://ghdx.healthdata.org/record/ihme-data/nicaragua-salud-mesoamérica-initiative-third-follow-health-facility-survey-2022

--------------------
Supporting materials
--------------------
More detail about the indicators and the household and health facility survey methods are available in Household and Health Facility Survey Reports. 
Indicator estimates are provided in Appendix A and details of indicator construction are provided in Appendix B.

Belize
https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Belize%20Household%20and%20Health%20Facility%20Report%20-%20May%202023.pdf
El Salvador
https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/El%20Salvador%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
Honduras
https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Honduras%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf
Nicaragua
https://www.healthdata.org/sites/default/files/files/Projects/SaludMesoamerica/Nicaragua%20Household%20and%20Health%20Facility%20Report%20-%20June%202023.pdf

------------
Code Authors
------------
Health facility survey:
Max Thom
Haaris Saqib
Casey Johanns

Household survey and community survey:
Matt Dearstyne
Yenny Guzman
Alex Schaefer
Katie Panhorst Harris
