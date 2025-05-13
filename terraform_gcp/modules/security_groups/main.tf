resource "google_compute_firewall" "public_ssh" {
    name = "public_allow_ssh"
    network = var.network
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    source_ranges = ["${var.mon_ip}/32"]
}

resource "google_compute_firewall" "public_http" {
  name    = "public-allow-http"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "public_https" {
  name    = "public-allow-https"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "public_egress" {
  name    = "public-allow-egress"
  network = var.network
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "private_3000" {
  name    = "private-allow-3000"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
  source_ranges = ["${var.mon_ip}/32"]
}

resource "google_compute_firewall" "private_9090" {
  name    = "private-allow-9090"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }
  source_ranges = ["${var.mon_ip}/32"]
}

resource "google_compute_firewall" "private_9000" {
  name    = "private-allow-9000"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
  source_ranges = ["${var.mon_ip}/32"]
}

resource "google_compute_firewall" "private_egress" {
  name    = "private-allow-egress"
  network = var.network
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "private_mysql" {
  name    = "private-mysql"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_tags = ["private"]
  target_tags = ["private"]
}

resource "google_compute_firewall" "public_to_private_http" {
  name    = "public-to-private-http"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_tags = ["public"]
  target_tags = ["private"]
}

resource "google_compute_firewall" "public_to_private_ssh" {
  name    = "public-to-private-ssh"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["public"]
  target_tags = ["private"]
}

resource "google_compute_firewall" "public_egress_to_private" {
  name    = "public-egress-to-private"
  network = var.network
  direction = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["private"]
  source_tags = ["public"]
}
