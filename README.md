# e-commerce-workflow

Steps to reproduce the project.

Note! Dataproc infrastructure is implemented, yet not in use. Therefore its building is not necessary to run project for now.

1. Fork/clone project to your Linux machine. Github codespaces comes handy at this step.
1. Install Terraform:
    ``` bash
        cd terraform/
        chmod +x tf_install.sh
        ./tf_install.sh
    ```
1. Enable API for:
    * Compute Engine API
    * Cloud Dataproc API (optional)


1. Create and provide SSH keys for VM machines (Compute Engine -> Settings -> Metadata -> SSH Keys)

1. Create a service account in your cloud project. To run this setup, you need these roles:
    * BigQuery Admin
    * Compute Admin
    * Service Account User
    * Storage Admin
    * Dataproc Editor (optional)  

1. Configure your project in terraform/variables.tf. In particular provide:
    * path to your GCP credentials
    * key information for GCP project
        * project_id
        * location / zone of your choice
        * service account mail, that was created in previous step
        * vm_user name provided in the SSH key
    * this git project url (might remain untouched if no changes would be applied)

1. Apply the infrastructure with Terraform
    ``` bash
        terraform init
        terraform plan
        terraform apply --auto-approve
    ```
    After succesful build, Terraform will output External IP address for created VM.
1. After first start of VM, startup script will be executed. It might take several minutes to finalize. It is recommended to log in to machine after startup script is finished.

1. When connected to VM, it is possible to validate the script execution by calling command:
    ``` 
        sudo journalctl -u google-startup-scripts.service
    ```

1. Proceed to project folder. (e-commerce-project)
    Adjust *.env* file if required.  
    Run aliased command for starting Kestra setup:
    ```
        docker_up
    ```
    If termination of service is required, use command:
    ```
        docker_down
    ```

1. Proceed to kestra folder.  
    * Adjust Key-Value setup in *flows/dev/gcp_kv_setup.yml*  
    * Upload flows to Kestra, using Terraform
    ``` bash
        terraform init
        terraform plan
        terraform apply --auto-approve
    ```
1. Log in to Kestra application, that should be available at *localhost:8080*.  
Run **gcp_kv_setup.yml** and provide missing credentials in KV store.

1. There are two main flows used in this application.  
First, **extract_raw_data**, performs several operations. This flow downloads the raw file from server, splits it to separate files partitioned by day and uploads data to GCS. It simulates some daily provided data, that should be handled automatically by system. There is also a helper flow, that manages bulk extraction - **batch_extract**.  
Second important flow, **ingest_to_bq** is triggered automatically, when files are found in selected folder. It ingest data to BigQuery in the form of raw table.
Then, after ingestion is done, runs dbt job that builds models for data warehouse.

1. To start entire pipeline, just run **batch_extract** flow. It will take significant ammount of time to finish that operation, as 411M of records needs to be handled in this project.
