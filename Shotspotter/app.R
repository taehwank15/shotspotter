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
library(gganimate)

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
                     separator = " to "),
      
      # have user enter the number of data points they want to show up on plot
      numericInput(inputId = "sample_size",
                   label = "Sample Size",
                   value = 15,
                   min = 1),
      
      # add action button to update graph
      actionButton(inputId = "update_plot",
                   label = "Update plot")
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # creates a new reactive expression to update the date range
  new_date_range <- eventReactive(
    eventExpr = input$update_plot,
    valueExpr = input$dateRange,
    ignoreNULL = FALSE
  )
  
  new_sample_size <- eventReactive(
    eventExpr = input$update_plot,
    valueExpr = input$sample_size,
    ignoreNULL = FALSE
  )
  
  output$distPlot <- renderPlot({
    
    # Filter for dates matching input start and end
    filtered_shots <- shot_locations %>% 
      filter(DATE___TIM >= new_date_range()[1]) %>%
      filter(DATE___TIM <= new_date_range()[2]) %>% 
      
      # filter for the user's selected sample size
      sample_n(new_sample_size())
    
    # draw the histogram with the specified number of bins
    ggplot(data = shapes) +
      geom_sf() +
      geom_sf(data = filtered_shots) +
      theme_map() +
      transition_time(filtered_shots$DATE___TIM)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)


