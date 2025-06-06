resource "google_compute_instance" "frontend" {
    name = "frontend"
    machine_type = "e2-micro"
    zone = var.zone

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    network_interface {
        network = var.vpc_id
        subnetwork = var.private_subnet_id
    }

    tags = ["frontend"]
}

resource "google_compute_address" "reverse_proxy_ip" {
  name = "reverse-proxy-ip"
  region = var.region
  project = var.project
}

resource "google_compute_instance" "reverse_proxy" {
  name         = "reverse-proxy"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.public_subnet_id
    
    # for reserved static ip
    access_config {
      nat_ip = google_compute_address.reverse_proxy_ip.address
    }
  }


  tags = ["reverse-proxy"]
}


resource "google_compute_instance" "backend" {
  name         = "backend"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.private_subnet_id
  }

  tags = ["backend"]
}


resource "google_compute_instance" "database" {
  name         = "database-mysql"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.private_subnet_id
  }

  tags = ["database"]
}

resource "google_compute_instance" "monitoring" {
  name         = "monitoring"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.private_subnet_id
  }

  tags = ["monitoring"]
}

# resource "null_resource" "generate_ansible_inventory" {
#     triggers = {
#       # Se déclenche à chaque terraform apply
#       always_run = timestamp()
#     }

#     provisioner "local-exec" {
#       command = "./generate_hosts.sh"
#       working_dir = path.module
#     }

#     depends_on = [
#       google_compute_instance.frontend,
#       google_compute_instance.reverse_proxy,
#       google_compute_instance.backend,
#       google_compute_instance.database,
#       google_compute_instance.monitoring
#     ]
# }