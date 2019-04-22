#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Shotspotter Data"),
   
   # Sidebar with a slider inputs for start date and end date 
   sidebarLayout(
      sidebarPanel(
         dateRangeInput(inputId = "dateRange",
                     label = "Date Range:",
                     start = min(data$DATE___TIM),
                     end = max(data$DATE___TIM),
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
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

