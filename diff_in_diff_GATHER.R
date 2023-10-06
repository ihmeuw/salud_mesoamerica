
# ************************************ #
# R version 4.3.1
# Salud Mesoamerica Initiative
# Third Operation Evaluation
# 2023 - IHME
# Difference-in-difference analysis
# *********************************** #

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Libraries
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Install pacman library if it has not yet been installed. This is a package management library.
if(!require("pacman")){install.packages("pacman")}

# Load all requred packages using the pacman library. The p_load function will automatically install any packages that are not yet installed.
pacman::p_load(tidyverse, #Includes dplyr, tidyr, readr, stringr, ggplot2
               ggrepel, ggiraph, sf, #ggplot2 helper functions
               lubridate, #manage dates
               openxlsx, #For managing excel files
               here, # For identifying files and working directories
               survey, # For calculations
               captioner, # For tables and figures
               Hmisc, scales, # For formatting numbers in text (adding commas every 3 digits, change number to text, capitalize)
               flextable, officer, # For formatting table outputs, 
               english, textclean, qdapRegex, # For text formatting
               readstata13,  #for reading in stata data
               margins, #for DiD model
               data.table, #also used in DiD code brought in from elsewhere
               jtools
)


#Set up functions for models - NOTE code users need to replace "FILEPATH" below with data locations. 
#this function runs on the medical record review indicator datasets that have all rounds appended. 
crude_function <- function(iso_list, indicator, plot_title, timeseries = "wave_ordinal", weight = "none", incremental = F){
  
  #Loop over all countries
  country_list <- lapply(iso_list, function(iso1){
    
    #Load data 
    df <- read_csv(paste0("FILEPATH",indicator,".csv"), show_col_types = F)
    
    # Specify the dependent (indicator) variable
    df$indvar <- df[[paste0("I",indicator)]]
    
    # Format txarea variable
    df$tx_area <- NA
    df$tx_area[tolower(df$arm) %in% c("t", "treatment", "intervention")] <- 1
    df$tx_area[tolower(df$arm) %in% c("c", "control", "comparison")] <- 0
    
    #Remove 1st operation data
    df <- df[df$wave != "18",]
    
    #Remove comparison area data from SLV
    if(iso1=="SLV") {
      df <- df[df$tx_area ==1,]
    }
    
    # Create numeric wave variable
    df$wavenum <- NA
    df$wavenum[df$wave == "BL"] <- 0 
    df$wavenum[df$wave == "36"] <- 1 #2nd operation =1   
    df$wavenum[df$wave == "54 - payment"] <- 3 ##3rd operation payment
    df$wavenum[df$wave == "54 - pre-covid"] <- 2 #3rd operation pre-evaluation
    df$wavenum[df$wave == "54"] <- 3 ##3rd operation payment - facility-level supply indicators have no pre-eval
    
    #Specify which value to use as the time series in the model - default is ordinal wavenum set up above
    if(timeseries == "wave_ordinal"){
      df$timesrs <- df$wavenum
    } 
    
    # Set up generic weight variable if weight parameter was specified in the function call
    if(weight == "hh"){
      df$weight_generic <- df$weight_hh
    } else if(weight == "woman"){
      df$weight_generic <- df$weight_woman
    } else if(weight == "child"){
      df$weight_generic <- df$weight_child
    }
    
    
    dfbl36 <- df[df$wavenum %in% 0:1,]
    df3654 <- df[df$wavenum %in% c(1,3),]
    
    if(incremental == T & all(c(0,1) %in% unique(df$wavenum))){
      dflist <- list(dfbl36,df3654)
    } else if(incremental == T){
      dflist <- list(df3654)
    } else{
      dflist <- list(df)
    }
    
    dfloop <- lapply(dflist, function(x){
      
      # Specify design based on whether weights were included
      if(weight %in% c("hh","woman","child")) { #hh
        dsn <- svydesign(id=~wtSEG, strat=~tx_area, weights=~weight_generic, data = x, nest = T)
      } else { #hf & lqas
        dsn <-  svydesign(ids = ~1, strata = NULL, weights=~1, data = x) #no weighting or strata for now
      }
      
      # Run the crude regression - no covariates
      if(all(c(0,1) %in% unique(x$tx_area))){
        crude <- svyglm(formula = indvar ~ wavenum + tx_area + wavenum*tx_area , design = dsn)
      } else{
        crude <- svyglm(formula = indvar ~ wavenum, design = dsn)
      }
      
      
      # Predict proportions for charts
      nd <- expand.grid(tx_area = c(0,1),wavenum = c(0,1,2,3))
      
      #confine parameters to the combinations that exist in the data
      nd <- nd[nd$tx_area %in% unique(x$tx_area) & nd$wavenum %in% unique(x$wavenum),]
      
      p <- data.frame(predict(object = crude, newdata = nd))
      
      # Create a summary table of the model output
      smry <- data.frame(name = rownames(summ(crude)$coeftable),summ(crude)$coeftable)
      smry$p <- round(smry$p, digits =5)
      smry$S.E. <- round(smry$S.E., digits = 5)
      smry$t.val. <- NULL
      smry$Est. <- round(smry$Est., digits =5)
      rownames(smry) <- NULL
      smry <- bind_rows(smry, data.frame(name = "R²", Est. = attr(summ(crude), "rsq")))
      
      #get the F statistic
      om <- lm(indvar ~ wavenum + tx_area + wavenum*tx_area, data = x) 
      smlm <- summary(om)
      t <- data.frame(name = rownames(data.frame(smlm$fstatistic)), Est. = smlm$fstatistic)
      t$name[t$name == "value"] <- "F statistic"
      
      #and p-value
      pv <- data.frame( name = "F stat P value", Est. = pf(summary(om)$fstatistic[1], summary(om)$fstatistic[2], summary(om)$fstatistic[3], lower.tail=FALSE))
      pv$Est. <- round(pv$Est., digits = 20)
      
      smry <- bind_rows(smry, t, pv)
      smry$Est. <- round(smry$Est., digits =5)
      
      smry$iso <- iso1
      smry$increment <- paste(sort(unique(x$wavenum)), collapse = " - ")
      
      
      #And the ouput used for the graphs
      out <- cbind(nd, p, p$link+p$SE*qnorm(0.5*(1-0.95)), p$link-p$SE*qnorm(0.5*(1-0.95)))
      colnames(out) <- c("tx_area", "wavenum", "margin", "se", "lower_ci", "upper_ci")
      out$iso1 <- iso1
      
      return(list(out,smry))
    })
    
    out <- rbindlist(lapply(dfloop, `[[`, 1))
    out <- out[!duplicated(out),]
    smry <- rbindlist(lapply(dfloop, `[[`, 2))
    smry <- smry[!duplicated(smry),]
    
    #Return both tables
    return(list(out,smry))
  })
  
  #Append together all country tables  
  newout <- rbindlist(lapply(country_list, `[[`, 1))
  
  newout$tx_area <- factor(newout$tx_area, levels = c(1,0), labels = c("Intervention", "Comparison"))
  newout$wavenum <- factor(newout$wavenum, levels = 0:3,  c("Baseline", "2nd Op", "3rd Op pre-eval", "3rd Op"))
  newout$iso1 <- factor(newout$iso1, levels = c("BLZ", "SLV", "GTM", "HND", "MEX", "NIC", "PAN"), labels = c("Belize", "El Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua", "Panama"))
  
  newout$lower_ci <- ifelse(is.na(newout$lower_ci) | newout$lower_ci < 0, 0, newout$lower_ci)
  newout$upper_ci <- ifelse(is.na(newout$upper_ci) | newout$upper_ci > 1, 1, newout$upper_ci)
  
  newout <- distinct(newout, tx_area, wavenum, iso1, .keep_all = TRUE)
  
  p <- 
    ggplot(newout, aes(x = wavenum, y = margin, group = tx_area, color = tx_area)) + theme_classic() +
    geom_point() +
    geom_errorbar(aes(ymin = lower_ci, ymax = upper_ci, linetype = tx_area), width = .05) +
    geom_line(aes(linetype = tx_area)) +
    scale_x_discrete( expand = c(0,0.25)) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    theme(legend.position = "bottom", axis.text.x = element_text(angle = 20, vjust = 1, hjust=1))+ 
    labs(title = "plot_title", linetype = NULL, color = NULL, x = "", y = "Probability") +
    facet_grid(.~iso1) +
    theme(plot.title = element_blank()) + #NOTE- remove this to include the plot TITLE
    scale_color_manual(values = c("Intervention" = "#5880C3", "Comparison" = "#E7168D")) +
    scale_linetype_discrete() +
    guides(color = guide_legend(override.aes = list(linetype = c("solid", "dotted"))))
  
 
  summary_overall <- rbindlist(lapply(country_list, `[[`, 2))
  
  return(list(p,summary_overall, newout))
  
}

