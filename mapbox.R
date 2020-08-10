
# Packages needed ---------------------------------------------------------

library(tidyverse)
library(mapdeck)
library(sf)
library(tigris)

# Before you get started --------------------------------------------------

# Download tippecanoe by running the following in terminal: `brew install tippecanoe`. if you dont have homebrew on your computer go here: https://brew.sh
# install mapboxapi

remotes::install_github("walkerke/mapboxapi")

# Go to mapbox and sign up for an account. Get your access token from your Mapbox account and save it in R; save a public token,
# secret token, or both with successive calls to mb_access_token()
mapboxapi::mb_access_token("pk.eyzdl....", install = TRUE)


# Data and tippecanoe -----------------------------------------------------

# NYT data
nyt <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv") %>%
  filter(date == "2020-08-01") %>% # just going to focus on one date
  drop_na(fips) %>%
  rename(GEOID = fips)

# Joining NYT to US county geometries
nyt_geo <- tigris::counties(class = "sf") %>%
  select(GEOID, geometry) %>%
  geo_join(nyt, by_sp = "GEOID", by_df = "GEOID")

# tippecanoe'ing the geometries
tippecanoe(
  input = nyt_geo,
  output = "uscounty.mbtiles",
  layer_name = "uscounty_polygons") # this might take a little while!

# upload these as tiles on mapbox
upload_tiles(input = "uscounty.mbtiles",
             username = "YOUR_USERNAME", # use your own username here
             tileset_id = "uscounty_polygons",
             multipart = TRUE)

# Go to mapbox now and look at your styles

# Bring it back to R

mapdeck(token = Sys.getenv("MAPBOX_PUBLIC_TOKEN"),
        style = "mapbox://styles/atoumi/ckddsbc903xey1io2y1nxiowx",
        zoom = 6,
        location = c(-98.7382803, 31.7678448)) # if it doesn't show up in your viewer, view in browser

# Now you can deploy to shiny using mapdeckOutput() in the UI and renderMapdeck() in the server!
