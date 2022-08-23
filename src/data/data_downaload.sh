#!/bin/bash

echo "Data download from open-flights"
kaggle datasets download open-flights/airline-database -p ./data/raw/  --unzip
kaggle datasets download open-flights/airports-train-stations-and-ferry-terminals -p ./data/raw/  --unzip
echo "Data download from airline-delay-analysis"
echo "NOTE: both data downloand and unzipping might take up to a few minutes"
kaggle datasets download sherrytp/airline-delay-analysis -p ./data/raw/ --unzip
echo "Data download - DONE"

echo "Downloaded files selection and renaming"
cd './data/raw/'
mv './airline delay analysis/2019.csv' './delays_2019.csv'
rm -r './airline delay analysis'
echo "Downloaded files selection and renaming - DONE"
