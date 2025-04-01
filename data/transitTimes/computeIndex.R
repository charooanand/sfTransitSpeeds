
blocks <- st_read("data/rawData/getBlockShape/blocksCentroid.shp") %>%
  mutate(block_long = st_coordinates(geometry)[, 1],
         block_lat = st_coordinates(geometry)[, 2]) %>% 
  st_drop_geometry()

odTbl <-  expand.grid(
  origin_idx = 1:nrow(blocks),
  dest_idx = 1:nrow(blocks)) %>%
  mutate(
    o_GEOID = blocks$GEOID[origin_idx],
    o_long = blocks$block_long[origin_idx],
    o_lat = blocks$block_lat[origin_idx],
    d_GEOID = blocks$GEOID[dest_idx],
    d_long = blocks$block_long[dest_idx],
    d_lat = blocks$block_lat[dest_idx]
  ) %>%
  select(o_GEOID, o_long, o_lat,
         d_GEOID, d_long, d_lat) 

##############################
# add straight line distance #
##############################

straightLineDist <- odTbl %>% 
  mutate(straightLineDist = distHaversine(cbind(o_long, o_lat), 
                                          cbind(d_long, d_lat)),
         straightLineKm = straightLineDist/1000,
         straightLineMiles = straightLineKm*0.6214) %>% 
  select(o_GEOID, d_GEOID, straightLineMiles) %>%
  as_tibble()


####################
# add transit time #
####################

source('data/transitTimes/getTransitTimesFunction.R')

odBlocks <- blocks %>%
  rename(id = GEOID,
         lon = block_long,
         lat = block_lat)

transitTimes <- lapply(1:nrow(departureTimes),
                       function(n) 
                       getTransitTime(odBlocks, 
                                      odBlocks, 
                                      departureTimes[n,])) %>%
                reduce(full_join)

#################
# compute index #
#################

index <- transitTimes %>% 
  filter(o != d) %>% 
  rename("o_GEOID" = "o", "d_GEOID" = "d") %>% 
  left_join(straightLineDist, by = c("o_GEOID", "d_GEOID")) %>% 
  mutate(meanTransitTime = rowMeans(across(starts_with("transitTime"))),
         meanMph = straightLineMiles / (meanTransitTime / 60)) %>% 
  group_by(o_GEOID) %>% 
  summarise(mphIndex = mean(meanMph),
            meanTime = mean(meanTransitTime)) %>% 
  rename("GEOID" = "o_GEOID")

write_csv(index, "data/transitTimes/index.csv")
