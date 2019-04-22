library(tidyverse)
library(tidycensus)
library(sf)
library(tigris)
library(ggthemes)
library(lubridate)

# Validate

data <- read_csv("http://justicetechlab.org/wp-content/uploads/2017/08/OakShots_latlong.csv",
                 col_types = cols(
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
                 )) %>% 
    mutate(DATE___TIM = mdy_hm(DATE___TIM))

# Turn df into shape file

# east_paloalto <- st_as_sf(data)
# has data for all the urban areas, jut want data for oakland - filter
raw_shapes <- urban_areas(class = "sf")

shapes <- raw_shapes %>% 
  filter(NAME10 == "San Francisco--Oakland, CA")

shot_locations <- st_as_sf(data, coords = c("XCOORD", "YCOORD"), crs = 4326) %>% 
  sample_n(5)

ggplot(data = shapes) +
  geom_sf() +
  geom_sf(data = shot_locations) +
  theme_map()

shot_locations2 <- st_as_sf(data, coords = c("XCOORD", "YCOORD"), crs = 4326)

# animation ideas
# select an address, then show the shots fired at that address over time
# select a date range, then show the shots fired in oakland within that range


oakland_shots %>% 
  filter(DATE___TIM <=  "2008-04-16")


