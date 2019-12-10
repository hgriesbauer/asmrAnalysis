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

dat %>% 
  
  # format climate data (see below for more information)
  select(stn=station_name,date,tmn=min_temp,tmx=max_temp,ppt=total_precip,year,month,day)
  


