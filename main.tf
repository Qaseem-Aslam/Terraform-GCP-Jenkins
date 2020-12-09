# Remote State
terraform {
  backend "remote" {
    organization = "Singhventures"
    workspaces {
      name = "Terraform-GCP-Jenkins"
    }
  }
}

# Firewall
resource "google_compute_firewall" "www" {
  name = "tf-www-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["8080", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Master startup script
data "template_file" "masterscript" {
  template = file("./template/master.sh.tpl")
  vars = {
    j_admin_user = var.j_admin_user
    j_admin_password = var.j_admin_password
    j_url = google_compute_address.static.address  
    jenkins_upload = var.jenkins_upload  
  }
}

# Static IP for Jenkins
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

# Jenkins Config
data "template_file" "jenkinsconfig" {
  template = file("./template/jenkins.yml.tpl")
  vars = {
    j_admin_user = var.j_admin_user
    j_admin_password = var.j_admin_password
    gh_admin_user = var.gh_admin_user
    gh_admin_password = var.gh_admin_password
    dh_admin_user = var.dh_admin_user
    dh_admin_password = var.dh_admin_password
    j_url = google_compute_address.static.address
    secretBytes = filebase64(var.kubeconfig) 
  }
}

# Master resource
resource "google_compute_instance" "jenkins_master" {
  name = "${var.cluster_name}-master"
  machine_type = var.machine_type
  zone = "${var.region}-b"
  tags = [var.cluster_name]
  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }  
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.pub_key)}"
  }
  connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(var.private_key)
      host = google_compute_address.static.address
    } 
  provisioner "file" {
    content = data.template_file.jenkinsconfig.rendered
    destination = "/${var.jenkins_upload}/jenkins.yml" 
  }
  provisioner "file" {
    source = var.kubeconfig
    destination = "/${var.jenkins_upload}/kubeconfig" 
  }  
  metadata_startup_script = data.template_file.masterscript.rendered
}