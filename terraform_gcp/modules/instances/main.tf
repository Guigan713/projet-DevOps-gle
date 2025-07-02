# IP statique pour le Load Balancer
resource "google_compute_address" "swarm_lb_ip" {
  name    = "swarm-lb-ip"
  region  = var.region
  project = var.project
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
    
    dynamic "access_config" {
      for_each = count.index == 0 ? [1] : []
      content {
        nat_ip = google_compute_address.swarm_lb_ip.address
      }
    }
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

