resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network             = var.vpc_id
    subnetwork          = var.public_subnet_id
    access_config {} 
  }
  metadata = {
    ssh-keys = "deploy:${file(var.ssh_public_key_path)}"
  }
}


# Swarm Managers
resource "google_compute_instance" "swarm_manager" {
  count        = var.swarm_manager_count
  name         = "swarm-manager-${count.index + 1}"
  machine_type = var.manager_machine_type
  zone         = var.zone

  can_ip_forward = true
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20 
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.private_subnet_id
  }

  metadata = {
    ssh-keys = "deploy:${file(var.ssh_public_key_path)}"
  }

  tags = ["swarm-node", "swarm-manager"]
}

# Swarm Workers
resource "google_compute_instance" "swarm_worker" {
  count        = var.swarm_worker_count
  name         = "swarm-worker-${count.index + 1}"
  machine_type = var.worker_machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.private_subnet_id
  }

  metadata = {
    ssh-keys = "deploy:${file(var.ssh_public_key_path)}"
  }

  tags = ["swarm-node", "swarm-worker"]
}

