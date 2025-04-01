r5r_core <- setup_r5("data/rawData/r5rInputs")

departureTimes <- vroom("data/rawData/departureTimes/departureTimes.csv")

getTransitTime <- function(origins, destinations, departureTime){
  
  transitTimeVarName <- paste0("transitTime", departureTime$TIMEID)
  timeStamp <-  departureTime$timeStamp
  
  ttm <- travel_time_matrix(
    r5r_core,
    origins = origins,
    destinations = destinations,
    mode = c("WALK", "TRANSIT"),
    departure_datetime = as.POSIXct(timeStamp),
    max_trip_duration = 360,
    verbose = TRUE) %>% 
    as_tibble() %>% 
    rename(o = from_id,
           d = to_id) %>% 
    mutate(!!transitTimeVarName := travel_time_p50) %>%
    select(-travel_time_p50)
  
  return(ttm)
  
}