# Generate monthly asmr values using daily climate data
# and compile it with CMD data from ClimateBC v6.11
library(forestDroughtTool)
library(tidyverse)
library(magrittr)
library(weathercan)


# load daily EnvCan climate data
load("data-raw/climDataCleaned.RData")

# source asmrCalc function
source("data-raw/asmrCalc.R")

# create function to create asmr values by station
  asmrCompile<-function(stnName,lat1) {
  
      climData %>% 
      filter(stn_name==stnName) %>% 
      dplyr::select(date,tmn,tmx,ppt,year,month,day) %>% 
      arrange(year,month,day) %>% 
      asmrCalc(climateData=.,latitude=lat1) %>% 
      group_by(year,month) %>% # group by year and month
      summarise_at(vars(ends_with(".ASMR")),mean) %>% 
      mutate(stn_name=stnName) %>% 
      dplyr::select(stn_name,everything()) %>%
      return()
    }  
  
asmrData<-
        rbind(asmrCompile(stnName="GRAND FORKS",lat1=50),
        asmrCompile(stnName="LYTTON 2",lat1=50),
        asmrCompile(stnName="LUMBY",lat1=50),
        asmrCompile(stnName="PRINCE GEORGE A",lat1=55),
        asmrCompile(stnName="SMITHERS",lat1=55),
        asmrCompile(stnName="FORT ST JAMES",lat1=55),
        asmrCompile(stnName="QUESNEL A",lat1=55),
        asmrCompile(stnName="GOLDEN A",lat1=50))

# save this intermediate step, just in case!
save(asmrData,file="data-raw/asmrData.RData")




