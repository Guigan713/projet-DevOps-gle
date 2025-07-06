resource "google_compute_health_check" "swarm_health_check" {
  name     = "${var.project_name}-health-check"
  project  = var.project_id

  timeout_sec         = 10
  check_interval_sec  = 10
  healthy_threshold   = 2
  unhealthy_threshold = 5

  tcp_health_check {
    port = "80"
  }

  log_config {
    enable = true
  }
}

resource "google_compute_instance_group" "swarm_nodes" {
  name        = "${var.project_name}-nodes"
  description = "Instance group for Docker Swarm nodes"
  zone        = var.zone
  project     = var.project_id

  instances = var.manager_instances

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  named_port {
    name = "traefik-api"
    port = "8080"
  }
}

resource "google_compute_backend_service" "swarm_backend" {
  name        = "${var.project_name}-backend"
  description = "Backend service for Docker Swarm"
  project     = var.project_id

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  health_checks = [google_compute_health_check.swarm_health_check.id]

  backend {
    group           = google_compute_instance_group.swarm_nodes.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  # Configuration pour passer les headers originaux
  custom_request_headers = [
    "X-Forwarded-Proto: $scheme",
    "X-Real-IP: $remote_addr"
  ]
}

resource "google_compute_url_map" "swarm_url_map" {
  name            = "${var.project_name}-url-map"
  description     = "URL map for Docker Swarm"
  project         = var.project_id

  default_service = google_compute_backend_service.swarm_backend.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "swarm_http_proxy" {
  name    = "${var.project_name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.swarm_url_map.id
}


resource "google_compute_managed_ssl_certificate" "swarm_ssl_cert_new" {
  name    = "${var.project_name}-ssl-cert-with-traefik"
  project = var.project_id

  managed {
    domains = [
      "sneakerportfolio.eu",
      "api.sneakerportfolio.eu", 
      "grafana.sneakerportfolio.eu",
      "prometheus.sneakerportfolio.eu",
      "traefik.sneakerportfolio.eu"
    ]
  }
}

resource "google_compute_target_https_proxy" "swarm_https_proxy" {
  name    = "${var.project_name}-https-proxy"  
  project = var.project_id
  url_map = google_compute_url_map.swarm_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.swarm_ssl_cert_new.id]
}

# Forwarding Rule HTTP (port 80)
resource "google_compute_global_forwarding_rule" "swarm_http" {
  name       = "${var.project_name}-http-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_http_proxy.swarm_http_proxy.id
  port_range = "80"
  ip_address = var.swarm_lb_ip
}

# Forwarding Rule HTTPS (port 443)
resource "google_compute_global_forwarding_rule" "swarm_https" {
  name       = "${var.project_name}-https-forwarding-rule"
  project    = var.project_id  
  target     = google_compute_target_https_proxy.swarm_https_proxy.id
  port_range = "443"
  ip_address = var.swarm_lb_ip
}