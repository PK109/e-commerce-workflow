#!/usr/bin/env python
# coding: utf-8

import argparse

from pyspark.sql import SparkSession

parser = argparse.ArgumentParser()

parser.add_argument('--input', required=True)
parser.add_argument('--output', required=True)

args = parser.parse_args()

input = args.input
output = args.output


# Tworzenie sesji Spark
spark = SparkSession.builder \
    .appName("CSV to Parquet Partitioning") \
    .getOrCreate()

# Ścieżki plików
files = [ "2019-Oct","2019-Nov", "2019-Dec", "2020-Jan", "2020-Feb", "2020-Mar", "2020-Apr" ]
for file in files[1:]:
    csv_file =f"{input}/{file}.csv"  # Plik wejściowy CSV
    output_dir = f"{output}/{file}"  # Folder na partycje
    
    # Wczytanie CSV do DataFrame
    df = spark \
        .read.option("header", "true") \
        .csv(csv_file)
    
    # Podział na partycje po 1 mln wierszy i zapis jako Parquet
    df.repartition((df.count() // 1_000_000) + 1).write.mode("overwrite").parquet(output_dir)
    
    print(f"Zapisano partycje w {output_dir}")

# Zamknięcie sesji Spark
spark.stop()
