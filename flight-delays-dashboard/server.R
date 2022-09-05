library(shiny)
library(readr)
library(tidyverse)
library(magrittr)
library(ggplot2)
library(plotly)
library(leaflet)
library(docstring)

# params to host in local network:
# options(shiny.host = '192.168.0.196')
# options(shiny.port = 8080)

#=========================== UDFs ==============================
map_stats_to_colnames <- function(input_string){
    #' Replace statistic name with the corresponding column name
    #' @description This function replaces statistic name with the corresponding column name
    #' @param input_string string with statistic name
    #' @usage map_stats_to_colnames(input_string)
    #' @return string representing column name referring to passed input_string
    #' @examples map_stats_to_colnames("Number of flights)
    case_when(
        input_string == "Number of flights" ~ "NB_FLIGHTS",
        input_string == "Number of routes" ~ "NB_ROUTES",
        input_string == "Percent of flights on time, i.e. delay <= 15 min" ~ "FLIGHTS_ON_TIME_PCT",
        input_string == "Share of flights delayd by >= 60 min" ~ "FLIGHTS_DEL_60_PCT",
        input_string == "Share of flights delayd by >= 180 min" ~ "FLIGHTS_DEL_180_PCT",
        input_string == "Average delay length [min]" ~ "AVG_ARRIVAL_TIME_DIFF_MIN",
        input_string == "Average arrival tiem difference [min]" ~ "AVG_DELAY_MIN"
    )
}

plot_barplot_stat_by_time <- function(df, stat, carrier, time_var) {
    #' Bar plot showing selected statistic for given carrier and time split.
    #' @description This function makes a plotly bar plot showing selected statistic for given carrier and time split.
    #' @param df data frame stroing summarised data
    #' @param stat string, name of selected column with statictics
    #' @param carrier string, name of selected airline
    #' @param time_var string, name of selected time split ("MONTH", "WEEKDAY", "DEP_DAY_TIME")
    #' @usage plot_barplot_stat_by_time(df, stat, carrier, time_var)
    #' @return bar plot rendered with ggplot and plotly 
    #' @examples plot_barplot_stat_by_time(df = dashboard_data_airlines_MONTH,
    # stat = "NB_FLIGHTS", carrier = "OVERALL, time_var = "MONTH")
    time_var_cleaned <- ifelse(time_var == "DEP_DAY_TIME",
                               "Departure day time",
                               str_to_title(time_var))
    df %>%
        filter(CARRIER_NAME == carrier) %>%
        select(time_var, stat) %>%
        ggplot(.) %+%
        geom_col(aes_string(x = time_var, y = stat),
                 fill = "steelblue") %+%
        theme_light() %+%
        scale_y_continuous(labels = scales::comma) %+%
        ggtitle(paste0(stat, " for ", carrier, " by ", time_var_cleaned)) %+%
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) %+%
        ylab(stat) %+%
        xlab(time_var_cleaned) %>%
        ggplotly()
}

add_info_column <- function(df, type){
    #' Create new column with concatenated the most important information from other columns.
    #' Data from this new column can be displayed on the leaflet map.
    #' @description This function reates new column with concatenated the most important information from other columns.
    #' @param df data frame storing flights' and delays' data
    #' @param type string, which stats should be computed: "route" or "airport"
    #' @usage add_info_column(df, type)
    #' @return  data frame with additional column
    #' @examples add_info_column(dashboard_data_routes, "route")
    df <- df %>%
        mutate(INFO = paste(paste0("# flights: ", NB_FLIGHTS),
                            paste0("% flights on time: ", FLIGHTS_ON_TIME_PCT),
                            paste0("% flights delayed >60min: ", FLIGHTS_DEL_60_PCT),
                            paste0("% flights delayed >180min: ", FLIGHTS_DEL_180_PCT),
                            paste0("avg arrival time diff [min]: ", AVG_ARRIVAL_TIME_DIFF_MIN),
                            paste0("avg delay [min]: ", AVG_DELAY_MIN),
                            sep = "<br/>"))   
    if(type == "route"){
        df <- df %>%
            mutate(INFO = paste(INFO, 
                                paste0("distance [km]: ", DISTANCE),
                                paste0("flight time [min]: ", round(FLIGHT_TIME)),
                                sep = "<br/>"))   
    } else if (type == "airport"){
        df <- df 
    }
    df
}

#=========================== DATA LOAD ==============================
files_to_load <- list.files("data/")
files_to_load <- files_to_load[grep("dashboard_", files_to_load)] %>%
    str_replace(., ".rds", "")

