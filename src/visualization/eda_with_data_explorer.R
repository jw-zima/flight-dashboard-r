#=========================== SETUP ==================================
library(readr)
library(magrittr)
library(DataExplorer)

#=========================== EDA ====================================
read_rds("data/interim//tb_flights_2019.rds") %>%
  create_report(
    output_file = "EDA Report.html",
    output_dir = "reports",
    report_title = "EDA Report - Flight arrivals and delays")
