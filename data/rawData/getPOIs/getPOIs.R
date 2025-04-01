

getCoords <- function(searchAddress){
  
  # using {geocoder}
  point <- geo(paste0("San Francisco ", searchAddress), 
               method = "osm") %>% 
           mutate(poiName = searchAddress) %>% 
           select(-address)
  
  pointShp <- st_as_sf(point,
                       coords = c("long", "lat"),
                       crs = "WGS84") %>% 
              cbind(select(point, -poiName))
  
  return(pointShp)
}

pois <- tribble(
  ~poiName,           ~emojiNames,
  "Financial District", "cityscape, briefcase, bank",
  "Ocean Beach",        "ocean, person_surfing, sunrise",
  "Chase Center",       "basketball, microphone, stadium",
  "Dolores Park",       "palm_tree, basket, sun_with_face",
  "Haight Ashbury",     "bear, rainbow, peace_symbol",
  "Ferry Building",     "ferry, classical_building, shallow_pan_of_food"
)


poiPointShape <- lapply(pois$poiName, getCoords) %>%
    reduce(rbind) %>%
    mutate(POIID = as.character(1:nrow(pois))) %>%
    rename(poi_long = long, poi_lat = lat) %>%
    select(POIID, poiName, poi_long, poi_lat) %>% 
    full_join(pois)
  

st_write(poiPointShape,
         "data/rawData/getPOIs/POIs.shp",
         delete_dsn = T)

write_csv(st_drop_geometry(poiPointShape), "data/rawData/getPOIs/POIs.csv")