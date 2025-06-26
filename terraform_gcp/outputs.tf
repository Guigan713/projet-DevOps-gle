output "swarm_manager_ips" {
  description = "Adresses IP privées des managers Docker Swarm"
  value       = module.instances.swarm_manager_ips
}

output "swarm_manager_public_ips" {
  description = "Adresses IP publiques des managers Docker Swarm"
  value       = [module.instances.swarm_leader_public_ip]
}

output "swarm_worker_ips" {
  description = "Adresses IP privées des workers Docker Swarm"
  value       = module.instances.swarm_worker_ips
}

output "swarm_load_balancer_ip" {
  description = "IP du Load Balancer Swarm (point d'entrée principal)"
  value       = module.instances.swarm_lb_ip
}


output "swarm_leader_ip" {
  description = "IP privée du manager leader"
  value       = module.instances.swarm_leader_ip
}

# Outputs de connexion
output "ssh_connection_manager" {
  description = "Commande SSH pour se connecter au manager leader"
  value       = "ssh -i ~/.ssh/gcp-ssh-key deploy@${module.instances.swarm_leader_public_ip}"
}

output "docker_swarm_status" {
  description = "Commande pour vérifier le statut du Swarm"
  value       = "ssh -i ~/.ssh/gcp-ssh-key deploy@${module.instances.swarm_leader_public_ip} 'sudo docker node ls'"
}

# Outputs réseau (compatibilité)
output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "ID du subnet public"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "ID du subnet privé"
  value       = module.network.private_subnet_id
}

# Outputs backup
output "backup_bucket_name" {
  description = "Nom du bucket de backup"
  value       = module.gcp_backup.bucket_name
}

output "backup_bucket_url" {
  description = "URL du bucket de backup"
  value       = module.gcp_backup.bucket_url
}

# Outputs DNS 
output "domain_name_servers" {
  description = "Serveurs de noms à configurer chez votre registrar"
  value       = var.enable_dns ? module.dns[0].name_servers : null
}

output "domain_dns_name" {
  description = "Nom de la zone DNS"
  value       = var.enable_dns ? module.dns[0].dns_name : null
}

output "application_urls" {
  description = "URLs d'accès à l'application"
  value = var.enable_dns ? {
    main  = "https://${var.domain_name}"
    www   = "https://www.${var.domain_name}"
    api   = var.create_api_subdomain ? "https://api.${var.domain_name}" : null
    grafana = "https://grafana.${var.domain_name}"
    prometheus = "https://prometheus.${var.domain_name}"
    traefik = "https://traefik.${var.domain_name}"
  } : {
    main = "http://${module.instances.swarm_lb_ip}"
    api  = "http://${module.instances.swarm_lb_ip}/api"
    grafana = "http://${module.instances.swarm_lb_ip}/grafana"
    prometheus = "http://${module.instances.swarm_lb_ip}/prometheus"
    traefik = "http://${module.instances.swarm_lb_ip}/traefik"
  }
}

# Outputs monitoring (conditionnels)
# output "monitoring_urls" {
#   description = "URLs des outils de monitoring"
#   value = var.enable_monitoring ? {
#     grafana    = var.enable_dns ? "https://monitoring.${var.domain_name}:3000" : "http://${module.swarm.load_balancer_ip}:3000"
#     prometheus = var.enable_dns ? "https://monitoring.${var.domain_name}:9090" : "http://${module.swarm.load_balancer_ip}:9090"
#   } : null
# }

# Outputs de déploiement
output "deployment_commands" {
  description = "Commandes pour déployer vos services"
  value = {
    stack_deploy = "docker stack deploy -c docker-compose.yml myapp"
    stack_ls     = "docker stack ls"
    service_ls   = "docker service ls"
    node_ls      = "docker node ls"
  }
}