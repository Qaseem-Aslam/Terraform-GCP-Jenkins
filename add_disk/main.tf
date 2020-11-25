# Remote State
terraform {
  backend "remote" {
    organization = "Singhventures"
    workspaces {
      name = "JenkinsHome"
    }
  }
}

# Persistent Storage
resource "google_compute_disk" "persistentstorage" {
  name  = var.storage_name
  type  = var.storage_type
  size = var.disk_size_gb
  zone  = "${var.region}-b"
  labels = {
    environment = var.storage_label
  }
}

# Save DiskName
resource "local_file" "diskName" {
    content     = var.storage_name
    filename = "diskName.txt"
}