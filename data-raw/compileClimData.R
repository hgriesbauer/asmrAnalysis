# Script to download and clean Environment Canada data for use in historical ASMR analysis

# Load libraries
library(weathercan)
library(tidyverse)
library(forestDroughtTool)
library(sf)
library(bcmaps)

# Step 1 - Select stations in BC with daily data and assign to 'stn'
stn<-
  stations %>% 
  filter(prov=="BC" & interval=="day") %>%  
  
  # Step 1.2 - Convert to a spatial file and merge with BGC units (this will take awhile!)
  st_as_sf(coords=c("lon","lat")) %>% # convert to spatial file
  st_set_crs(4326) %>% # set to WGS1984 datum
  transform_bc_albers() %>% # set to BC albers projection
  st_join(bec()[,"MAP_LABEL"]) %>%  # merge with BEC
  st_drop_geometry() # drop geometry

# Step 2 Summarize station coverage
stn %>% 
  mutate(length=end-start+1) %>% # create a column to show record length
  filter(length>50) %>% # filter for stations with more than 50 years' of data
  filter(end>2005) %>% # filter for records that end after 2005
  arrange(desc(MAP_LABEL,length)) %>% 
  View()
  
# Select stations to download that have sufficient records and in BGC units of interest
stnList=c("PRINCE GEORGE A",
          "QUESNEL A",
          "FORT ST JAMES",
          "SMITHERS",
          "GRAND FORKS",
          "LYTTON 2",
          "GOLDEN A",
          "LUMBY")

# Extract stnIDs for stnList
stnID<-
  stn %>% 
  filter(station_name%in%stnList) %>% 
  dplyr::select(station_id)

# Download data  
dat<-
  weather_dl(station_ids=as.data.frame(stnID)[,1],interval="day",verbose=TRUE) 

# Format and clean data
X<-select(dat,stn=station_name,date,tmn=min_temp,tmx=max_temp,ppt=total_precip,year,month,day)
x1<-by(INDICES=X$stn,function(x) cleanECData(x),data=X)
x2<-dplyr::bind_rows(x1,.id="id")
x2$stn_name=names(x1)[as.numeric(x2$id)]

# some final formmating and assign to final variable
climData<-
  x2 %>% 
  dplyr::select(1:4,ppt=ppt_filled,tmx=tmx_filled,tmn=tmn_filled,stn_name=stn_name) %>% 
  left_join(select(stn,station_name,bgc=MAP_LABEL),by=c("stn_name"="station_name")) %>% 
  left_join(select(filter(stations,interval=="day"),station_name,lat,lon,elev),by=c("stn_name"="station_name"))
  mutate(date=lubridate::ymd(year,month,day)) %>% 
    mutate(year=as.integer(year),
          month=as.integer(month),
          day=as.integer(day))
  
# save dataset 
save(climData,file="data-raw/climDataCleaned.RData")

# write csv for ClimateBC
climData %>% 
  group_by(stn_name) %>% 
  summarise(ID1=first(stn_name),
            ID2=first(bgc),
            lat=first(lat),
            long=first(lon),
            el=first(elev)) %>% 
  dplyr::select(-stn_name) %>% 
  write.csv(file="data-raw/stnFile.csv",row.names = F)
