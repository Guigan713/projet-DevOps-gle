# Health checks du Load Balancer GCP
resource "google_compute_firewall" "lb_health_check" {
  name    = "${var.project_name}-lb-health-check"
  network = var.vpc_name
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Ranges IP spécifiques aux health checks GCP 
  source_ranges = [
    "130.211.0.0/22",  # Google Load Balancer health check ranges
    "35.191.0.0/16",   # Google Load Balancer health check ranges
    "35.235.240.0/20"  # Additional GCP health check range
  ]

  target_tags = ["swarm-node"]
  description = "Allow health checks from GCP Load Balancer"
}

resource "google_compute_firewall" "swarm_lb_to_nodes" {
  name    = "swarm-lb-to-nodes"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

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

resource "google_compute_firewall" "github_actions" {
  name    = "allow-github-actions"
  network = var.vpc_name
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    # GitHub Actions runner IP ranges (les principales plages)
    "4.148.0.0/16",
    "4.149.0.0/16", 
    "4.150.0.0/16",
    "4.151.0.0/16",
    "4.152.0.0/15",
    "4.154.0.0/15",
    "4.156.0.0/15",
    "4.175.0.0/16",
    "4.180.0.0/16",
    "4.207.0.0/16",
    "4.208.0.0/15",
    "13.64.0.0/16",
    "13.65.0.0/16",
    "13.66.0.0/16",
    "13.67.0.0/16",
    "13.68.0.0/16",
    "13.69.0.0/16",
    "13.70.0.0/16",
    "13.71.0.0/16",
    "13.72.0.0/16",
    "13.73.0.0/16",
    "13.74.0.0/16",
    "13.75.0.0/16",
    "20.40.0.0/13",
    "20.48.0.0/12",
    "20.64.0.0/10",
    "20.128.0.0/16",
    "40.64.0.0/10",
    "52.224.0.0/11",
    "52.152.0.0/13",
    "52.160.0.0/11",
    "52.192.0.0/11"
  ]

  target_tags = ["swarm-node", "bastion", "swarm-manager"]
  description = "Allow SSH access from GitHub Actions runners IPs only"
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