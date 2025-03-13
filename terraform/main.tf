terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.location
  credentials = var.credentials
}

resource "google_compute_address" "static_ip" {
  name   = "vm-static-ip"
  region = var.location
}

resource "time_static" "deployment" {}

resource "google_storage_bucket" "storage_bucket" {
  name          = "${local.gcs_bucket_name}-1"
  location      = var.location
  force_destroy = true
  storage_class = var.gcs_storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 // days
    }
  }

}

resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id = var.bq_dataset_name
  project    = var.project_id
  location   = var.location
}

resource "google_compute_instance" "instance-e-commerce" {
  boot_disk {
    auto_delete = true
    device_name = "instance-${time_static.deployment.unix}"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250128"
      size  = 50
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-standard-2"

  metadata_startup_script = <<-EOT
  #!/bin/bash
  set -x
  git clone ${var.repo_url} /home/${var.vm_user}/e-commerce_project
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu focal stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker
  sudo usermod -aG docker ${var.vm_user}
  newgrp docker
  cd /home/${var.vm_user}/e-commerce_project
  cp sample.env .env
  set +x
  EOT

  name = "instance-${time_static.deployment.unix}"

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
         nat_ip = google_compute_address.static_ip.address  # Assign the static IP
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "de-zoomcamp@fleet-aleph-447822-a2.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = local.zone
}


output "deployment_epoch" {
  value = time_static.deployment.unix
}
output "vm_static_ip" {
  value = google_compute_address.static_ip.address
  description = "The external static IP assigned to the VM"
}

