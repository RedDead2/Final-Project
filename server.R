#Packages 
library(dplyr)
library(shiny) 
library(rsconnect)
library(ggplot2)
library(tidyverse)
library(sf)
library(tmap)
library(classInt)
library(leaflet)
library(rgdal)

#Data
acsdata <- read.csv("ACS_17_5YR_S1301/ACS_17_5YR_S1301_with_ann.csv")
Kingshp <- st_read("Kingshapefile/2010_Census_Tracts_for_King_County__Conflated_to_Parcels__Major_Waterbodies_Erased__tracts10_shore_area.shp")
Pierceshp <- st_read("piercewgs84/pierceCountwgs84.shp")

#Data Aggregation 
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
    
    
#Selects Shape File and Coordinataes     
    if(input$County == "King County") {
      Shapefile <- Kingshp
      name <- "King County"
      LNG <- -121.9836
      LAT <- 47.5480
      
    } else if (input$County == "Pierce County") {
      Shapefile <- Pierceshp 
      name <- "Pierce County"
      LNG <-  -122.1295
      LAT <- 47.0676
    } else {
      
    }
    
#Selects Columns   
    if(input$data == "15 to 50 years per 1000") {
      selectcol <- "HC04_EST_VC01"
      fileandcol <- "Shapefile$HC04_EST_VC01"
      Legend_title <- "15 to 50 years per 1000"
    } else if(input$data == "NATIVITY - Foreign born per 1000") {
      selectcol <- "HC04_EST_VC21"
      fileandcol <- "Shapefile$HC04_EST_VC21"
      Legend_title <- "NATIVITY - Foreign born per 1000"
    } else if (input$data == "NATIVITY - Native per 1000") {
      selectcol <- "HC04_EST_VC20"
      fileandcol <- "Shapefile$HC04_EST_VC20"
      Legend_title <- "NATIVITY - Native per 1000"
    } else {
      selectcol <- "HC04_EST_VC24"
      fileandcol <- "Shapefile$HC04_EST_VC24"
      Legend_title <- "EDUCATIONAL ATTAINMENT - Less than high school graduate per 1000"
    }
 
  # Select Static or Interactive    
    if(input$Type == "Static") {
      style <-  tmap_mode("plot") +
        tm_shape(Shapefile) + tm_fill(col= selectcol, title = Legend_title) + tmap_options(max.categories = 6) + tm_borders() + tm_layout(aes.palette = list(seq = "-RdYlGn"), title = name, title.position = c("LEFT", "TOP")) 
    } else {
      bins <- c(0, 10, 20, 50, 100, 200, 500, 1000)
      pal <- colorBin("YlOrRd", bins = bins)
      style <- output$mymap <- renderLeaflet({
        dmap <- leaflet()  %>% addTiles() %>% 
          setView(lng = LNG, lat= LAT, zoom=9) %>% 
          addPolygons(data=Shapefile, fillColor = ~pal(get(selectcol)), weight = 2,
                      opacity = 1,
                      color = "white",
                      dashArray = "3",
                      fillOpacity = 0.7) %>% 
          addLegend(pal = pal, values = selectcol, opacity = 0.7, title = Legend_title,
                    position = "bottomright")
        
         
        dmap
      })
    }
    
    
# Creates Maps 
    style
    
    
  }) 
})