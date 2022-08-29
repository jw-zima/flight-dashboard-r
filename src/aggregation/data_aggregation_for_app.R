#=========================== SETUP ==================================
library(tidyverse)
library(readr)
library(magrittr)
library(lubridate)
library(ggplot2)
library(plotly)
library(tictoc)
library(docstring)

#=========================== UDFs ===================================
calc_stats <- function(df, grouping_vars = NULL){
  #' Compute the most important KPIs/stats split by groups
  #' @description This function computes basic frequency and flight delay stats
  #' @param df data frame storing flights' and delays' data
  #' @param grouping_vars name of column or list of column names that should
  #' be used for grouping
  #' @usage calc_stats(df, grouping_vars)
  #' @return data frame with stats for each group
  #' @examples calc_stats(df_flight_data, c("CARRIER_NAME"))
  df %>%
    group_by_at(grouping_vars) %>%
    summarise(NB_FLIGHTS = n(),
              FLIGHTS_ON_TIME_PCT = 100 * round((1 - sum(FLAG_ARR_DELAYED_15MIN) / NB_FLIGHTS),3),
              FLIGHTS_DEL_60_PCT = 100 * round((sum(FLAG_ARR_DELAYED_60MIN) / NB_FLIGHTS),3),
              FLIGHTS_DEL_180_PCT = 100 * round((sum(FLAG_ARR_DELAYED_180MIN) /NB_FLIGHTS),3),
              AVG_ARRIVAL_TIME_DIFF_MIN = round(mean(ARR_TIME_DIFF), 0),
              AVG_DELAY_MIN = round(mean(ARR_TIME_DIFF[FLAG_ARR_DELAYED == 1]), 0),
              NB_AIRLINES = n_distinct(CARRIER),
              NB_ROUTES = n_distinct(ROUTE),
              NB_FLIGHTS = n(),
              .groups = "drop"
    )
}

format_count_stats <- function(df){
  #' Format count KPIs for better readability
  #' @description Change absolute values into millions/thousands
  #' @param df data frame storing flights' and delays' stats
  #' @usage format_count_stats(df)
  #' @return data frame with stats with reformatted columns storing count stats
  #' @examples format_count_stats(tb_stats)
  df %>%
    mutate(NB_FLIGHTS_MN = round(NB_FLIGHTS / 1000000, 1),
           NB_ROUTES_TH = round(NB_ROUTES / 1000, 1)
           ) %>%
    select(-NB_FLIGHTS, -NB_ROUTES)
}

calc_overall_stats_by_airline_and_split <- function(df, grouping_vars){
  #' Compute most important stats split both for selected groups and each airline, as well as for all airlines at once (overall)
  #' @description This function computes and unions key stats for each group extended by airline and for all airlines combined
  #' @param df data frame storing flights' and delays' stats
  #' @param grouping_vars name of column or list of column names that should
  #' @usage calc_overall_stats_by_airline_and_split(x, grouping_vars)
  #' @return data frame with unioned start split by grouping var and airline as well as by selected group for all airlines combined
  #' @examples calc_overall_stats_by_airline_and_split(df_flight_data, "MONTH")
  stats_by_airline_and_split <- df %>%
    calc_stats(., c("CARRIER_NAME", grouping_vars))
  
  stats_by_split <- df %>%
    calc_stats(., grouping_vars)
  
  result <-
    bind_rows(stats_by_airline_and_split, stats_by_split) %>%
    mutate(CARRIER_NAME = ifelse(is.na(CARRIER_NAME),  "OVERALL", CARRIER_NAME)) %>%
    select(-NB_AIRLINES)
  
  result
}

get_most_important_reason <- function(x){
  #' Get name of a element with the highest value
  #' @description This function returns name of element with the highest value.
  #' If more than one element has maximum value then names are being concatenated
  #' @param x list of elements
  #' @usage get_most_important_reason(x)
  #' @return character string with name or concatenated names of elements with the highest value
  #' @examples reasons <- 1:5
  #' names(reasons) <- c("AIRLINE_DELAY", "WEATHER_DELAY", "NAS_DELAY", "SECURITY_DELAY", "LATE_AIRCRAFT_DELAY")
  #' get_most_important_reason(reasons)
  
  x <- x[-1]
  paste0(
    names(x)[which(x == max(x))],
    collapse = ", ")
}

#=========================== DATA LOAD ==============================
df <- read_rds("data/processed/tb_flights_2019_filtered.rds")

#=========================== DATA AGGREGATION =======================
#====== Overall KPIs ======
tb_kpis_overall <- df %>%
  calc_stats(., NULL) %>%
  format_count_stats(.)

#====== Stats tab ======
tb_stats_airline <- calc_overall_stats_by_airline_and_split(df, NULL)
tb_stats_airline_MONTH <- calc_overall_stats_by_airline_and_split(df, "MONTH")
tb_stats_airline_WEEKDAY <- calc_overall_stats_by_airline_and_split(df, "WEEKDAY")
tb_stats_airline_DEP_DAY_TIME <- calc_overall_stats_by_airline_and_split(df, "DEP_DAY_TIME")
tb_stats_airline_DAY <- calc_overall_stats_by_airline_and_split(df, "FL_DATE")

