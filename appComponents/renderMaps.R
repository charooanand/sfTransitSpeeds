########
# data #
########

blockData <- vroom("data/rawData/getBlockShape/blocksData.csv")

blockShape <- st_read("data/rawData/getBlockShape/blocksShape.shp") %>% 
  full_join(blockData, by = "GEOID")

index <- vroom("data/transitTimes/index.csv") %>% 
  full_join(blockShape) %>% 
  st_as_sf()

poiMatrix <- vroom("data/transitTimes/poiMatrix.csv") %>% 
  full_join(blockShape) %>% 
  st_as_sf()

poiShape <- st_read("data/rawData/getPOIs/POIs.shp")

departureTimes <- vroom("data/rawData/departureTimes/departureTimes.csv")


###########
# poi map #
###########

poiIcon <- leaflet::makeIcon(
  iconUrl = "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-yellow.png",
  iconWidth = 25, iconHeight = 41,
  iconAnchorX = 12, iconAnchorY = 41
)


poiMap <- function(poi, time, outcome) {
  
  data <- poiMatrix %>%
    filter(POIID == poi) %>%
    select(GEOID, name, straightLineMiles, ends_with(toString(time))) %>%
    rename_with(~ gsub("\\d+$", "", .x)) %>% 
    filter(is.finite(.data[[outcome]]))
  
  pal <- colorNumeric(
    palette = "plasma",
    domain = as.numeric(data[[outcome]]))
  
  poiPoint <- poiShape %>% filter(POIID == poi)
  poiName <- poiPoint$poiName
  poiEmojis <- poiPoint$emojiNames %>%
    str_split(",") %>%
    unlist() %>%
    str_trim() %>%
    lapply(ji) %>%
    paste(collapse = "")
  
  departureTime <- departureTimes %>% filter(TIMEID == time)
  departureTimeDesc <- departureTime$desc

  
  legendTitle <- case_when(
    outcome == "transitTime" ~ "Travel Time (in Minutes)",
    outcome == "straightLineMiles" ~ "Distance (in Miles)",
    outcome == "mph" ~ "Effective Transit <br/> Speed (in MPH)"
  )
  
  outcomeUnit <- case_when(
    outcome == "transitTime" ~ "minutes",
    outcome == "straightLineMiles" ~ "miles",
    outcome == "mph" ~ "mph"
  )
  
  infoBox <- paste0(
    "<div style='
      background:#1e1e1e;
      color:#ffffff;
      padding:10px 15px;
      border-radius:6px;
      box-shadow:0 2px 6px rgba(255,255,255,0.1);
      font-size:14px;
      border: 1px solid #444444;
    '>
     <strong>Point of Interest:</strong> ", poiName, " ", poiEmojis, "<br/>
     <strong>Departure Time:</strong> ", departureTimeDesc, "
   </div>"
  )
  
  leaflet(data) %>%
    addProviderTiles("CartoDB.DarkMatter") %>%
    addPolygons(
      fillColor = ~pal(get(outcome)),
      fillOpacity = 0.7,
      color = "white",
      weight = 1,
      label = ~paste0(name, ": ", round(data[[outcome]], 2), " ", outcomeUnit),
      labelOptions = labelOptions(
        direction = "top",
        textsize = "13px"
      ),
      highlightOptions = highlightOptions(
        weight = 4,
        color = "white",
        fillOpacity = 1,
        bringToFront = TRUE
      )
    ) %>%
    addMarkers(
      data = poiPoint,
      icon = poiIcon
    ) %>%
    addLegend(
      pal = pal,
      values = data[[outcome]],
      title = HTML(paste0("<span style='color:white;'>", legendTitle, "</span>")),
      position = "bottomright"
    ) %>%
    addControl(
      html = infoBox,
      position = "topright"
    )
}


#############
# index map #
#############

indexMap <- function(whichIndex){

  labelInfo <- list(
    meanTime = list(
      title = "Average Transit Time <br/> (in Minutes)",
      unit = "mins",
      round_to = 0
    ),
    mphIndex = list(
      title = "Average Effective Transit <br/> Speed (in MPH)",
      unit = "mph",
      round_to = 2
    )
  )
  
  labelConfig <- labelInfo[[whichIndex]]
  
  # Create color palette
  pal <- colorNumeric(
    palette = "viridis",
    domain = index[[whichIndex]],
    reverse = TRUE
  )
  
  # Build Leaflet map
  leaflet(index) %>%
    addProviderTiles("CartoDB.DarkMatter") %>%
    addPolygons(
      fillColor = ~pal(get(whichIndex)),
      fillOpacity = 0.7,
      color = "white",
      weight = 1, 
      label = ~paste0(
        name, ": ",
        round(get(whichIndex), labelConfig$round_to), " ",
        labelConfig$unit
      ),
      labelOptions = labelOptions(
        direction = "top",
        textsize = "13px"
      ),
      highlightOptions = highlightOptions(
        weight = 4,
        color = "white",
        fillOpacity = 1,
        bringToFront = TRUE
      )
    ) %>%
    addLegend(
      pal = pal,
      values = ~get(whichIndex),
      title = labelConfig$title,
      position = "bottomright"
    )
}


