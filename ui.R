
# Emmanuel Robi 

# Packages 
library(shiny)
library(leaflet)

# Pages Title
shinyUI(fluidPage(
  sidebarLayout(sidebarPanel(selectInput(
    inputId = "data", label = "Columns:", 
    choices = c("15 to 50 years", "NATIVITY - Foreign born", "NATIVITY - Native", "EDUCATIONAL ATTAINMENT - Less than high school graduate"),
    selected = "15 to 50 years"), 
    radioButtons(inputId = "County", label = "Select County:", 
                 choices = c("King County", "Pierce County"), 
                 selected = "King County"),
    radioButtons(inputId = "Type", label = "Select Interactive or Static:", 
                 choices = c("Interactive", "Static"), 
                 selected = "Interactive")
  ),
  # Displays the plot
  mainPanel(plotOutput("Counties", width = 400, height = 400), leafletOutput("mymap")
  )
  )
)
)
