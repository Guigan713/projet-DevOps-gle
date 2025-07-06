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
    "3.16.15.0/28",
    "13.68.0.0/18",
    "13.75.0.0/16",
    "20.40.0.0/13",
    "40.83.0.0/16",
    "40.92.0.0/15",
    "40.107.0.0/16",
    "52.191.0.0/16",
    "52.192.0.0/14",
    "52.220.191.128/26",
    "52.223.128.0/18",
  ]

  target_tags = ["swarm-node", "bastion", "swarm-manager"]
  description = "Allow access from GitHub Actions runners IPs"
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