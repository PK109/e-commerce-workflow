#! /bin/bash

awk -F, 'NR==1 {header=$0; next} 
         {split($1, d, " "); filename = "day_" d[1] ".csv"}
         !(filename in seen) {print header > filename; seen[filename]}
         {print > filename}' ../dataset_raw/2019-Dec.csv