###############
#create output#
###############

#List countries to include
iso_list <- c("NIC", "HND", "BLZ", "SLV") # , "PAN", "MEX", "GTM",

# Run by indicator number

# 3030
lm_3030 <- crude_function(iso_list = c("NIC", "SLV", "BLZ"), indicator = "3030", plot_title = "3030 4+ ANC visits with quality, crude model, incremental",incremental = T)

lm_3030[[1]]

test <- crude_function(iso_list = c("NIC", "SLV", "BLZ"), indicator = "3030", plot_title = "3030 4+ ANC visits with quality, crude model",incremental = F)



# 3050
lm_3050 <- crude_function(iso_list = c("HND"), indicator = "3050", plot_title = "3050 5+ ANC visits with quality, crude model, incremental", incremental = T)

test <- crude_function(iso_list = c("HND"), indicator = "3050", plot_title = "3050 5+ ANC visits with quality, crude model")



# 3040
lm_3040 <- crude_function(iso_list = c("NIC"), indicator = "3040", plot_title = "3040 First ANC visit within 12 weeks, crude model, incremental", incremental = T)

test <- crude_function(iso_list = c("NIC"), indicator = "3040", plot_title = "3040 First ANC visit within 12 weeks, crude model", incremental =F)




# 4050
lm_4050 <- crude_function(iso_list = c("NIC", "SLV", "BLZ"), indicator = "4050", plot_title = "4050 Immediate postpartum care to country standard, crude model, incremental", incremental = T)

