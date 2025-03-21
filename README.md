# e-commerce-workflow

To start project, you need terraform with access to your GCP services.

Provide your service account keys with following roles:
BigQuery Admin
Compute Admin
Dataproc Editor
Service Account User
Storage Admin


to verify what have happened on startup script, run this command on target instance:
sudo journalctl -u google-startup-scripts.service

To run instantly docker-compose with kestra, run command:
docker compose --env-file=.env -f=kestra/docker-compose.yml up -d

To speed up pipeline with ingesting data to GCS, files can be uploaded compressed and converted to parquet files with mounting bucket on VM.

