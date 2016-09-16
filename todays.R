install.packages("maps")
library(maps)
library(ggplot2)

plot(all_states)


all_states <- map_data("state")
all_states

install.packages("maptools")
library(maptools)

library(rgdal)

(states <- readOGR("../cb_2015_us_state_500k",
                       "cb_2015_us_state_500k"))

terr<- c("AS", "PR", "VI", "GU", "HI", "AK", "MP")                            
noterr<- states[!(states[["STUSPS"]] %in% terr),]
plot(noterr)
                
                