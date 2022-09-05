library(shiny)
library(shinythemes)
library(shinydashboard)
library(plotly)
library(leaflet)

all_carriers <- list('OVERALL', 'Alaska Airlines', 'Allegiant Air', 'American Airlines',
                     'American Eagle Airlines', 'Atlantic Southeast Airlines', 'Comair',
                     'Delta Air Lines', 'Frontier Airlines', 'Hawaiian Airlines',
                     'JetBlue Airways', 'Mesa Airlines', 'Midwest Airlines',
                     'Pinnacle Airlines', 'SkyWest', 'Southwest Airlines',
                     'Spirit Airlines', 'United Airlines')
all_stats <- list("Number of flights",
                  "Number of routes",
                  "Percent of flights on time, i.e. delay <= 15 min",
                  "Share of flights delayd by >= 60 min",
                  "Share of flights delayd by >= 180 min",
                  "Average delay length [min]",
                  "Average arrival tiem difference [min]")

ui <- dashboardPage(
    skin = "blue",
    
    dashboardHeader(
        title = "2019 US flights"
    ),
    
    ###################################################################
    ############################## SIDEBAR ############################
    ###################################################################
    dashboardSidebar(
        sidebarMenu(
            id = "navbar",
            ###################### INFO TAB ######################
            menuItem("Info", tabName = "tabInfo",
                     icon = icon("info-sign", lib = "glyphicon")),

            ###################### KEY STATS TAB ######################
            menuItem("Key statistics", tabName = "tabStats",
                     icon = icon("plane", lib = "glyphicon")
            ),
            
            conditionalPanel(
                'input.navbar == "tabStats"',
                selectInput("tabStatsStatSelect", "Select statistic:",
                            choices = all_stats,
                            selected = "Number of flights"
                ),
                selectInput("tabStatsSelectCarrier", "Select airline:",
                            choices = all_carriers,
                            selected = "OVERALL"
                )
            ),
            
            ###################### ROUTES TAB ######################
            menuItem("Routes", tabName = "tabRoutes",
                     icon = icon("globe", lib = "glyphicon")),
            
            conditionalPanel(
                'input.navbar == "tabRoutes"',
                selectInput("tabRoutesStatsSelect", "Select statistic:",
                            choices = setdiff(all_stats, "Number of routes"),
                            selected = "Number of flights"
                ),
                selectInput("tabRoutesSelectCarrier", "Select airline:",
                            choices = all_carriers,
                            selected = "OVERALL"
                ),
                sliderInput("tabRoutesSlider", "Top routes to present: ", 1, 100, 25)
            ),
            
            ###################### AIRPORTS TAB ######################
            menuItem("Airports", tabName = "tabAirports",
                     icon = icon("map-marker", lib = "glyphicon")),
            
            conditionalPanel(
                'input.navbar == "tabAirports"',
                selectInput("tabAirportsStatsSelect", "Select statistic:",
                            choices = all_stats,
                            selected = "Number of flights"
                ),
                sliderInput("tabAirportsSlider", "Top airports to present: ", 1, 100, 25)
            ),
            
            ###################### DELAY TAB ######################
            menuItem("Delay reasons", tabName = "tabDelays",
                     icon = icon("time", lib = "glyphicon")
            ),
            
            conditionalPanel(
                'input.navbar == "tabDelays"',
                selectInput("tabDelaysSelect", "Select airline:",
                            choices = all_carriers,
                            selected = "OVERALL"
                )
            )
        )
    ),
    
    ###################################################################
    ############################## BODY ###############################
    ###################################################################
    
    dashboardBody(
        ###################### KPIs ###################### 
        fluidRow(
            valueBoxOutput("kpiAirlines"),

            valueBoxOutput("kpiRoutes"),

            valueBoxOutput("kpiFlights")
        ),
        
        fluidRow(
            valueBoxOutput("kpiOnTime"),

            valueBoxOutput("kpiDelayed60"),

            valueBoxOutput("kpiDelayed180")
        ),
        
        tabItems(
        ###################### INFO TAB ######################
            tabItem(tabName = "tabInfo",
                    h2("About"),
                    h3("Context"),
                    span("The app delivers summary statitics on "), strong("2019 US domestic traffic data "), 
                    span("and "), strong("on-time performance "),
                    span("of flights operated by large air carriers along with providing "),
                    strong("delay reasons."),
                    br(),
                    span("The dataset originally comes from two data souerces:"),
                    tags$li("the U.S. Department of Transportation's (DOT) Bureau of Transportation Statistics,"),
                    tags$li("OpenFlights data."),
                    h3("Author"),
                    strong("jw-zima"),
                    a("GitHub", href="https://github.com/jw-zima")
            ),
            
        ###################### KEY STATS TAB ######################
            tabItem(tabName = "tabStats",
                    h2("The most important statistics for each airline"),
                    
                    plotlyOutput("barplotStatByAirline"),
                    br(),
                    fluidRow(
                        splitLayout(
                        cellWidths = c("33%", "33%"),
                        plotlyOutput("barlotStatByMonth"),
                        plotlyOutput("barlotStatByWeekday"),
                        plotlyOutput("barlotStatByDaytime")
                        )
                    ),
                    br(),
                    plotlyOutput("lineplotStatByAirline")
                    
                    
            ),
        ###################### ROUTES TAB ######################
            tabItem(tabName = "tabRoutes",
                    h2("Top routes with the highest value of selected statictic"),
                    leafletOutput("mapRoutes"),
                    dataTableOutput("tableRoutes")
            ),
        
        ###################### AIRPORTS TAB ######################
            tabItem(tabName = "tabAirports",
                    h2("Top airports with the highest value of selected statictic"),
                    leafletOutput("mapAirports"),
                    dataTableOutput("tableAirports")
            ),
            
        ###################### DELAY TAB ######################
            tabItem(tabName = "tabDelays",
                    h2("Delay reasons and length"),
                    plotlyOutput("barplotDelayReasonByAirline"),
                    plotlyOutput("barplotDelayTimeByAirline")
            )
        )
    )
)