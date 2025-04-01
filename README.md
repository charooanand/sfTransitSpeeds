# sfTransitSpeeds

🌉🚇 [SF Transit Speeds](https://charoo.shinyapps.io/sftransitspeeds/) is designed for SF residents, transit riders, and planners — anyone interested in how BART and MUNI’s network design shapes the transit accessibility landscape of San Francisco.

**Points of Interest:**  
How long does it take to reach POIs in San Francisco from different neighborhoods using BART and MUNI? Does travel time vary by time of day or day of the week? By combining journey time with straight-line distance, we can visualize the effective transit speed (in miles per hour) from each Census block group to various points of interest across the city.

**Index:**  
Which neighborhoods enjoy the fastest transit access to the rest of the city? For each Census block group, I estimate how long it takes to reach all other block groups at various times throughout the week. To measure overall accessibility, I calculate a simple average of these travel times — this becomes the **Time Index**. Naturally, centrally located areas tend to score better on this metric. I also create a complementary **Speed Index**, which averages the effective transit speeds instead of travel times, offering an alternative perspective on network performance.

---

**💽💻️ Built with open data, R, and Shiny**

This app is built using a suite of R packages tailored for spatial analysis and transportation data. I use [{tidyverse}](https://www.tidyverse.org/) and [{sf}](https://r-spatial.github.io/sf/) to manage and manipulate spatial data frames, and [{tidycensus}](https://walker-data.com/tidycensus/) to download Census geometries. To geocode points of interest (POIs), I rely on [{tidygeocoder}](https://jessecambon.github.io/tidygeocoder/), and for fast straight-line distance calculations, I use [{geosphere}](https://cran.r-project.org/package=geosphere). Transit network data comes from [GTFS](https://gtfs.org/) feeds provided by [SFMTA](https://www.sfmta.com/reports/gtfs-transit-data) and [BART](https://www.bart.gov/schedules/developers/gtfs). I also incorporate an OpenStreetMap base layer from [BBBike](https://download.bbbike.org/osm/bbbike/SanFrancisco/). Transit travel times are computed using [{r5r}](https://ipeagit.github.io/r5r/), which integrates GTFS and street network data for multimodal routing. Maps are rendered with [{leaflet}](https://rstudio.github.io/leaflet/), and the app itself is built and deployed using [{shiny}](https://shiny.posit.co/).
