
## **Setup Instructions**

> [!Note]  
> Dataproc infrastructure and spark enviroment are implemented, yet not in use. Therefore its building is not necessary to run project for now.



1. **Fork/clone project to your Linux machine**  
 Github codespaces comes handy at this step.
1. **Install Terraform**
    ``` bash
        cd terraform/
        chmod +x tf_install.sh
        ./tf_install.sh
    ```



1. **Create and provide SSH keys for VM machines**  
Compute Engine -> Settings -> Metadata -> SSH Keys

1. **Create a service account in your cloud project**  
To run this setup, you need these roles:
    * BigQuery Admin
    * Compute Admin
    * Service Account User
    * Storage Admin
    * Dataproc Editor (optional)  

1. **Configure your project in terraform/variables.tf**  
In particular provide:
    * `credentials` path to your GCP credentials
    
    * key information for GCP project
        - `project_id`
        - `location` and `zone`
        - `service_account_mail` (created in the previous step)
        - `vm_user` (username for the SSH key)
    * `project_repo_url`  (the Git project URL can remain unchanged if no modifications are needed).

1. **Apply the infrastructure with Terraform**
    ``` bash
        terraform init
        terraform plan
        terraform apply --auto-approve
    ```
    After succesful build, Terraform will output External IP address for created VM.
1. **After first start of VM, startup script will be executed**  
It might take several minutes to finalize. It is recommended to log in to machine after startup script is finished.

1. **When connected to VM, it is possible to validate the script execution by calling command**
    ``` 
        sudo journalctl -u google-startup-scripts.service
    ```

1. **Proceed to project folder. `e-commerce-project`**  

    Adjust *.env* file if required.  
    Run aliased command for starting Kestra setup:
    ```
        docker_up
    ```
    If termination of service is required, use command:
    ```
        docker_down
    ```

1. **Proceed to `kestra` folder**
    * Adjust Key-Value setup in *flows/dev/gcp_kv_setup.yml*  
    * Upload flows to Kestra, using Terraform
    ``` bash
        terraform init
        terraform plan
        terraform apply --auto-approve
    ```
1. **Log in to Kestra application**  
It should be available at *localhost:8080*.  
Run **gcp_kv_setup.yml** and provide missing credentials in KV store.

1. **Pipeline Overview**

    * **`extract_raw_data`**:
        - Downloads raw files from the server.
        - Splits files into partitions by day.
        - Uploads partitioned data to GCS.

    * **`batch_extract`**:
        - A helper flow for bulk extraction of raw data.

    * **`ingest_to_bq`**:
        - Automatically triggered when files are uploaded to a specific folder.
        - Ingests data into BigQuery as raw tables.
        - Runs a dbt job to build data warehouse models.

    **Starting the Pipeline**
    To start the entire pipeline, trigger the `batch_extract` flow. Note that this process may take significant time as it handles 411M records.


1. **Create dashboard**  
After successful build, data are ready to be visualized, with several metrics calculated.