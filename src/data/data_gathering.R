#=========================== SETUP ==================================
library(tidyverse)
library(readr)
library(magrittr)
library(lubridate)
library(ggplot2)
library(plotly)
library(docstring)

#=========================== UDFs ===================================
clean_colnames <- function(df){
  #' Clean and unify column names
  #' @description Make all column names uppercase and replace punctuation signs with underscore
  #' @param df data frame 
  #' @usage clean_colnames(df)
  #' @return data frame with cleaned and unified column names
  #' @examples clean_colnames(iris)
  df %>%
    set_colnames(
      toupper(colnames(.)) %>%
        str_replace_all(., "[[:punct:]]| ", "_")
      )
}

na_to_zero_replace <- function(x){
  #' Replace missing values with 0
  #' @description This function replaces missing values with 0
  #' @param x vector
  #' @usage na_to_zero_replace(x)
  #' @return vector with NAs replaced with 0
  #' @examples na_to_zero_replace(c(1, 2, 4, NA, 4, 3))
  ifelse(is.na(x), 0, x)
}

#=========================== DATA LOAD ==============================
# airport data
colnames_airports_data <- c("Airport ID", "Airport Name", "City",
                            "Country", "IATA", "ICAO", "Latitude",
                            "Longitude", "Altitude", "Timezone Hours",
                            "Daylight savings time", "Timezone", "Type",
                            "Source")

tb_airports <- read_csv("data/raw/airports-extended.csv",
                        col_names = colnames_airports_data,
                        show_col_types = FALSE) %>%
  clean_colnames() %>%
  select(NAME = AIRPORT_NAME, CITY, COUNTRY,  IATA, COUNTRY, 
         LATITUDE, LONGITUDE)


# airline data
tb_airlines <- read_csv("data/raw/airlines.csv", 
                        show_col_types = FALSE) %>%
  clean_colnames() %>%
  select(NAME, IATA, COUNTRY) %>%
  set_colnames(str_c("CARRIER_", colnames(.)))

# flight data
tb_flights <- read_csv("data/raw/delays_2019.csv", show_col_types = FALSE) %>%
  clean_colnames() %>%
  select(-c(TAXI_OUT, WHEELS_OFF, WHEELS_ON, TAXI_IN, `___21`))

#=========================== DATA CLEANING ==========================
tb_flights <- tb_flights %>%
  rename(CARRIER = OP_UNIQUE_CARRIER,
         FL_NUM = OP_CARRIER_FL_NUM,
         AIRLINE_DELAY = CARRIER_DELAY,
         DEP_TIME_DIFF = DEP_DELAY,
         ARR_TIME_DIFF = ARR_DELAY) %>%
  # join all data sources
  left_join(tb_airlines, by = c("CARRIER" = "CARRIER_IATA")) %>%
  left_join(tb_airports %>%
              set_colnames(str_c("ORIGIN_", colnames(.))),
            by = c("ORIGIN" = "ORIGIN_IATA")) %>%
  left_join(tb_airports %>%
              set_colnames(str_c("DEST_", colnames(.))),
            by = c("DEST" = "DEST_IATA")) %>%
  # impute NAs
  mutate_at(colnames(.)[endsWith(colnames(.), "DELAY")],
            na_to_zero_replace) %>%
  # create new variables
  mutate(ROUTE = paste0(ORIGIN, "-", DEST),
         ROUTE_NAME = paste0(ORIGIN_CITY, "-", DEST_CITY),
         FLAG_ARR_DELAYED = ifelse(ARR_TIME_DIFF > 0, 1, 0),
         FLAG_ARR_DELAYED_15MIN = ifelse(ARR_TIME_DIFF >= 15, 1, 0),
         FLAG_ARR_DELAYED_60MIN = ifelse(ARR_TIME_DIFF >= 60, 1, 0),
         FLAG_ARR_DELAYED_180MIN = ifelse(ARR_TIME_DIFF >= 180, 1, 0),
         OTHER_REASON_DELAY = ifelse(
           FLAG_ARR_DELAYED == 0,
           0,
           ARR_TIME_DIFF - (AIRLINE_DELAY + WEATHER_DELAY + NAS_DELAY +
                              SECURITY_DELAY + LATE_AIRCRAFT_DELAY)),
         MONTH = months(FL_DATE),
         WEEKDAY = weekdays(FL_DATE),
         DEP_HOUR = as.integer(substr(DEP_TIME, 1, 2)),
         DEP_DAY_TIME = case_when(DEP_HOUR >= 7 & DEP_HOUR <= 10 ~ "morning 7-10",
                                  DEP_HOUR >= 11 & DEP_HOUR <= 14 ~ "around noon 11-14",
                                  DEP_HOUR >= 15 & DEP_HOUR <= 18 ~ "afternoon 15-18",
                                  DEP_HOUR >= 19 & DEP_HOUR <= 22~ "evening 19-22",
                                  DEP_HOUR >= 23 | DEP_HOUR <= 2 ~ "night 23-02",
                                  DEP_HOUR >= 3 & DEP_HOUR <= 6 ~ "early morning 03-06",
                                  is.na(DEP_HOUR) ~ "unknown",
                                  TRUE ~ "error"),
         MONTH = factor(MONTH, levels = month.name),
         WEEKDAY = factor(WEEKDAY, levels = c("Monday", "Tuesday", "Wednesday",
                                              "Thursday", "Friday", "Saturday", "Sunday")),
         DEP_DAY_TIME = factor(DEP_DAY_TIME, levels = c("morning 7-10", "around noon 11-14", "afternoon 15-18",
                                                        "evening 19-22", "night 23-02", "early morning 03-06", "unknown", "error"))) %>% 
  # reorder columns
  select(-DEP_HOUR) %>%
  select(FL_DATE, MONTH, WEEKDAY, DEP_DAY_TIME,
         starts_with("CARRIER"), FL_NUM, starts_with("ROUTE"), contains("ORIG"),
         contains("DEST"), contains("DEP"), contains("ARR"),
         ends_with("DELAY"), everything())

#=========================== DATA SAVE ==============================
write_rds(tb_flights, "data/interim//tb_flights_2019.rds")

tb_flights %>%
  na.omit() %>%
  write_rds(., "data/processed/tb_flights_2019_filtered.rds")
