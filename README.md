# e-commerce-workflow

## **Objectives**

This project implements a data pipeline for processing e-commerce data using Terraform, Kestra, and dbt.
Project can be directly utilized to perform dashboards on Looker studio or any similar tool.

> [!Note]  
> Please refer to `SETUP.md` and `TROUBLESHOOTING.md` for instructions how to handle this project on your own.

## **Features**
- **Infrastructure Provisioning:** Terraform provisions GCP resources like Compute Engine, BigQuery, and GCS.
- **Orchestration:** Kestra orchestrates data ingestion and transformation workflows.
- **Data Transformation:** dbt builds data models and metrics for analysis.
- **Visualization:** after build, data is ready to be visualized.
## **Project Infrastructure**
![e-commerce workflow diagram](https://github.com/user-attachments/assets/14e493ee-4cb1-448f-9c11-1b80f548e7e9)
## **Project Structure**
- **`terraform/`**: Contains Terraform configurations for provisioning GCP resources.
- **`kestra/`**: Includes Kestra workflow definitions and simple TF file to import flows to application
- **`dbt/`**: Houses dbt models and configurations for data transformation.
- **`spark/`**: Contains PySpark scripts for data processing. Not in use for now.




## **Contributing**
Contributions are welcome! Feel free to open issues or submit pull requests for improvements.
