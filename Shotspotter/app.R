#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(tidycensus)
library(sf)
library(tigris)
library(ggthemes)
library(lubridate)
library(shiny)
library(tidyverse)

# Read in Oakland data from justicetechlab

oakland_shots <- read_csv("http://justicetechlab.org/wp-content/uploads/2017/08/OakShots_latlong.csv",
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

# Turn Oakland data into shape file

shot_locations <- st_as_sf(oakland_shots, coords = c("XCOORD", "YCOORD"), crs = 4326) %>% 
  sample_n(500)

# Create map of urban areas, focusing in on Oakland

raw_shapes <- urban_areas(class = "sf")

shapes <- raw_shapes %>% 
  filter(NAME10 == "San Francisco--Oakland, CA")



# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Shotspotter Data"),
   
   # Sidebar with a slider inputs for start date and end date 
   sidebarLayout(
      sidebarPanel(
         dateRangeInput(inputId = "dateRange",
                     label = "Date Range:",
                     min = min(shot_locations$DATE___TIM),
                     start = median(shot_locations$DATE___TIM),
                     end = max(shot_locations$DATE___TIM),
                     format = "yyyy-mm-dd",
                     startview = "month",
                     weekstart = 0,
                     separator = " to ")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
     
      # Filter for dates matching input start and end
      filtered_shots <- shot_locations %>% 
        filter(DATE___TIM >= input$dateRange[1]) %>%
        filter(DATE___TIM <= input$dateRange[2])
        
      
      # draw the histogram with the specified number of bins
      ggplot(data = shapes) +
        geom_sf() +
        geom_sf(data = filtered_shots) +
        theme_map()
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

