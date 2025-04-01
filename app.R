source("setUp.R")
source("appComponents/renderMaps.R")
source("appComponents/inputLabels.R")

ui <- dashboardPage(
  dashboardHeader(title = "SF Transit Speeds"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(" Info", tabName = "landing", icon = icon("info-circle")),
      menuItem(" Points Of Interest", tabName = "poi", icon = icon("map-pin")),
      menuItem(" Index", tabName = "index", icon = icon("globe"))
    )
  ),
  
  dashboardBody(
    tags$head(
      includeCSS("www/styles.css")
    ),

    tabItems(
      
      # Landing page
      tabItem(tabName = "landing",
              fluidRow(
                box(
                  status = "primary",
                  width = 12,
                  HTML(paste(readLines("appComponents/landingText.html"), collapse = "\n"))
                )
              )
      ),
      
      tabItem(tabName = "poi",
              fluidRow(
                box(width = 3,
                    status = "info",
                    HTML(paste(readLines("appComponents/poiText.html"), collapse = "</br>")),
                    selectInput("poi", "Point of Interest", choices = NULL),
                    selectInput("time", "Departure Time", choices = NULL),
                    selectInput("outcome", "Displayed Measure", choices = NULL)
                ),
                box(width = 9,
                    leafletOutput("poiMap", height = 600) 
                )
              )
      ),
      

      tabItem(tabName = "index",
              fluidRow(
                box(width = 3,
                    status = "info",
                    HTML(paste(readLines("appComponents/indexText.html"), collapse = "\n")),
                    radioButtons("whichIndex", "", choices = indexChoices)
                ),
                box(width = 9,
                    leafletOutput("indexMap", height = 600) 
                )
              )
      )
    )
  )
)

server <- function(input, output, session) {
  
  observe({
    updateSelectInput(session, "poi", choices = poiChoices)
    updateSelectInput(session, "time", choices = departureChoices)
    updateSelectInput(session, "outcome", choices = outcomeChoices)
    updateRadioButtons(session, "whichIndex", choices = indexChoices, selected = "mphIndex")
  })
  
  
  output$poiMap <- renderLeaflet({
    poiMap(poi = input$poi, time = input$time, outcome = input$outcome)
  })
  
  
  output$indexMap <- renderLeaflet({
    indexMap(whichIndex = input$whichIndex)
  })
  
}

shinyApp(ui, server)