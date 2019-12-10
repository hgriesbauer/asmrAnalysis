# Script to format file from ClimateBC

cmd<-
  read_csv("data-raw/stnFile_1901-2018MSY.csv") %>% 
  dplyr::select(1:6,starts_with("CMD")) %>% 
  arrange(ID1,Year) %>% 
  select(stn_name=ID1,bgc=ID2,everything())

save(cmd,file="data-raw/cmdData.RData")
