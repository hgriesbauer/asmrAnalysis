# Bring TACA-computed ASMR and ClimateBC together for analysis
library(tidyverse)

# load CMD data
load("data-raw/cmdData.Rdata")

# load asmr data
load("data-raw/asmrData.RData")

# Bring both datasets together
dat<-  
  cmd %>% 
  dplyr::select(stn_name,bgc,Year,7:18) %>% 
  pivot_longer(starts_with("CMD"),names_to="month",values_to="CMD") %>% 
  mutate(month=str_remove(month,pattern="CMD")) %>% 
  mutate(month=as.integer(month)) %>% 
  right_join(asmrData,by=c("stn_name","Year"="year","month"))

save(dat,file="data/cmdASMR.RData")

