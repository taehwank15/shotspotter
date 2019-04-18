library(tidyverse)
library(tidycensus)
library(sf)

# Validate

census_api_key("92c13151737fd67fa744a0c0316d27b4a4c8caa2", install = TRUE)

data <- read_csv("http://justicetechlab.org/wp-content/uploads/2017/08/OakShots_latlong.csv",
                 col_names= cols(
                   OBJECTID = col_double(),
                   CAD_ = col_character(),
                   BEAT = col_character(),
                   DATE___TIM = col_character(),
                   ADDRESS = col_character(),
                   CALL_ID = col_character(),
                   DESCRIPTIO = col_character(),
                   Xrough = col_double(),
                   Yrough = col_double(),
                   XCOORD = col_double(),
                   YCOORD = col_double()
                 ))

# Turn df into shape file

# east_paloalto <- st_as_sf(data)
