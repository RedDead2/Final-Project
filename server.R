# Packages 
library(dplyr)
library(shiny) 
library(rsconnect)
library(ggplot2)
library(tidyverse)
library(sf)
library(tmap)
library(classInt)
library(leaflet)

# Data and shp
acsdata <- read.csv("ACS_17_5YR_S1301/ACS_17_5YR_S1301_with_ann.csv")
Kingshp <- st_read("Kingshapefile/2010_Census_Tracts_for_King_County__Conflated_to_Parcels__Major_Waterbodies_Erased__tracts10_shore_area.shp")
Pierceshp <- st_read("Pierce_county_shapefile/2010_Census_Tracts.shp")

n <- 1 
acsdata <- acsdata[-(1:n), , drop = FALSE]

acsdata <- select(acsdata, "HC04_EST_VC01", "HC04_EST_VC21", "HC04_EST_VC20", "HC04_EST_VC24", "GEO.id", "GEO.id2", "GEO.display.label")

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
    
    if(input$data == "15 to 50 years") {
      selectcol <- "HC04_EST_VC01"
      Legend_title <- "15 to 50 years"
    } else if(input$data == "NATIVITY - Foreign born") {
      selectcol <- "HC04_EST_VC21"
      Legend_title <- "NATIVITY - Foreign born"
    } else if (input$data == "NATIVITY - Native") {
      selectcol <- "HC04_EST_VC20"
      Legend_title <- "NATIVITY - Native"
    } else {
      selectcol <- "HC04_EST_VC24"
      Legend_title <- "EDUCATIONAL ATTAINMENT - Less than high school graduate"
    }
    
    if(input$County == "King County") {
      Shapefile <- Kingshp
      name <- "King County"
      
    } else {
      Shapefile <- Pierceshp 
      name <- "Pierce County"
    }
    
    if(input$Type == "Static") {
      style <-  tmap_mode("plot") +
                    tm_shape(Shapefile) + tm_fill(col= selectcol, title = Legend_title) + tmap_options(max.categories = 6) + tm_borders() + tm_layout(aes.palette = list(seq = "-RdYlGn"), title = name, title.position = c("LEFT", "TOP")) 
    } else {
      style <- output$mymap <- renderLeaflet({
        dmap <- leaflet()  %>% addTiles() %>% 
          setView(lng = -121.9836, lat=47.5480, zoom=9) %>% 
          addPolygons(data=Shapefile, fillColor = ~pal(as.numeric(Shapefile$selectcol)), weight = 2,
                      opacity = 1,
                      color = "white",
                      dashArray = "3",
                      fillOpacity = 0.7) %>% 
          addLegend(pal = pal, values = Shapefile$selectcol, opacity = 0.7, title = NULL,
                    position = "bottomright")
        
        
        dmap
      })
  } 
    # King County Map
    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000)
    pal <- colorBin("YlOrRd", domain = Shapefile$selectcol, bins = bins)
    style
   
     
}) 
})

