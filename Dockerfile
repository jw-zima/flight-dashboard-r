FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1 \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    netcdf-bin

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev

# copy necessary files
## app folder
COPY /flight-delays-dashboard ./app
## renv.lock file
COPY /flight-delays-dashboard/renv.lock ./renv.lock

RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'rmarkdown', 'readr', 'tidyverse', 'magrittr', 'ggplot2', 'plotly', 'leaflet', 'docstring'), repos='https://cloud.r-project.org/')"

# install renv & restore packages
# RUN Rscript -e 'install.packages("renv")'
# RUN Rscript -e 'renv::consent(provided = TRUE)'
# RUN Rscript -e 'renv::restore()'

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
