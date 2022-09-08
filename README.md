#  flight-dashboard-r

# Shiny dashboard with stast on flight arrivals and delays in US in 2019
<p align="left">
    <a alt="Data Analysis">
        <img src="https://img.shields.io/badge/%20-Data%20Analysis%20-orange" /></a>
    <a alt="Visualisation">
        <img src="https://img.shields.io/badge/%20-Visualisation%20-orange" /></a>
    <a alt="Dashboard">
        <img src="https://img.shields.io/badge/%20-Interactive%20Dashboard%20-orange" /></a>
</p>

## General info

#### Problem Statement
The app delivers summary statitics on **2019 US domestic traffic data** and **on-time performance** of flights operated by large air carriers along with providing **delay reasons**.

## Website
https://jw-zima.shinyapps.io/flight-delays-dashboard/ [disabled after the testing phase]

![](/references/tab_stats.PNG)

![](/references/tab_routes.PNG)

![](/references/tab_airports.PNG)

![](/references/tab_delay_reasons.PNG)

## Technologies

<p align="left">
    <a alt="R">
        <img src="https://img.shields.io/badge/%20-R%20-blue" /></a>
    <a alt="Shiny">
        <img src="https://img.shields.io/badge/%20-Shiny%20-blue" /></a>
    <a alt="bash">
        <img src="https://img.shields.io/badge/%20-bash%20-blue" /></a>
    <a alt="Docker">
        <img src="https://img.shields.io/badge/%20-Docker%20-blue" /></a>
</p>


## References

Datasets are were downloaded from the kaggle platform using the official [Kaggle API](https://github.com/Kaggle/kaggle-api). Data used:
* [Airline Database](https://www.kaggle.com/datasets/open-flights/airline-database)
* [Airports, Train Stations, and Ferry Terminals](https://www.kaggle.com/datasets/open-flights/airports-train-stations-and-ferry-terminals)
* [Airline Delay Analysis](https://www.kaggle.com/datasets/sherrytp/airline-delay-analysis)

--------
## How to run it
Run the following command in the bash terminal:

```zsh
bash ./setup.sh
```
The following command would:
* create required environments (both R and conda),
* launch data download from the Kaggle platform
* run data preprocessing and aggregation
* build the Shiny app
* build and run Docker
* copy the app to container and host it there.


## Install developer requirements

1. bash
2. R
3. conda
4. Docker

________________


## Project Organization

```
├── data
│   ├── interim             <- Intermediate data that has been transformed.
│   ├── processed           <- The final, canonical data sets used to compute all stats for the dashboard.
│   └── raw                 <- The original, immutable data dump.
│
├── flight-delays-dashboard <- All files required to build and runn the Shiny app  
│   ├── data                <- Aggreagted data used in the dashboard
│   ├── renv                <- Envirton files required to restore the Shiny app R environment
│   ├── renv.lock           <- Lock file with list of required R packages for the Shiny app
│   ├── rsconnect           <- Files required to publich the app using the RStudio Connect [needed only if this deploymnet option would be selected]
│   ├── server.R            <- Server shiny file
│   └── ui.R                <- UI shiny file
│
├── references         <- Screen shots of the Shiny app
│
├── renv               <- Envirton files required to restore the project R environment
│
├── renv.lock          <- Lock file with list of required R packages for the entire project
│
├── reports            <- Generated results of EDA analysis as HTML
│
├── src                <- Source code for use in this project.
│   ├── data           <- Scripts to download or gather/join data
│   │   ├── data_downaload.sh
│   │   └── data_gathering.R
│   ├── aggregation    <- Scripts to aggregate data to compute all stats required for the dashboard
│   │   └── data_aggregation_for_app.R
│   ├── utils          <- Scripts with utilities
│   │   └── install_load_packages.R
│   └── visualization  <- Scripts to run EDA analyses/generate plots
│       └── eda_with_data_explorer.R
│
├── test               <- Placeholder for test. Tests were abandoned in this project.
|
├── Dockerfile         <- Dockerfile
|
├── env.yml            <- yml file to restore conda environment
|
├── README.md          <- The top-level README for developers using this project.
|
├── LICENSE
|
└── setup.sh           <- Core bash script to run all steps.

```

## Contributors

jw-zima

--------
<p><small>Project based on the <a target="_blank" href="https://github.com/tgrrr/cookiecutter-data-science-r">cookiecutter data science for r project template</a>. #cookiecutterdatascience</small></p>