test <- crude_function(iso_list = c("NIC", "SLV", "BLZ"), indicator = "4050", plot_title = "4050 Immediate postpartum care to country standard, crude model")



# 4065
lm_4065 <- crude_function(iso_list = c("NIC"), indicator = "4065", plot_title = "4065 Partograph completion, uncomplicated deliveries, incremental", incremental = T)

test <- crude_function(iso_list = c("NIC"), indicator = "4065", plot_title = "4065 Partograph completion, uncomplicated deliveries", incremental = F)



# 4070
lm_4070 <- crude_function(iso_list = iso_list, indicator = "4070", plot_title = "4070 Management of neonatal complications, crude model, incremental", incremental = T)

test <- crude_function(iso_list = iso_list, indicator = "4070", plot_title = "4070 Management of neonatal complications, crude model", incremental = F)


# 4080
lm_4080 <- crude_function(iso_list = iso_list, indicator = "4080", plot_title = "4080 Management of maternal complications, crude model, incremental", incremental = T)

test <- crude_function(iso_list = iso_list, indicator = "4080", plot_title = "4080 Management of maternal complications, crude model")


# 4095
lm_4095 <- crude_function(iso_list = c("NIC"), indicator = "4095", plot_title = "4095 Active management of third stage of labor, crude model, incremental", incremental =T)

test <- crude_function(iso_list = c("NIC"), indicator = "4095", plot_title = "4095 Active management of third stage of labor, crude model")



# 4103
lm_4103 <- crude_function(iso_list = c("NIC", "HND"), indicator = "4103", plot_title = "4103 Routine newborn care with quality, crude model, incremental", incremental =T)

test <- crude_function(iso_list = c("NIC", "HND"), indicator = "4103", plot_title = "4103 Routine newborn care with quality, crude model")



#Testing out an adjusted model - we're not using this because of the data availability issues on patient-level variables, but we want to be able to show if it makes a difference in the results/conclusions to try an adjusted one
#NIC neonatal complications

df <- read_csv(paste0("NICARAGUAFILEPATH/indicators/4070.csv"), show_col_types = F)

# Specify the dependent (indicator) variable
df$indvar <- df$I4070

#clean up the new covariates - coded as -1 which means don't know, code to NA
df$mrr_age_mom_yr[df$mrr_age_mom_yr==-1] <- NA
df$mrr_mom_edu[df$mrr_mom_edu==-1] <- NA  #this is an ordinal, leave it as-is since it's just a test
df$mrr_mom_mar_stat[df$mrr_mom_mar_stat==-1] <- NA
#want married/partnered (1,2,7) vs. not
df$mrr_mom_unmarried[df$mrr_mom_mar_stat==1 |df$mrr_mom_mar_stat==2 |df$mrr_mom_mar_stat==7 ] <- 1
df$mrr_mom_unmarried[df$mrr_mom_mar_stat==3] <- 0
df$mrr_mom_unmarried[df$mrr_mom_mar_stat==995] <- NA
df$mrr_mom_unmarried[is.na(df$mrr_mom_mar_stat)] <- NA  

