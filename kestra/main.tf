terraform {
  required_providers {
    kestra = {
        source  = "kestra-io/kestra"
        version = "0.21.1"
    }
  }
}

provider "kestra" {
  url = "http://localhost:8080"
  username = "admin@localhost.dev"
  password = "kestra"
}
variable "namespace" {
  default = "dev"
  description = "Name of workspace to be used. Do not change."
}

resource "kestra_flow" "gcp_kv_setup" {
  namespace = var.namespace
  flow_id = "gcp_kv_setup"
  content = file("flows/${var.namespace}/gcp_kv_setup.yml")
}

resource "kestra_flow" "extract_raw_data" {
  namespace = var.namespace
  flow_id = "extract_raw_data"
  content = file("flows/${var.namespace}/extract_raw_data.yml")
}

resource "kestra_flow" "batch_extract" {
  namespace = var.namespace
  flow_id = "batch_extract"
  content = file("flows/${var.namespace}/batch_extract.yml")
}

resource "kestra_flow" "ingest_to_bq" {
  namespace = var.namespace
  flow_id = "ingest_to_bq"
  content = file("flows/${var.namespace}/ingest_to_bq.yml")
}

resource "kestra_flow" "push_to_git" {
  namespace = "system"
  flow_id = "push_to_git"
  content = file("flows/system/push_to_git.yml")
}