# Packages 
library(dplyr)
library(shiny) 
library(rsconnect)
library(ggplot2)
library(tidyverse)
library(sf)
library(tmap)

# Data and shp
acsdata <- read.csv("ACS_17_5YR_S1301/ACS_17_5YR_S1301_with_ann.csv")
Kingshp <- st_read("Kingshapefile/2010_Census_Tracts_for_King_County__Conflated_to_Parcels__Major_Waterbodies_Erased__tracts10_shore_area.shp")
Pierceshp <- st_read("Pierce_county_shapefile/2010_Census_Tracts.shp")

acsdata <- acsdata[-(1:n), , drop = FALSE]

acsdata <- select(acsdata, "HC04_EST_VC04", "HC04_EST_VC21", "HC04_EST_VC20", "HC04_EST_VC24", "GEO.id", "GEO.id2", "GEO.display.label")

acsdata$GEO.id3 <- as.character(acsdata$GEO.id2)
acsdata$GEO.id3 <- substr(acsdata$GEO.id3, 0, 5)

King <- filter(acsdata, GEO.id3 == '53033') 
Pierce <- filter(acsdata, GEO.id3 == '53053')

Kingshp$GEO.id2 = Kingshp$GEO_ID_TRT
Pierceshp$GEO.id2 = Pierceshp$GEOID10
Pierceshp$GEO.id2 <- substr(Pierceshp$GEO.id2, 0, 11)

Kingshp <- merge(Kingshp, King, by="GEO.id2")
Pierceshp <- merge(Pierceshp, Pierce, by="GEO.id2")


shinyServer(function(input, output) {
  output$Counties <- renderPlot({
  
    if(input$data == "HC04_EST_VC04") {
      plot <- "HC04_EST_VC04"
      Legend_title <- "Women with births in the past 12 months - Rate per 1,000 women; Estimate; 35 to 50 years"
    } else if(input$data == "HC04_EST_VC21") {
      plot <- "HC04_EST_VC21"
      Legend_title <- "Women with births in the past 12 months  - Rate per 1,000 women; Estimate; NATIVITY - Foreign born"
    } else if (input$data == "HC04_EST_VC20") {
      plot <- "HC04_EST_VC20"
      Legend_title <- "Women with births in the past 12 months  - Rate per 1,000 women; Estimate; NATIVITY - Native"
    } else {
      plot <- "HC04_EST_VC24"
      Legend_title <- "Women with births in the past 12 months - Rate per 1,000 women; Estimate; EDUCATIONAL ATTAINMENT - Less than high school graduate"
    }
    
    # King County Map
    tm_shape(Kingshp) + tm_fill(col= plot, 
                                breaks = c(0, 20, 40, 60, 80, 100, 120, 140), 
                                #palette = c("red", "orange", "yellow", "blue", "white", "turquoise"), 
                                title = Legend_title) + tm_borders() + tm_layout(aes.palette = list(seq = "-RdYlGn"), title = "King County ", title.position = c("RIGHT", "TOP")) 
  })
})