#want: indigenous yes/no (2,6,7)
df$mrr_mom_ethnicity[df$mrr_mom_ethnicity==-1] <- NA
df$mrr_mom_indig[df$mrr_mom_ethnicity==2 | df$mrr_mom_ethnicity==6 |df$mrr_mom_ethnicity==7] <- 1
df$mrr_mom_indig[df$mrr_mom_ethnicity==1 | df$mrr_mom_ethnicity==3 |df$mrr_mom_ethnicity==4 |df$mrr_mom_ethnicity==8] <- 0 #not necessarily true, but this is the assumption we'll use
df$mrr_mom_indig[is.na(df$mrr_mom_ethnicity)] <- NA


# Format txarea variable
df$tx_area <- NA
df$tx_area[tolower(df$arm) %in% c("t", "treatment", "intervention")] <- 1
df$tx_area[tolower(df$arm) %in% c("c", "control", "comparison")] <- 0

#Remove 1st operation data
df <- df[df$wave != "18",]

# Create numeric wave variable
df$wavenum <- NA
df$wavenum[df$wave == "BL"] <- 0 
df$wavenum[df$wave == "36"] <- 1 #2nd operation =1   
df$wavenum[df$wave == "54 - payment"] <- 3 ##3rd operation payment
df$wavenum[df$wave == "54 - pre-covid"] <- 2 #3rd operation pre-evaluation
df$wavenum[df$wave == "54"] <- 3 ##3rd operation payment - facility-level supply indicators have no pre-eval

#Specify which value to use as the time series in the model - default is ordinal wavenum set up above
df$timesrs <- df$wavenum

dfbl36 <- df[df$wavenum %in% 0:1,]
df3654 <- df[df$wavenum %in% c(1,3),]

dflist <- list(dfbl36,df3654)


dfloop <- lapply(dflist, function(x){
  
  # Specify design based on whether weights were included
  dsn <-  svydesign(ids = ~1, strata = NULL, weights=~1, data = x) #no weighting or strata for now
  
  ## ADDING PATIENT-LEVEL COVARIATES HERE
  crude <- svyglm(formula = indvar ~ mrr_age_mom_yr + mrr_mom_edu + mrr_mom_unmarried + mrr_mom_indig + wavenum + tx_area + wavenum*tx_area , design = dsn) 
  
  print(summary(crude))
  print(nobs(crude))
  
  # # Predict proportions for charts
  # nd <- expand.grid(tx_area = c(0,1),wavenum = c(0,1,2,3)) 
  # 
  # #confine parameters to the combinations that exist in the data
  # nd <- nd[nd$tx_area %in% unique(x$tx_area) & nd$wavenum %in% unique(x$wavenum),]
  # 
  # p <- data.frame(predict(object = crude, newdata = nd))
  
  # Create a summary table of the model output
  smry <- data.frame(name = rownames(summ(crude)$coeftable),summ(crude)$coeftable)
  smry$p <- round(smry$p, digits =5)
  smry$S.E. <- round(smry$S.E., digits = 5)
  smry$t.val. <- NULL
  smry$Est. <- round(smry$Est., digits =5)
  rownames(smry) <- NULL
  smry <- bind_rows(smry, data.frame(name = "R²", Est. = attr(summ(crude), "rsq")))
  
  #get the F statistic
  om <- lm(indvar ~ wavenum + tx_area + wavenum*tx_area, data = x) 
  smlm <- summary(om)
  t <- data.frame(name = rownames(data.frame(smlm$fstatistic)), Est. = smlm$fstatistic)
  t$name[t$name == "value"] <- "F statistic"
  
  #and p-value
  pv <- data.frame( name = "F stat P value", Est. = pf(summary(om)$fstatistic[1], summary(om)$fstatistic[2], summary(om)$fstatistic[3], lower.tail=FALSE))
  pv$Est. <- round(pv$Est., digits = 20)
  
  smry <- bind_rows(smry, t, pv)
  smry$Est. <- round(smry$Est., digits =5)
  
  smry$iso <- "NIC"
  #  smry$ind <- indicator
  smry$increment <- paste(sort(unique(x$wavenum)), collapse = " - ")
  
  # 
  # #And the ouput used for the graphs
  # out <- cbind(nd, p, p$link+p$SE*qnorm(0.5*(1-0.95)), p$link-p$SE*qnorm(0.5*(1-0.95)))
  # #rownames(out) <- c("Baseline control", "Baseline intervention", "36m control", "36m intervention")
  # colnames(out) <- c("tx_area", "wavenum", "margin", "se", "lower_ci", "upper_ci")
  # out$iso1 <- "NIC"
  return(smry)
  #return(list(out,smry))
})



