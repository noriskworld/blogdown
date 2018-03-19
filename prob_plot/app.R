#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Lognormal vs Weibull - PDF"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        sliderInput("sdlog", 
                    label = "Lognormal - SD Log",
                    min = 0, max = 5, value = 1, step = 0.1),
        sliderInput("meanlog", 
                    label = "Lognormal - Mean Log",
                    min = -5, max = 5, value = 0, step = 0.2),
        sliderInput("scale", 
                    label = "Weibull - Scale",
                    min = 0, max = 5, value = 1, step = 0.1),
        sliderInput("shape", 
                    label = "Weibull - Shape",
                    min = 0, max = 5, value = 1, step = 0.1)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      ),
      tags$head(
        tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                    type="text/javascript")
      ),
      HTML('<div data-iframe-height></div>')
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
     len = 100
     x0 <-  seq(0, 5, length.out = len)
     df <- tibble(x = rep(x0,2), 
                  pdf = c(dlnorm(x0, meanlog = input$meanlog, sdlog = input$sdlog), 
                          dweibull(x0, shape = input$shape, scale = input$scale)),
                  dis_type = c(rep("Log Normal", len), rep("Weibull", len)))
     p <- ggplot(df) + geom_line( aes( y = pdf, x = x, color = dis_type))
     print(p)
     })
}

# Run the application 
shinyApp(ui = ui, server = server)

