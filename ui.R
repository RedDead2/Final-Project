# Emmanuel Robi 

# Packages 
library(shiny)

# Pages Title
  shinyUI(fluidPage(
  sidebarLayout(sidebarPanel(selectInput(
    inputId = "data", label = "Columns:", 
    choices = c("HC04_EST_VC04", "HC04_EST_VC21", "HC04_EST_VC20", "HC04_EST_VC24"),
                                         selected = "HC04_EST_VC04")),
  # Displays the plot
  mainPanel(plotOutput("Counties")
            )
  )
  )
  )



   