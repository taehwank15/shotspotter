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
  
  # Change DATE___TIM so that time is not a factor
  
  mutate(DATE___TIM = mdy_hm(DATE___TIM)) %>% 
  mutate(DATE___TIM = date(DATE___TIM))

# Turn Oakland data into shape file, sampling only 500 points to speed up render time

shot_locations <- st_as_sf(oakland_shots, coords = c("XCOORD", "YCOORD"), crs = 4326) %>% 
  sample_n(500)


# Create map of urban areas, focusing in on Oakland

raw_shapes <- urban_areas(class = "sf")

shapes <- raw_shapes %>% 
  filter(NAME10 == "San Francisco--Oakland, CA")



# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  navbarPage("Shotspotter Data",
    tabPanel("Map",
    # Sidebar with a slider inputs for start date and end date 
      sidebarLayout(
        sidebarPanel(
          h6("We decided to use a sample size of 500 so that rendering doesn't take too long"),
          
          # Place where user can select date range
          
          dateRangeInput(inputId = "dateRange",
                         label = "Date Range:",
                         min = min(shot_locations$DATE___TIM),
                         start = median(shot_locations$DATE___TIM),
                         end = max(shot_locations$DATE___TIM),
                         format = "yyyy-mm-dd",
                         startview = "month",
                         weekstart = 0,
                         separator = " to "),
          
          # Add action button to update map
          
          actionButton(inputId = "update_plot",
                       label = "Update plot")
          
        ),
        
        # Show a plot of the generated map
        
        mainPanel(
          plotOutput("distPlot")
        )
      )
    ),
    
    # Navbar tab to show github repo and credit thank justicetechlab
    
    tabPanel("About",
             mainPanel(
               h4("We would like to thank the Justice Tech Lab for making this amazing data available to us. All their data can be seen at: "),
               a("http://justicetechlab.org/shotspotter-data/"),
               h4("Our github repository can be seen at: "),
               a("https://github.com/taehwank15/shotspotter")
             ))
  )
)

# Define server logic required to animate map

server <- function(input, output) {
  
  # Creates a new reactive expression to update the date range only when button pressed
  
  new_date_range <- eventReactive(
    eventExpr = input$update_plot,
    valueExpr = input$dateRange,
    ignoreNULL = FALSE
  )
  
  output$distPlot <- renderImage({
    
    # Sets up an gif output 
    
    outfile <- tempfile(fileex='.gif')
    
    # Filter for dates matching input start and end
    
    filtered_shots <- shot_locations %>% 
      filter(DATE___TIM >= new_date_range()[1]) %>%
      filter(DATE___TIM <= new_date_range()[2]) %>% 
      filter(is.na(DATE___TIM) == FALSE)
    
    # Create gif of daily shooting patterns in Oakland
    
    p = ggplot(data = shapes) +
      geom_sf() +
      geom_sf(data = filtered_shots) +
      theme_map() +
      transition_time(filtered_shots$DATE___TIM) +
      labs(title = "Daily Shooting Patterns in Oakland, CA",
           subtitle = "Date: {frame_time}",
           caption = "Data Source: Justice Tech Lab")
    
    anim_save("outfile.gif", animate(p))
    
    list(src = "outfile.gif",
         contentType = 'image/gif'
    )
    
  }, deleteFile = TRUE)
}

# Run the application 
shinyApp(ui = ui, server = server)


