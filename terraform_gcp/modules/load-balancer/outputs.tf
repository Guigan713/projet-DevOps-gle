output "swarm_lb_ip" {
  description = "IP address of the load balancer"
  value = var.swarm_lb_ip
}

output "backend_service_id" {
  description = "ID of the backend service"
  value       = google_compute_backend_service.swarm_backend.id
}

output "backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.swarm_backend.name
}

output "health_check_id" {
  description = "ID of the health check"
  value       = google_compute_health_check.swarm_health_check.id
}

output "instance_group_id" {
  description = "ID of the instance group"
  value       = google_compute_instance_group.swarm_nodes.id
}

output "forwarding_rules" {
  description = "Forwarding rules information"
  value = {
    http = {
      name = google_compute_global_forwarding_rule.swarm_http.name
      ip   = google_compute_global_forwarding_rule.swarm_http.ip_address
      port = google_compute_global_forwarding_rule.swarm_http.port_range
    }
    https = {
      name = google_compute_global_forwarding_rule.swarm_https.name
      ip   = google_compute_global_forwarding_rule.swarm_https.ip_address
      port = google_compute_global_forwarding_rule.swarm_https.port_range
    }
  }
}

output "url_map_id" {
  description = "ID of the URL map"
  value       = google_compute_url_map.swarm_url_map.id
}

output "proxies" {
  description = "HTTP and HTTPS proxy information"
  value = {
    http_proxy = {
      name = google_compute_target_http_proxy.swarm_http_proxy.name
      id   = google_compute_target_http_proxy.swarm_http_proxy.id
    }
    https_proxy = {
      name = google_compute_target_https_proxy.swarm_https_proxy.name
      id   = google_compute_target_https_proxy.swarm_https_proxy.id
    }
  }
}

output "ssl_certificate" {
  description = "SSL certificate information"
  value = {
    name    = google_compute_managed_ssl_certificate.swarm_ssl_cert_new.name
    id      = google_compute_managed_ssl_certificate.swarm_ssl_cert_new.id
    domains = google_compute_managed_ssl_certificate.swarm_ssl_cert_new.managed[0].domains
  }
}