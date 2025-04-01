
##############
# POI Inputs #
##############

poiInputs <- st_read("data/rawData/getPOIs/POIs.shp") %>% 
  st_drop_geometry() %>% 
  select(POIID, poiName, emojiNames)

poiChoices <- setNames(as.character(poiInputs$POIID), poiInputs$poiName)

#########################
# Departure Time Inputs #
#########################

departureTimeInputs <- vroom("data/rawData/departureTimes/departureTimes.csv") 

departureChoices <- setNames(as.character(departureTimeInputs$TIMEID), departureTimeInputs$desc)

############
# outcomes # 
############

outcomeChoices <- setNames(
  c("transitTime", "straightLineMiles", "mph"),
  c("Travel Time (in Minutes)", "Distance (in Miles)", "Effective Transit Speed (in MPH)")
)

############
# outcomes # 
############

indexChoices <- setNames(
  c("meanTime", "mphIndex"),
  c("Time Index", "Speed Index")
)

