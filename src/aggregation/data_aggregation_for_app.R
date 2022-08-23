#=========================== SETUP ==================================
library(tidyverse)
library(readr)
library(magrittr)
library(lubridate)
library(ggplot2)
library(plotly)

#=========================== UDFs ===================================
calc_on_time_pct <- function(df){
  df %>%
    summarise(nb_flights = n(),
              flights_on_time_pct = 100 * round((1 - sum(FLAG_ARR_DELAYED_15MIN) / nb_flights),3),
              flights_del_60_pct = 100 * round((sum(FLAG_ARR_DELAYED_60MIN) / nb_flights),3),
              flights_del_180_pct = 100 * round((sum(FLAG_ARR_DELAYED_180MIN) /nb_flights),3)
    )
}

calc_count_stats <- function(df){
  df %>%
    summarise(nb_airlines = n_distinct(CARRIER),
              nb_routes_th = round(n_distinct(ROUTE) / 1000, 1),
              nb_flights = n(),
              nb_flights_mn = round(nb_flights / 1000000, 1)
    ) %>%
    select(-nb_flights)
}

calc_avg_time_dif <-  function(df){
  df %>%
    summarise(avg_arrival_time_diff_min = mean(ARR_TIME_DIFF),
              avg_delay_legth_min = mean(ARR_TIME_DIFF[FLAG_ARR_DELAYED == 1])
    )
}

calc_overall_stats_split <- function(df, vec){
  inner_join(
    df %>%
      group_by_at(vec) %>%
      calc_on_time_pct(.),
    df %>%
      group_by_at(vec) %>%
      calc_avg_time_dif(.),
    by = vec)
}

calc_overall_stats_by_airline_and_split <- function(df, split_var){
  stats_by_airline_and_split <- calc_overall_stats_split(df, c("CARRIER_NAME", split_var))
  stats_by_split <- calc_overall_stats_split(df, c(split_var))
  
  result <-
    bind_rows(stats_by_airline_and_split, stats_by_split) %>%
    mutate(CARRIER_NAME = ifelse(is.na(CARRIER_NAME),  "OVERALL", CARRIER_NAME))
  
  result
}

#=========================== DATA LOAD ==============================
df <- read_rds("data/processed/tb_flights_2019_filtered.rds")

#=========================== DATA AGGREGATION =======================
#====== Overall KPIs ======
tb_kpis_overall <- bind_cols(calc_count_stats(df), calc_on_time_pct(df)) %>%
  select(-nb_flights)

#====== Stats tab ======
tb_stats_airline <- calc_overall_stats_split(df, c("CARRIER_NAME"))
tb_stats_airline_MONTH <- calc_overall_stats_by_airline_and_split(df, "MONTH")
tb_stats_airline_WEEKDAY <- calc_overall_stats_by_airline_and_split(df, "WEEKDAY")
tb_stats_airline_DEP_DAY_TIME <- calc_overall_stats_by_airline_and_split(df, "DEP_DAY_TIME")
tb_stats_airline_DAY <- calc_overall_stats_by_airline_and_split(df, "FL_DATE")

#====== Routes tab ======
# tb_routes <- tbd

#====== Airports tab ======
# tb_airports <- tbd

#=========================== DATA SAVE ==============================
write_rds(tb_kpis_overall, file = "data/processed/dashboard_data_kpis.rds")

write_rds(
  list(tb_stats_airline = tb_stats_airline,
       tb_stats_airline_MONTH = tb_stats_airline_MONTH,
       tb_stats_airline_WEEKDAY = tb_stats_airline_WEEKDAY,
       tb_stats_airline_DEP_DAY_TIME = tb_stats_airline_DEP_DAY_TIME,
       tb_stats_airline_DAY = tb_stats_airline_DAY
  ),
  file = "data/processed/dashboard_data_stats.rds")

# write_rds(tb_routes, file = "data/processed/dashboard_data_routes.rds")
# 
# write_rds(tb_airports, file = "data/processed/dashboard_data_routes.rds")
