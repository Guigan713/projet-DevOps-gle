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
        subnetwork = var.public_subnet_id
    }

    tags = ["frontend"]
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