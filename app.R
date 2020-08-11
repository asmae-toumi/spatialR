# Packages ----------------------------------------------------------------

library(tidyverse)
library(janitor)
library(albersusa)
library(sf)
library(tigris)
library(r2d3maps)
library(rmapshaper)
library(shiny)
library(shinycssloaders)

# County geometries -------------------------------------------------------

cty_sf <- counties_sf("longlat") # from albersusa package 
plot(st_geometry(cty_sf)) # checking geometries, looks good
cty_sf <- ms_simplify(cty_sf) # make the geometries simpler for faster rendering 


# Data ---------------------------------------------------------------------

# CDC's social vulnerability index variables: https://svi.cdc.gov/Documents/Data/2018_SVI_Data/SVI2018Documentation.pdf

svi <- read_csv("svi_county.csv") %>% 
  clean_names() %>% # make everything snake_case
  filter(across(where(is.numeric), ~. >= 0)) # because NA's are coded as -Inf

# join data to geometries
cty_sf_joined <- cty_sf %>% geo_join(svi, by_sp = "fips", by_df = "fips")

# UI ----------------------------------------------------------------------

ui <- navbarPage("Fun with r2d3map", id="nav", 

                 tabPanel(
                   "Interactive map",
                   withSpinner(d3Output(outputId = "mymap", width = "900px", height = "500px"))),
                 
                 tabPanel("Explore the data",
                          DT::dataTableOutput("table"))
)


# Server ------------------------------------------------------------------

server <- function(input, output) {
  
<<<<<<< HEAD

=======
>>>>>>> e2c655e3dafb73b1378e20e4a7d7bb0c159414e5
  # map panel 
  output$mymap <- renderD3({
    d3_map(shape = cty_sf_joined, projection = "Albers") %>%
      add_labs(caption = "Viz: Asmae Toumi | Data: CDC") %>% 
      add_continuous_breaks(var = "rpl_theme1", palette = "Reds") %>%
      add_legend(title = "Socioeconomic Vulnerability (percentile)") %>%
      add_tooltip("<b>{location}</b>: {rpl_theme1}")
  })
  
  # data panel
  output$table <- DT::renderDataTable({
     DT::datatable(svi, rownames = F,  filter = 'top',
                  extensions = c('Buttons', 'FixedHeader', 'Scroller'),
                  options = list(pageLength = 15, lengthChange = F,
                                 fixedHeader = TRUE,
                                 dom = 'lfBrtip',
                                 list('copy', 'print', list(
                                   extend = 'collection',
                                   buttons = c('csv', 'excel', 'pdf'),
                                   text = 'Download'
                                 ))
                  ))
  })
  
}

shinyApp(ui = ui, server = server)


