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
  storage_class = var.gcs_bucket_storage_class
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
    device_name = var.vm_name

    initialize_params {
      image = var.vm_image
      size  = 80
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

  metadata_startup_script = file("./startup_script.sh")


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
    email  = var.service_account_mail
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only",
              "https://www.googleapis.com/auth/logging.write",
              "https://www.googleapis.com/auth/monitoring.write", 
              "https://www.googleapis.com/auth/service.management.readonly", 
              "https://www.googleapis.com/auth/servicecontrol", 
              "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = local.zone
}


resource "google_dataproc_autoscaling_policy" "auto_scaling" {
  count = local.dataproc_enabled ? 1 : 0  # enable / disable dataproc
  policy_id = "auto-scaling-policy"
  location = var.location

  worker_config {
    max_instances = 4  
    min_instances = 2   
    weight        = 1
  }

  basic_algorithm {
    yarn_config {
      scale_up_factor   = 0.5
      scale_down_factor = 0.5
      graceful_decommission_timeout = "120s"
    }
  }
}

resource "google_dataproc_cluster" "e_commerce_cluster" {
  count = local.dataproc_enabled ? 1 : 0 # enable / disable dataproc
  name     = "e-commerce-dataproc-cluster"
  region   = var.location
  project  = var.project_id

  cluster_config {

    # Enable component gateway
    endpoint_config {
      enable_http_port_access = true
    }

    master_config {
      num_instances  = 1
      machine_type   = "e2-standard-2"
      disk_config {
        boot_disk_type    = "pd-balanced"
        boot_disk_size_gb = 40
      }
    }

    worker_config {
      machine_type = "e2-standard-2"
      num_instances = 2
      disk_config {
        boot_disk_type    = "pd-balanced"
        boot_disk_size_gb = 40
      }
    }

    software_config {
      image_version = "2.2-debian12"
      optional_components = [
        "JUPYTER",
        "DOCKER"
      ]
    }

    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.auto_scaling[0].name
    }
    

    gce_cluster_config {
      # internal_ip_only = true  
      zone = local.zone
      network = "default"

    }
  }
}


output "deployment_epoch" {
  value = time_static.deployment.unix
}
output "vm_static_ip" {
  value = google_compute_address.static_ip.address
  description = "The external static IP assigned to the VM"
}

