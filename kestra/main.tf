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
  namespace = "prod"
  flow_id = "gcp_kv_setup"
  content = file("flows/gcp_kv_setup.yml")
}

resource "kestra_flow" "subflow" {
  namespace = "prod"
  flow_id = "subflow"
  content = file("flows/subflow.yml")
}

resource "kestra_flow" "subflow_import" {
  namespace = "prod"
  flow_id = "subflow_import"
  content = file("flows/subflow_import.yml")
}

resource "kestra_flow" "dataset_import" {
  namespace = "prod"
  flow_id = "dataset_import"
  content = file("flows/dataset_import.yml")
}

resource "kestra_flow" "dataset_full_import" {
  namespace = "prod"
  flow_id = "dataset_full_import"
  content = file("flows/dataset_full_import.yml")
}