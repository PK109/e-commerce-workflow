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

# resource "google_compute_instance" "default" {
#   name         = var.vm_name
#   machine_type = var.vm_standard_type
#   zone         = "${var.location}-c"


#   boot_disk {
#     initialize_params {
#       image = var.vm_standard_os
#       size = 50
#       type  = "pd-balanced"
#     }
#     mode = "READ_WRITE"
#   }
  
#   network_interface {
#     network = "default"
#     access_config {
#       network_tier = "PREMIUM"
#     }
#   }

#   service_account {
#     email  = "de-zoomcamp@fleet-aleph-447822-a2.iam.gserviceaccount.com"
#     scopes = ["https://www.googleapis.com/auth/devstorage.read_only",
#      "https://www.googleapis.com/auth/logging.write",
#      "https://www.googleapis.com/auth/monitoring.write",
#      "https://www.googleapis.com/auth/service.management.readonly",
#      "https://www.googleapis.com/auth/servicecontrol",
#      "https://www.googleapis.com/auth/trace.append"]
#   }

#   ## installation script for Docker
#   metadata = {
#       startup-script = "sudo apt-get install ca-certificates curl\nsudo install -m 0755 -d /etc/apt/keyrings\nsudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc\nsudo chmod a+r /etc/apt/keyrings/docker.asc\necho \\\n      \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \\\n      $(. /etc/os-release && echo \"$${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable\" | \\\nsudo tee /etc/apt/sources.list.d/docker.list > /dev/null\nsudo apt-get update    \nsudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\necho \"Cloning repo\"\ngit clone $${var.repo_url} e-commerce_project\ncd e-commerce_project/Docker"
#     }
# }

# This code is compatible with Terraform 4.25.0 and versions that are backward compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration
# resource "google_compute_instance" "instance-20250206-043904" {
#   boot_disk {
#     auto_delete = true
#     device_name = "instance-20250206-043904"

#     initialize_params {
#       image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250128"
#       size  = 50
#       type  = "pd-balanced"
#     }

#     mode = "READ_WRITE"
#   }

#   can_ip_forward      = false
#   deletion_protection = false
#   enable_display      = false

#   labels = {
#     goog-ec-src = "vm_add-tf"
#   }

#   name         = var.vm_name
#   machine_type = var.vm_standard_type
#   zone         = "${var.location}-c"
#   network_interface {
#     access_config {
#       network_tier = "PREMIUM"
#     }

#     queue_count = 0
#     stack_type  = "IPV4_ONLY"
#     subnetwork  = "default"
#   }

#   scheduling {
#     automatic_restart   = true
#     on_host_maintenance = "MIGRATE"
#     preemptible         = false
#     provisioning_model  = "STANDARD"
#   }

#   service_account {
#     email  = "de-zoomcamp@fleet-aleph-447822-a2.iam.gserviceaccount.com"
#     scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
#   }

#   shielded_instance_config {
#     enable_integrity_monitoring = true
#     enable_secure_boot          = false
#     enable_vtpm                 = true
#   }

#   metadata = {
#       startup-script = "mkdir dosth\necho \"Cloning repo\"\ngit clone ${var.repo_url} e-commerce_project\nsudo apt-get install ca-certificates curl\nsudo install -m 0755 -d /etc/apt/keyrings\nsudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc\nsudo chmod a+r /etc/apt/keyrings/docker.asc\necho \"deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$${UBUNTU_CODENAME:-$$VERSION_CODENAME}\") stable\" | \\\nsudo tee /etc/apt/sources.list.d/docker.list > /dev/null\nsudo apt-get update\nsudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\ncd e-commerce_project/Docker"
#     }
# }

# This code is compatible with Terraform 4.25.0 and versions that are backward compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration
resource "time_static" "deployment" {}

output "deployment_epoch" {
  value = time_static.deployment.unix
}
output "vm_static_ip" {
  value = google_compute_address.static_ip.address
  description = "The external static IP assigned to the VM"
}

resource "google_compute_instance" "instance-20250206-053211" {
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

  # metadata_startup_script = "#! /bin/bash\necho $(pwd)\nmkdir dosth\ncd dosth\necho $(pwd)\ngit clone https://github.com/PK109/DataEngineering-2025.git e-commerce_project"
  # metadata = {
  #   startup-script = "#! /bin/bash\nmkdir dosth\ngit clone https://github.com/PK109/DataEngineering-2025.git e-commerce_project"
    # \nsudo apt-get update\nsudo apt-get install ca-certificates curl\nsudo install -m 0755 -d /etc/apt/keyrings\nsudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc\nsudo chmod a+r /etc/apt/keyrings/docker.asc\necho \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null\nsudo apt-get update\nsudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
  # }
  metadata_startup_script = <<-EOT
  #!/bin/bash
  set -x
  git clone https://github.com/PK109/DataEngineering-2025.git /home/${var.vm_user}/e-commerce_project
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


