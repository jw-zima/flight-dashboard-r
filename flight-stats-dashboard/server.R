library(shiny)
library(readr)

# df <- read_rds("../data/processed/tb_flights_2019_filtered.rds")

shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # # generate bins based on input$bins from ui.R
        # x    <- faithful[, 2]
        # bins <- seq(min(x), max(x), length.out = input$bins + 1)
        # 
        # # draw the histogram with the specified number of bins
        # hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
    
    output$testTable <- renderDataTable({
        head(iris, 4)
    })
    
    output$kpiAirlines <- renderValueBox({
        valueBox(
            "11", "# airlines", icon = icon("plane", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiRoutes <- renderValueBox({
        valueBox(
            "111", "# routes", icon = icon("globe", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiFlights <- renderValueBox({
        valueBox(
            "999999", "# flights", icon = icon("transfer", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiDelayed15 <- renderValueBox({
        valueBox(
            paste0(round(100 * (1 - 0.2),1),"%"), "flights on time, i.e. delayed < 15min", icon = icon("thumbs-up", lib = "glyphicon"),
            color = "green"
        )
    })
    
    output$kpiDelayed60 <- renderValueBox({
        valueBox(
            "12%", "flights delayed > 60min", icon = icon("hand-right", lib = "glyphicon"),
            color = "yellow"
        )
    })
    
    output$kpiDelayed180 <- renderValueBox({
        valueBox(
            "2%", "flights delayed > 180min", icon = icon("thumbs-down", lib = "glyphicon"),
            color = "red"
        )
    })
    
    output$tabStatsSelected <- renderText({
        paste0("You have selected: ", input$tabStatsSelect)
    })

})
