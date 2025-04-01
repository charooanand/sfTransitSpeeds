vars <- tribble(  
  ~varDesc, ~variable,  
  "totalUnits", "H003001",  
  "occupiedUnits", "H003002",    
  "vacantUnits", "H003003",      
  "whiteHouseholds", "H006002",  
  "renterOccupied", "H004004"    
)  

blocksRaw <- get_decennial(  
  geography = 'block group',  
  variables = vars$variable,  
  state = 'CA',  
  county = 'San Francisco',  
  geometry = T,  
  year = 2010  
) %>% st_transform("WGS84")




blocksClean <- st_drop_geometry(blocksRaw) %>% 
  full_join(vars, by = "variable") %>% 
  pivot_wider(
    id_cols = c(GEOID, NAME),
    names_from = varDesc,
    values_from = value
  ) %>% 
  mutate(
    vacancyShare = vacantUnits / totalUnits,
    whiteShare = whiteHouseholds / occupiedUnits,
    renterShare = renterOccupied / occupiedUnits,
    name = map_chr(NAME, ~ paste0(str_split(.x, ",")[[1]][1:2], collapse = ", "))
  ) %>% 
  select(-NAME) %>% 
  full_join(select(blocksRaw, GEOID)) %>% 
  st_as_sf() %>% 
  filter(
    totalUnits != 0,
    !(GEOID %in% c("060759804011", 
                   "060750601001", 
                   "060750179021", 
                   "060759803001"))
  ) %>% 
  distinct(GEOID, .keep_all = TRUE)


st_write(select(blocksClean, GEOID),
         "data/rawData/getBlockShape/blocksShape.shp",
         delete_dsn = T)

st_write(st_centroid(select(blocksClean, GEOID)),
         "data/rawData/getBlockShape/blocksCentroid.shp",
         delete_dsn = T)

write_csv(st_drop_geometry(blocksClean), 
          "data/rawData/getBlockShape/blocksData.csv")


 