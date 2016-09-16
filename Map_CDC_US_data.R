#refers to script to update CDC data folder.
source("Update_CDC_Data.R")  

#load libraries
library(dplyr)
library(stringr)
library(maps)
library(rgdal)
library(tmap)

#change this line if you don"t have zika data in caps
#read CDC data into file (verion for most recent data file only, non automated)
cdc_data20160831 <- read.csv("../Zika_Data/United_States/CDC_Report/data/CDC_Report-2016-08-31.csv")

#create columns to seperate country and state
cdc_data20160831$location <- sapply(cdc_data20160831$location, as.character)
cdc_data20160831$location <- substr(cdc_data20160831$location, 15, nchar(cdc_data20160831$location))
cdc_data20160831$NAME <- cdc_data20160831$location
cdc_data20160831$NAME<- str_replace_all(cdc_data20160831$NAME, "[[_]]", " ")

## Broken ## Piped version overwriting location field
##cdc_data20160831$location <- sapply(cdc_data20160831$location, as.character) %>% substr(15, nchar(cdc_data20160831$location))

#seperating to build two new data frames for local and imported
cdc_data20160831_local <- filter(cdc_data20160831,data_field_code=="US0002")
cdc_data20160831_travel <- filter(cdc_data20160831,data_field_code=="US0001")

#joining build two new columns for local and imported
cdc_data20160831_joined <- cdc_data20160831_travel
cdc_data20160831_joined$local <- cdc_data20160831_local$value
cdc_data20160831_joinedmin <- filter(cdc_data20160831_joined, cdc_data20160831_joined$location_type == "state") 

##Squishing the shapes and the data
##append_data(shp, data, key.shp = NULL, key.data = NULL,
  ##          ignore.duplicates = FALSE, ignore.na = FALSE,
    ##        fixed.order = is.null(key.data) && is.null(key.shp))

##Building the states
states <- readOGR("cb_2015_us_state_500k",
                   "cb_2015_us_state_500k")

terr<- c("AS", "PR", "VI", "GU", "HI", "AK", "MP")                            
noterr<- states[!(states[["STUSPS"]] %in% terr),]
plot(noterr)

zikamapping831 <- merge(noterr, cdc_data20160831_joinedmin, sort = FALSE, by = "NAME")

##p <- qplot(long, lat, data = tomap, 
##           group= group,
##           fill = value,
##           geom = "polygon")

#mapping theZika data onto a map of the US with fill being the travel acquired case count by
##tmap_mode("view") ##changes plotting to leverage leaflet and plot over open street map
tmap_mode("plot") ##changes it back to normal plot mode
tm_shape(zikamapping831)+ #imports name of shape object
  tm_borders()+ #layers in the outlines of the polygon 
  tm_fill("value", title = "Imported Zika Cases", cex = 0.5)+
  tm_legend(legend.frame = TRUE, legend.outside = TRUE)+## = c("right", "bottom"))+ # specifying where to find the fill information
  tm_style_classic() +
  tm_bubbles(size = ("local"))+
  tm_text("value", size = 0.7) #puts amounts of imported cases


