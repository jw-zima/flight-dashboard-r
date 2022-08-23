library(shiny)
library(shinythemes)
library(shinydashboard)

ui <- dashboardPage(
    skin = "blue",
    
    dashboardHeader(
        title = "2019 US flights"
    ),
    
    dashboardSidebar(
        sidebarMenu(
            id = "navbar",
            
            menuItem("Info", tabName = "tabInfo",
                     icon = icon("info-sign", lib = "glyphicon")),
            
            menuItem("Key statistics", tabName = "tabStats",
                     icon = icon("plane", lib = "glyphicon")
            ),
            
            conditionalPanel(
                'input.navbar == "tabStats"',
                selectInput("tabStatsSelect", "Select statistic:",
                            choices = list("Number of flights",
                                           "Share of flights delayd by >= 15 min",
                                           "Share of flights delayd by >= 60 min",
                                           "Share of flights delayd by >= 180 min",
                                           "Average delay length",
                                           "Average arrival tiem difference"
                            ),
                            selected = "Number of flights"
                )
            ),
            
            menuItem("Routes", tabName = "tabRoutes",
                     icon = icon("globe", lib = "glyphicon")),
            
            conditionalPanel(
                'input.navbar == "tabRoutes"',
                sliderInput("tabRoutesSlider", "Top most freuent routes: ", 1, 100, 10)
            ),
            
            menuItem("Airports", tabName = "tabAirports",
                     icon = icon("map-marker", lib = "glyphicon")),
            
            conditionalPanel(
                'input.navbar == "tabAirports"',
                sliderInput("tabAirportsSlider", "Top most delayed airports: ", 1, 100, 10)
            ),
            
            menuItem("Delays", tabName = "tabDelays",
                     icon = icon("time", lib = "glyphicon")
            ),
            
            conditionalPanel(
                'input.navbar == "tabDelays"',
                selectInput("tabDelaysSelect", "Select airline:",
                            choices = list("Overall" = "Overall",
                                           "Delta" = "Delta"
                            ),
                            selected = "Overall"
                )
            )
        )
    ),
    
    dashboardBody(
        fluidRow(
            valueBoxOutput("kpiAirlines"),

            valueBoxOutput("kpiRoutes"),

            valueBoxOutput("kpiFlights")
        ),
        
        fluidRow(
            valueBoxOutput("kpiDelayed15"),

            valueBoxOutput("kpiDelayed60"),

            valueBoxOutput("kpiDelayed180")
        ),
        
        tabItems(
            tabItem(tabName = "tabInfo",
                    h2("Info tab content")
            ),
            
            tabItem(tabName = "tabStats",
                    h2("Stats tab content"),
                    textOutput("tabStatsSelected")
            ),
            
            tabItem(tabName = "tabRoutes",
                    h2("Routes tab content")
            ),
            
            tabItem(tabName = "tabAirports",
                    h2("Airports tab content")
            ),
            
            tabItem(tabName = "tabDelays",
                    h2("Delays tab content"),
                    dataTableOutput("testTable")
            )
        )
    )
)