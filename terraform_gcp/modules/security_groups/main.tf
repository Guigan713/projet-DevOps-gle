resource "google_compute_firewall" "swarm_manager_ssh" {
  name    = "swarm-manager-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["swarm-manager"]
}

# SSH from managers to all nodes (bastion)
resource "google_compute_firewall" "swarm_internal_ssh" {
  name    = "swarm-internal-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["swarm-manager"]
  target_tags = ["swarm-node"]
}

# Communication interne simplifiée
resource "google_compute_firewall" "swarm_internal_communication" {
  name    = "swarm-internal-communication"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["2377", "7946"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["4789", "7946"]
  }
  
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr
  ]
  target_tags = ["swarm-node"]
}

# Ports spécifiques Docker Swarm
resource "google_compute_firewall" "swarm_cluster_ports" {
  name    = "swarm-cluster-ports"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["2377", "7946"]  # Cluster management + node communication
  }
  
  allow {
    protocol = "udp"
    ports    = ["4789", "7946"]  # Overlay network + node communication
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr
  ]
  target_tags = ["swarm-node"]
}

# HTTP/HTTPS externe
resource "google_compute_firewall" "swarm_web_ingress" {
  name    = "swarm-web-ingress"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["swarm-manager"]  # Load balancer sur managers
}

# Monitoring accès externe (Grafana, Prometheus via Swarm)
resource "google_compute_firewall" "swarm_monitoring" {
  name    = "swarm-monitoring"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090", "9093"]  # Grafana, Prometheus, Alertmanager
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["swarm-manager"]
}

# Egress
resource "google_compute_firewall" "swarm_outbound" {
  name      = "swarm-outbound"
  network   = var.vpc_name
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags       = ["swarm-node"]
}