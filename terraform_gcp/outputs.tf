output "frontend_ip" {
  description = "Adresse IP publique de l'instance frontend"
  value       = module.instances.frontend_private_ip
}

output "reverse_proxy_ip" {
  description = "Adresse IP publique de l'instance reverse proxy"
  value       = module.instances.reverse_proxy_public_ip
}

output "backend_ip" {
  description = "Adresse IP privée de l'instance backend"
  value       = module.instances.backend_private_ip
}

output "database_ip" {
  description = "Adresse IP privée de l'instance MySQL"
  value       = module.instances.database_private_ip
}

output "monitoring_ip" {
  description = "Adresse IP privée de l'instance Prometheus/Grafana"
  value       = module.instances.monitoring_private_ip
}


output "bucket_name" {
  value = module.gcp_backup.bucket_name
}
