variable "credentials" {
    description = "My GCP credentials file."
    default = "/workspaces/e-commerce-workflow/.ssh/gcp-credentials.json"
}

variable "project_id" {
  default = "e-commerce-validation"
}

variable "service_account_mail" {
  default = "terraform-service-account@e-commerce-validation.iam.gserviceaccount.com"
  description = "Mail of service account that will handle startup script."
  
}

variable "bq_dataset_name" {
  description = "BigQuery dataset Name"
  default     = "e_commerce_dataset"
}

variable "vm_name" {
  description = "Virtual Machine Name"
  default = "e-commerce-orchestrator"
}

variable "location" {
  default = "europe-west3"
}

variable "vm_standard_type" {
  description = "Default type of VM created"
  default = "e2-standard-2"
}
variable "vm_image" {
  description = "Default OS of VM created"
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250128"
}

variable "project_repo_url" {
    description = "URL address to the repo containing this project. Should be publicly available to avoid working with GitHub tokens."
    default = "https://github.com/PK109/e-commerce-workflow.git"
}

variable "vm_user" {
  description = "Name of user that will connect to the VM. Can be obtained as the last word in the public SSH key."
  default = "przemek"
}

variable "gcs_bucket_storage_class" {
  default = "STANDARD"
}

locals {
  gcs_bucket_name = "${var.project_id}-e_commerce_storage"
  zone = "${var.location}-c"
  dataproc_enabled = false
}