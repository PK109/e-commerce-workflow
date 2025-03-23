terraform {
  required_providers {
    kestra = {
        source  = "kestra-io/kestra"
        version = "0.21.1"
    }
  }
}

provider "kestra" {
  # mandatory, the URL for kestra
  url = "http://localhost:8080"

  # optional basic auth username
  username = "admin@localhost.dev"
  password = "kestra"

}

resource "kestra_flow" "gcp_kv_setup" {
  namespace = "dev"
  flow_id = "gcp_kv_setup"
  content = file("flows/gcp_kv_setup.yml")
}

resource "kestra_flow" "subflow_dev" {
  namespace = "dev"
  flow_id = "subflow_dev"
  content = file("flows/subflow_dev.yml")
}

resource "kestra_flow" "test_subflow" {
  namespace = "dev"
  flow_id = "test_subflow"
  content = file("flows/test_subflow.yml")
}

resource "kestra_flow" "data_daily_ingestion" {
  namespace = "dev"
  flow_id = "data_daily_ingestion"
  content = file("flows/data_daily_ingestion.yml")
}