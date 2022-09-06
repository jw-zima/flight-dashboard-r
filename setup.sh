#!/bin/bash
cd "${0%/*}"

echo "==============================================="
echo "CONDA ENV CREATION"
echo "==============================================="
conda init bash
conda env create -f env.yml
source activate flight-dashboard
conda info --envs

echo "==============================================="
echo "R ENV CREATION"
echo "==============================================="
Rscript ./src/utils/install_load_packages.r

echo "==============================================="
echo "DATA DOWNLOAD"
echo "==============================================="
sh ./src/data/data_downaload.sh
#
echo "==============================================="
echo "DATA GATHERING"
echo "==============================================="
Rscript ./src/data/data_gathering.r

echo "==============================================="
echo "DATA AGGREGATION FOR APP"
echo "==============================================="
Rscript ./src/aggregation/data_aggregation_for_app.r

echo "==============================================="
echo "DOCKER BUILD"
echo "==============================================="
docker build -t flight-delays-shiny-app .

echo "==============================================="
echo "DOCKER RUN"
echo "==============================================="
docker run -d --rm -p 3838:3838 flight-delays-shiny-app
