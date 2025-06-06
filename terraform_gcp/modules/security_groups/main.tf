resource "google_compute_firewall" "reverse_proxy_ssh" {
  name    = "reverse-proxy-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["reverse-proxy"]
}

# HTTP, HTTPS
resource "google_compute_firewall" "reverse_proxy_ingress" {
  name    = "reverse-proxy-ingress"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reverse-proxy"]
}

# Firewall rule for frontend (private subnet)
resource "google_compute_firewall" "frontend_ssh" {
  name    = "frontend-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["frontend"]
}

resource "google_compute_firewall" "backend_ssh" {
  name    = "backend-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["backend"]
}

resource "google_compute_firewall" "database_ssh" {
  name    = "database-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["database"]
}

resource "google_compute_firewall" "monitoring_ssh" {
  name    = "monitoring-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["monitoring"]
}

resource "google_compute_firewall" "monitoring_services" {
  name    = "monitoring-services"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090", "9000"]  # Grafana et Prometheus
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["monitoring"]
}

# Communication rules between services

# Reverse proxy to frontend
resource "google_compute_firewall" "reverse_proxy_to_frontend" {
  name    = "reverse-proxy-to-frontend"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_tags = ["reverse-proxy"]
  target_tags = ["frontend"]
}

# Frontend to backend
resource "google_compute_firewall" "frontend_to_backend" {
  name    = "frontend-to-backend"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_tags = ["frontend"]
  target_tags = ["backend"]
}

# Backend to database
resource "google_compute_firewall" "backend_to_database" {
  name    = "backend-to-database"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_tags = ["backend"]
  target_tags = ["database"]
}

# Admin access to database
resource "google_compute_firewall" "admin_to_database" {
  name    = "admin-to-database"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["database"]
}

# Monitoring rules

# Monitoring to all services (Node Exporter)
resource "google_compute_firewall" "monitoring_to_services_node_exporter" {
  name    = "monitoring-to-services-node-exporter"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_tags = ["monitoring"]
  target_tags = ["reverse-proxy", "frontend", "backend", "database"]
}

# Monitoring to database (MySQL exporter)
resource "google_compute_firewall" "monitoring_to_database_mysql_exporter" {
  name    = "monitoring-to-database-mysql-exporter"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["9104"]
  }

  source_tags = ["monitoring"]
  target_tags = ["database"]
}

# Reverse proxy to monitoring (Grafana)
resource "google_compute_firewall" "reverse_proxy_to_grafana" {
  name    = "reverse-proxy-to-grafana"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_tags = ["reverse-proxy"]
  target_tags = ["monitoring"]
}

# Reverse proxy to monitoring (Prometheus - only if debug needed)
resource "google_compute_firewall" "reverse_proxy_to_prometheus" {
  name    = "reverse-proxy-to-prometheus"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_tags = ["reverse-proxy"]
  target_tags = ["monitoring"]
}

# Egress rules 
resource "google_compute_firewall" "allow_outbound" {
  name      = "allow-outbound"
  network   = var.vpc_name
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags       = ["reverse-proxy", "frontend", "backend", "monitoring"]
}