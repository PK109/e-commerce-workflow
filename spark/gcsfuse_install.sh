#! /bin/bash

export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc
sudo apt-get update
sudo apt-get install gcsfuse
# for dev purposes
mkdir ./dataset_raw
mkdir ./dataset_pq
gcsfuse --only-dir e_commerce_dataset/raw fleet-aleph-447822-a2-e_commerce_storage-1 ./dataset_raw
gcsfuse --only-dir e_commerce_dataset/parquet fleet-aleph-447822-a2-e_commerce_storage-1 ./dataset_pq