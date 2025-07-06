output "swarm_manager_ips" {
  description = "Adresses IP privées des managers Docker Swarm"
  value       = module.instances.swarm_manager_ips
}

output "swarm_worker_ips" {
  description = "Adresses IP privées des workers Docker Swarm"
  value       = module.instances.swarm_worker_ips
}

output "swarm_load_balancer_ip" {
  description = "IP du Load Balancer Swarm (point d'entrée principal)"
  value       = module.load-balancer.swarm_lb_ip
}

output "bastion_public_ip" {
  description = "Adresse IP publique du bastion (accès SSH uniquement)"
  value       = module.instances.bastion_public_ip
}

output "swarm_leader_ip" {
  description = "IP privée du manager leader"
  value       = module.instances.swarm_leader_ip
}

# Outputs de connexion
output "ssh_connection_manager" {
  description = "Commande SSH pour se connecter au manager leader via le bastion"
  value       = "ssh -i ~/.ssh/gcp-ssh-key -J deploy@${module.instances.bastion_public_ip} deploy@${module.instances.swarm_leader_ip}"
}

output "docker_swarm_status" {
  description = "Commande pour vérifier le statut du Swarm (via bastion)"
  value       = "ssh -i ~/.ssh/gcp-ssh-key -J deploy@${module.instances.bastion_public_ip} deploy@${module.instances.swarm_leader_ip} 'sudo docker node ls'"
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

output "swarm_cluster_info" {
  description = "Informations complètes du cluster Swarm"
  value       = module.instances.swarm_cluster_info
}

output "load_balancer_status" {
  description = "État du Load Balancer"
  value       = module.load-balancer.swarm_lb_ip
}

output "ansible_inventory" {
  description = "Variables pour générer l'inventaire Ansible"
  value = {
    bastion_public_ip = module.instances.bastion_public_ip
    swarm_manager_ips = module.instances.swarm_manager_ips
    swarm_worker_ips  = module.instances.swarm_worker_ips
    swarm_leader_ip   = module.instances.swarm_leader_ip
    lb_ip            = module.load-balancer.swarm_lb_ip
  }
}

output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    cluster_size      = length(module.instances.swarm_manager_ips) + length(module.instances.swarm_worker_ips)
    manager_count     = length(module.instances.swarm_manager_ips)
    worker_count      = length(module.instances.swarm_worker_ips)
    load_balancer_ip  = module.load-balancer.swarm_lb_ip
    backup_enabled    = true
  }
}