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

data "local_file" "diskName" {
    filename = "./add_disk/${var.diskNameFile}"
}

# Master startup script
data "template_file" "masterscript" {
  template = file("./template/master.sh.tpl")
  vars = {
    js_uuid = var.js_uuid
    mnt_drive_id = var.mnt_drive_id
    mnt_drive_name = data.local_file.diskName.content
  }
}

# Jenkins Config
data "template_file" "jenkinsconfig" {
  template = file("./template/jenkins.yml.tpl")
  vars = {
    j_admin_user = var.j_admin_user
    j_admin_password = var.j_admin_password
    gh_admin_user = var.gh_admin_user
    gh_admin_password = var.gh_admin_password
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
  attached_disk {
    source=data.local_file.diskName.content
  }     
  network_interface {
    network = "default"
    access_config {}
  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.pub_key)}"
  }

  provisioner "file" {
    content = data.template_file.jenkinsconfig.rendered
    destination = "/tmp/jenkins.yml" 
    connection {
        type = "ssh"
        user = var.ssh_user
        private_key = file(var.private_key)
        host = self.network_interface[0].access_config[0].nat_ip
      }  
  }

  metadata_startup_script = data.template_file.masterscript.rendered
  
}

output "secret" {
  value = data.template_file.masterscript.rendered
}