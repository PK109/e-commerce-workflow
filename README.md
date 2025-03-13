# e-commerce-workflow

To start project, you need terraform with access to your GCP services.

Provide your service account keys with following permissions:
bigquery.datasets.create
bigquery.datasets.delete
compute.instances.*
storage.buckets.create
storage.buckets.delete


to verify what have happened on startup script, run this command on target instance:
sudo journalctl -u google-startup-scripts.service