#====== Routes tab ======
tb_stats_routes <- left_join(
  calc_overall_stats_by_airline_and_split(df, 
                                          c("ROUTE", "ROUTE_NAME", 
                                                "ORIGIN_LATITUDE", "ORIGIN_LONGITUDE",
                                                "DEST_LATITUDE", "DEST_LONGITUDE")),
  df %>%
    group_by(ROUTE, ROUTE_NAME, 
             ORIGIN_LATITUDE, ORIGIN_LONGITUDE,
             DEST_LATITUDE, DEST_LONGITUDE) %>%
    summarise(AIRLINES = paste(unique(CARRIER_NAME), collapse  = ", "),
              DISTANCE = mean(DISTANCE),
              FLIGHT_TIME = mean(AIR_TIME),
              .groups = "drop") %>%
    mutate(CARRIER_NAME = "OVERALL"),
  by = c("ROUTE", "ROUTE_NAME", "CARRIER_NAME",
         "ORIGIN_LATITUDE", "ORIGIN_LONGITUDE",
         "DEST_LATITUDE", "DEST_LONGITUDE")) %>%
  select(-NB_ROUTES) %>%
  select(contains("ROUTE"), starts_with("NB_"), contains("AIRLINES"), everything()) %>%
  arrange(desc(NB_FLIGHTS))

#====== Airports tab ======
tb_stats_airports <- df %>%
    calc_stats(., c("DEST", "DEST_NAME", "DEST_CITY",
                    "DEST_LATITUDE", "DEST_LONGITUDE")) %>%
    select(contains("DEST"), starts_with("NB_"), everything()) %>%
    arrange(desc(NB_FLIGHTS))

#====== Delays tab ======
tb_stats_routes_carrier_MONTH <- calc_overall_stats_by_airline_and_split(df, c("ROUTE_NAME", "MONTH"))
tb_stats_routes_carrier_WEEKDAY <- calc_overall_stats_by_airline_and_split(df, c("ROUTE_NAME", "WEEKDAY"))
tb_stats_routes_carrier_DEP_DAY_TIME <- calc_overall_stats_by_airline_and_split(df, c("ROUTE_NAME", "DEP_DAY_TIME"))

tic()
df_delay_reasons <- df %>%
  filter(FLAG_ARR_DELAYED == 1) %>%
  select(CARRIER_NAME, ends_with("_DELAY")) %>%
  mutate(REASON_MAX_TIME = apply(., 1, get_most_important_reason)) %>%
  mutate(REASON_MAX_TIME = str_replace(REASON_MAX_TIME, "_DELAY", ""))
toc()

tb_stats_delay_time_carrier <- bind_rows(
  df_delay_reasons %>%
    group_by(CARRIER_NAME) %>%
    summarise_all(mean),
  df_delay_reasons %>%
    summarise_all(mean) %>%
    mutate(CARRIER_NAME = "OVERALL")
) %>%
  select(-REASON_MAX_TIME) %>%
  gather(., key = "KEY", value = "VALUE", -CARRIER_NAME) %>%
  mutate(VALUE = round(VALUE))


tb_stats_delay_reason_carrier <- bind_rows(
  df_delay_reasons %>%
    group_by(CARRIER_NAME, REASON_MAX_TIME) %>%
    summarise(NB_DELAYS = n(),
              .groups = "drop"),
  df_delay_reasons %>%
    group_by(REASON_MAX_TIME) %>%
    summarise(NB_DELAYS = n(),
              .groups = "drop") %>%
    mutate(CARRIER_NAME = "OVERALL")
) %>%
  group_by(CARRIER_NAME) %>%
  mutate(PCT_DELAYS = 100 * round(NB_DELAYS / sum(NB_DELAYS),3))

#=========================== DATA SAVE ==============================
dashboard_data_location <- "src/flight-delays-dashboard/data/"
write_rds(tb_kpis_overall, file = paste0(dashboard_data_location, "dashboard_data_kpis.rds"))

write_rds(
  list(tb_stats_airline = tb_stats_airline,
       tb_stats_airline_MONTH = tb_stats_airline_MONTH,
       tb_stats_airline_WEEKDAY = tb_stats_airline_WEEKDAY,
       tb_stats_airline_DEP_DAY_TIME = tb_stats_airline_DEP_DAY_TIME,
       tb_stats_airline_DAY = tb_stats_airline_DAY
  ),
  file = paste0(dashboard_data_location, "dashboard_data_airlines.rds"))

write_rds(tb_stats_routes, file = paste0(dashboard_data_location, "dashboard_data_routes.rds"))

write_rds(tb_stats_airports, file = paste0(dashboard_data_location, "dashboard_data_airports.rds"))

write_rds(
  list(tb_stats_routes_carrier_MONTH = tb_stats_routes_carrier_MONTH,
       tb_stats_routes_carrier_WEEKDAY = tb_stats_routes_carrier_WEEKDAY,
       tb_stats_routes_carrier_DEP_DAY_TIME = tb_stats_routes_carrier_DEP_DAY_TIME,
       tb_stats_delay_time_carrier = tb_stats_delay_time_carrier,
       tb_stats_delay_reason_carrier = tb_stats_delay_reason_carrier
  ),
  file = paste0(dashboard_data_location, "dashboard_data_delays.rds"))
