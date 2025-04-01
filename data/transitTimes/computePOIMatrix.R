#################
# make od table #
#################

pois <- vroom("data/rawData/getPOIs/POIs.csv")

blocks <- st_read("data/rawData/getBlockShape/blocksCentroid.shp") %>%
  mutate(block_long = st_coordinates(geometry)[, 1],
         block_lat = st_coordinates(geometry)[, 2]) %>% 
  st_drop_geometry()

odTbl <-  expand.grid(
  origin_idx = 1:nrow(blocks),
  dest_idx = 1:nrow(pois)) %>%
  mutate(
    GEOID = blocks$GEOID[origin_idx],
    block_long = blocks$block_long[origin_idx],
    block_lat = blocks$block_lat[origin_idx],
    POIID = pois$POIID[dest_idx],
    poi_long = pois$poi_long[dest_idx],
    poi_lat = pois$poi_lat[dest_idx]
  ) %>%
  select(GEOID, block_long, block_lat,
         POIID, poi_long, poi_lat) 

##############################
# add straight line distance #
##############################

straightLineDist <- odTbl %>% 
  mutate(straightLineDist = distHaversine(cbind(block_long, block_lat), 
                                          cbind(poi_long, poi_lat)),
         straightLineKm = straightLineDist/1000,
         straightLineMiles = straightLineKm*0.6214) %>% 
  select(GEOID, POIID, straightLineMiles) %>%
  mutate(POIID = as.character(POIID)) %>% 
  as_tibble()

####################
# add transit time #
####################

source('data/transitTimes/getTransitTimesFunction.R')

origins <- blocks %>%
  rename(id = GEOID,
         lon = block_long,
         lat = block_lat)

destinations <- pois %>%
  rename(id = POIID,
         lon = poi_long,
         lat = poi_lat)

transitTimes <- lapply(1:nrow(departureTimes),
                function(n) 
                getTransitTime(origins, destinations, departureTimes[n,])) %>% 
                reduce(full_join)

#################
# join and save #
#################

df <- transitTimes %>% 
  rename("GEOID" = "o", "POIID" = "d") %>% 
  full_join(straightLineDist, by = c("GEOID", "POIID")) %>% 
  mutate(across(starts_with("transitTime"), 
                ~ straightLineMiles / (.x / 60), 
                .names = "mph{str_extract(.col, '\\\\d+')}"))

write_csv(df, "data/transitTimes/poiMatrix.csv")