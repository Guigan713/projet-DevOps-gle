output "name_servers" {
    description = "Serveurs de noms à configurer chez votre registrar"
    value = aws_route53_zone.my_zone.name_servers
}

output "dns_name" {
  description = "Nom de la zone DNS"
  value       = aws_route53_zone.my_zone.name
}


output "zone_id" {
  description = "ID de la zone Route 53"
  value       = aws_route53_zone.my_zone.zone_id
}