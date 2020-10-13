library(tigris)
library(tidyverse)

cty <- counties(cb = TRUE, resolution = "20m") %>% rename(fips = GEOID)

library(tidycensus)

us_county_income <- 
  get_acs(geography = "county", variables = "B19013_001") %>% 
  select(fips = GEOID, name = NAME, income = "estimate") %>% 
  drop_na()

cty <- cty %>% 
  geo_join(us_county_income, by_df = "fips", by_sp = "fips")

library(leaflet)
library(RColorBrewer)
library(htmltools)

pal <- colorNumeric("YlOrRd", domain = cty$income)

labels <- 
  sprintf(
    "<strong>%s</strong><br/> Income: %s $",
    cty$name, cty$income) %>% 
  lapply(htmltools::HTML)

leaflet(cty) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("CartoDB.PositronNoLabels") %>%
  addPolygons(
    fillColor = ~pal(income), 
    weight = 1,
    opacity = 1,
    color = "white",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 2,
      color = "#666",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal"),
      textsize = "15px",
      direction = "auto")) %>%
  addLegend(pal = pal,
            values = cty$income,
            position = "bottomright",
            title = "Income (5-year ACS)",
            labFormat = labelFormat(suffix = "$"),
            opacity = 0.8,
            na.label = "No data")