output "name_servers" {
    description = "Serveurs de noms à configurer chez votre registrar"
    value = google_dns_managed_zone.my_zone.name_servers
}

output "dns_name" {
  description = "Nom de la zone DNS"
  value       = google_dns_managed_zone.my_zone.dns_name
}