# Packages 
library(shiny)
library(leaflet)

# Creates Widgets for Maps 
shinyUI(fluidPage(
  sidebarLayout(sidebarPanel(selectInput(
    inputId = "data", label = "Categories:", 
    choices = c("15 to 50 years per 1000", "NATIVITY - Foreign born per 1000", "NATIVITY - Native per 1000", "EDUCATIONAL ATTAINMENT - Less than high school graduate per 1000"),
    selected = "15 to 50 years per 1000"), 
    radioButtons(inputId = "County", label = "Select County:", 
                 choices = c("King County", "Pierce County"), 
                 selected = "King County"),
    radioButtons(inputId = "Type", label = "Select Interactive or Static:", 
                 choices = c("Interactive", "Static"), 
                 selected = "Static")
  ),
  #Displays the Maps                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
  mainPanel(plotOutput("Counties", width = 600, height = 600), leafletOutput("mymap")
  )
  )
)
)
