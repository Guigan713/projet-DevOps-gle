output "name_servers" {
    description = "Serveurs de noms à configurer chez le registrar"
    value = google_dns_managed_zone.swarm_zone.name_servers
}

output "dns_name" {
  description = "Nom de la zone DNS"
  value       = google_dns_managed_zone.swarm_zone.dns_name
}

output "domain_endpoints" {
  description = "Points d'accès de l'application"
  value = {
    main  = "https://${var.domain_name}"
    www   = "https://www.${var.domain_name}"
    api   = var.create_api_subdomain ? "https://api.${var.domain_name}" : null
    # admin = var.create_admin_subdomain ? "https://admin.${var.domain_name}" : null
    grafana = "https://grafana.${var.domain_name}"
    prometheus = "https://prometheus.${var.domain_name}"
    traefik = "https://traefik.${var.domain_name}"
  }
}