for (file in files_to_load){
    eval(parse(text = paste0(file," <- read_rds('", "data/", file, ".rds')")))
}

#=========================== APP ==============================
shinyServer(function(input, output) {

    
    ###################### KPIs ###################### 
    output$kpiAirlines <- renderValueBox({
        valueBox(
            dashboard_data_kpis$NB_AIRLINES,
            "# airlines",
            icon = icon("plane", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiRoutes <- renderValueBox({
        valueBox(
            dashboard_data_kpis$NB_ROUTES_TH,
            "# routes [thousands]", icon = icon("globe", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiFlights <- renderValueBox({
        valueBox(
            dashboard_data_kpis$NB_FLIGHTS_MN,
            "# flights [Milions]", icon = icon("transfer", lib = "glyphicon"),
            color = "blue"
        )
    })
    
    output$kpiOnTime <- renderValueBox({
        valueBox(
            paste0(dashboard_data_kpis$FLIGHTS_ON_TIME_PCT,"%"),
            "flights on time, i.e. delayed < 15min", icon = icon("thumbs-up", lib = "glyphicon"),
            color = "green"
        )
    })
    
    output$kpiDelayed60 <- renderValueBox({
        valueBox(
            paste0(dashboard_data_kpis$FLIGHTS_DEL_60_PCT,"%"),
            "flights delayed > 60min", icon = icon("hand-right", lib = "glyphicon"),
            color = "yellow"
        )
    })
    
    output$kpiDelayed180 <- renderValueBox({
        valueBox(
            paste0(dashboard_data_kpis$FLIGHTS_DEL_180_PCT,"%"),
            "flights delayed > 180min", icon = icon("thumbs-down", lib = "glyphicon"),
            color = "red"
        )
    })
    
    ###################### KEY STATS TAB ###################### 
    selected_column_stats_tab <- reactive({
        map_stats_to_colnames(input$tabStatsStatSelect)
    })
    
    output$barplotStatByAirline <- renderPlotly({
        dashboard_data_airlines$tb_stats_airline %>%
            filter(CARRIER_NAME != "OVERALL") %>%
            select("CARRIER_NAME", selected_column_stats_tab()) %>%
            arrange(across(starts_with(selected_column_stats_tab()))) %>%
            mutate(CARRIER_NAME = factor(CARRIER_NAME, levels = .$CARRIER_NAME)) %>%
            ggplot(.) %+%
            geom_col(aes_string(x = selected_column_stats_tab(), y = "CARRIER_NAME"),
                     fill = "steelblue") %+%
            theme_light() %+%
            scale_x_continuous(labels = scales::comma) %+%
            ggtitle(input$tabStatsStatSelect) %+%
            ylab("Airline") %+%
            xlab(input$tabStatsStatSelect) %>%
            ggplotly()
    })
    
    output$lineplotStatByAirline <- renderPlotly({
        dashboard_data_airlines$tb_stats_airline_DAY %>%
            filter(CARRIER_NAME == input$tabStatsSelectCarrier) %>%
            select("FL_DATE", selected_column_stats_tab()) %>%
            ggplot(.) %+%
            geom_line(aes_string(x = "FL_DATE", y = selected_column_stats_tab()),
                      col = "steelblue") %+%
            theme_light() %+%
            scale_y_continuous(labels = scales::comma) %+%
            ggtitle(paste0(input$tabStatsStatSelect, " for ", input$tabStatsSelectCarrier)) %+%
            ylab(input$tabStatsStatSelect) %+%
            xlab("Flight date") %>%
            ggplotly()
    })
    
    output$barlotStatByMonth <- renderPlotly({
        plot_barplot_stat_by_time(df = dashboard_data_airlines$tb_stats_airline_MONTH,
                                  stat = selected_column_stats_tab(),
                                  carrier = input$tabStatsSelectCarrier,
                                  time_var = "MONTH")
    })
    
    output$barlotStatByWeekday <- renderPlotly({
        plot_barplot_stat_by_time(df = dashboard_data_airlines$tb_stats_airline_WEEKDAY,
                                  stat = selected_column_stats_tab(),
                                  carrier = input$tabStatsSelectCarrier,
                                  time_var = "WEEKDAY")
    })
    
    output$barlotStatByDaytime <- renderPlotly({
        plot_barplot_stat_by_time(df = dashboard_data_airlines$tb_stats_airline_DEP_DAY_TIME,
                                  stat = selected_column_stats_tab(),
                                  carrier = input$tabStatsSelectCarrier,
                                  time_var = "DEP_DAY_TIME")
    })
    ###################### ROUTES TAB ###################### 
    selected_column_routes_tab <- reactive({
        map_stats_to_colnames(input$tabRoutesStatsSelect)
    })
    
    data_tab_routes <- reactive({
        data_tab_routes <- dashboard_data_routes %>%
            filter(CARRIER_NAME == input$tabRoutesSelectCarrier) %>%
            arrange(across(starts_with(selected_column_routes_tab()), desc)) %>%
            head(input$tabRoutesSlider) %>%
            mutate(ID = row_number()) %>%
            select(ID, everything())
        if(input$tabRoutesSelectCarrier == "OVERALL"){
            data_tab_routes <- data_tab_routes %>%
                select(-CARRIER_NAME)
        } else {
            data_tab_routes <- data_tab_routes %>%
                select(-AIRLINES)
        }
        data_tab_routes
    })
    
    output$tableRoutes <- renderDataTable({
        data_tab_routes() %>%
            select(-ends_with("TUDE"))
    })
    
    output$mapRoutes <- renderLeaflet({
        map_data <- data_tab_routes() %>%
            add_info_column(., type = "route") 
        
        map_data <- bind_rows(map_data %>% select(ROUTE, ROUTE_NAME, INFO, LNG = ORIGIN_LONGITUDE, LAT = ORIGIN_LATITUDE),
                       map_data %>% select(ROUTE, ROUTE_NAME, INFO, LNG = DEST_LONGITUDE, LAT = DEST_LATITUDE))
        
        
        leaflet(data = map_data) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addPolylines(., lng = ~LNG,lat = ~LAT, group = ~ROUTE_NAME, color = "steelblue",
                         popup = ~as.character(INFO), label = ~paste(ROUTE, " | ", ROUTE_NAME))
    })
    ###################### AIRPORTS TAB ###################### 
    
    selected_column_airports_tab <- reactive({
        map_stats_to_colnames(input$tabAirportsStatsSelect)
    })

    data_tab_airports <- reactive({
        dashboard_data_airports %>%
            arrange(across(starts_with(selected_column_airports_tab()), desc)) %>%
            head(input$tabAirportsSlider) %>%
            mutate(ID = row_number()) %>%
            select(ID, everything())
    })

    output$tableAirports <- renderDataTable({
        data_tab_airports() %>%
            select(-ends_with("TUDE"))
    })

    output$mapAirports <- renderLeaflet({
        data_tab_airports() %>%
            add_info_column(., type = "airport") %>%
        leaflet(data = .) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addMarkers(~DEST_LONGITUDE, ~DEST_LATITUDE,
                       popup = ~as.character(INFO), label = ~paste(DEST, " | ", DEST_NAME))
    })
    
    ###################### DELAYS TAB ######################
    
    output$barplotDelayReasonByAirline <- renderPlotly({
        dashboard_data_delays$tb_stats_delay_reason_carrier %>%
            rename(REASON = REASON_MAX_TIME) %>%  
            filter(CARRIER_NAME == input$tabDelaysSelect) %>%
            arrange(across(starts_with("PCT_DELAYS"))) %>%
            mutate(REASON = factor(REASON, levels = .$REASON)) %>%
            ggplot(.) %+%
            geom_col(aes_string(x = "PCT_DELAYS", y = "REASON"),
                     fill = "steelblue") %+%
            theme_light() %+%
            scale_x_continuous(labels = scales::comma) %+%
            ggtitle("Delay reasons") %+%
            ylab("Delay reasons") %+%
            xlab("Percent of delays") %>%
            ggplotly()
    })
    
    output$barplotDelayTimeByAirline <- renderPlotly({
        dashboard_data_delays$tb_stats_delay_time_carrier %>%
            rename(REASON = KEY, DELAY_LENGTH = VALUE) %>%  
            filter(CARRIER_NAME == input$tabDelaysSelect) %>%
            arrange(across(starts_with("DELAY_LENGTH"))) %>%
            mutate(REASON = factor(REASON, levels = .$REASON)) %>%
            ggplot(.) %+%
            geom_col(aes_string(x = "DELAY_LENGTH", y = "REASON"),
                     fill = "steelblue") %+%
            theme_light() %+%
            scale_x_continuous(labels = scales::comma) %+%
            ggtitle("Delay length") %+%
            ylab("Delay reasons") %+%
            xlab("Delay length [min]") %>%
            ggplotly()
    })
    

})
