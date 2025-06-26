resource "google_dns_managed_zone" "swarm_zone" {
  name        = "${replace(var.domain_name, ".", "-")}-zone"
  dns_name    = "${var.domain_name}."
  description = "Zone DNS pour Docker Swarm - ${var.domain_name}"
  project     = var.project
}

resource "google_dns_record_set" "swarm_a_record" {
  name         = "${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}

resource "google_dns_record_set" "swarm_www_record" {
  name         = "www.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}

resource "google_dns_record_set" "api_record" {
  count        = var.create_api_subdomain ? 1 : 0
  name         = "api.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}

# resource "google_dns_record_set" "admin_record" {
#   count        = var.create_admin_subdomain ? 1 : 0
#   name         = "admin.${var.domain_name}."
#   managed_zone = google_dns_managed_zone.swarm_zone.name
#   type         = "A"
#   ttl          = 300
#   rrdatas      = [var.swarm_lb_ip]
# }

variable "subdomains" {
  default = ["grafana", "prometheus", "traefik"]
}

resource "google_dns_record_set" "service_records" {
  count        = length(var.subdomains)
  name         = "${var.subdomains[count.index]}.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}
