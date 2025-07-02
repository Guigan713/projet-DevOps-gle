resource "google_compute_firewall" "swarm_lb_to_nodes" {
  name    = "swarm-lb-to-nodes"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  # Source = subnet privé (où est le LB interne OU [optionnel] l'IP interne du LB si connue)
  source_ranges = [var.public_subnet_cidr, var.private_subnet_cidr]
  target_tags   = ["swarm-node"]
}

resource "google_compute_firewall" "ssh_bastion_from_admin" {
  name          = "ssh-bastion-admin"
  network       = var.vpc_name
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }

  source_ranges = ["${var.mon_ip}/32"]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "bastion_ssh" {
  name    = "bastion-ssh-to-nodes"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["bastion"]
  target_tags = ["swarm-node"]
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

resource "google_compute_firewall" "swarm_node_exporter" {
  name    = "swarm-node-exporter"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_ranges = [
    var.private_subnet_cidr,
    var.public_subnet_cidr,
  ]
  target_tags   = ["swarm-node"]
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