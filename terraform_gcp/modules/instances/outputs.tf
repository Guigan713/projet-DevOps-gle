output "swarm_manager_ips" {
  description = "IPs privées des managers Swarm"
  value = google_compute_instance.swarm_manager[*].network_interface[0].network_ip
}

output "swarm_worker_ips" {
  description = "IPs privées des workers Swarm"
  value = google_compute_instance.swarm_worker[*].network_interface[0].network_ip
}

output "bastion_public_ip" {
  description = "Adresse IP publique du bastion (SSH/admin)"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "swarm_leader_ip" {
  description = "IP du premier manager"
  value = google_compute_instance.swarm_manager[0].network_interface[0].network_ip
}

output "swarm_cluster_info" {
  description = "Informations complètes du cluster Swarm"
  value = {
    managers = {
      count = length(google_compute_instance.swarm_manager)
      ips   = google_compute_instance.swarm_manager[*].network_interface[0].network_ip
      names = google_compute_instance.swarm_manager[*].name
    }
    workers = {
      count = length(google_compute_instance.swarm_worker)
      ips   = google_compute_instance.swarm_worker[*].network_interface[0].network_ip
      names = google_compute_instance.swarm_worker[*].name
    }
    leader_ip = google_compute_instance.swarm_manager[0].network_interface[0].network_ip
    bastion_ip = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
  }
}

# Self-links pour le module Load Balancer
output "swarm_manager_self_links" {
  description = "Self-links des instances manager pour le Load Balancer"
  value       = google_compute_instance.swarm_manager[*].self_link
}

output "swarm_worker_self_links" {
  description = "Self-links des instances worker pour le Load Balancer"
  value       = google_compute_instance.swarm_worker[*].self_link
}

output "all_swarm_nodes_self_links" {
  description = "Self-links de tous les nœuds Swarm (managers + workers)"
  value = concat(
    google_compute_instance.swarm_manager[*].self_link,
    google_compute_instance.swarm_worker[*].self_link
  )
}

# Instances complètes pour le Load Balancer
output "swarm_manager_instances" {
  description = "Instances complètes des managers pour le Load Balancer"
  value = [
    for instance in google_compute_instance.swarm_manager : {
      name       = instance.name
      self_link  = instance.self_link
      private_ip = instance.network_interface[0].network_ip
      zone       = instance.zone
    }
  ]
}

output "swarm_worker_instances" {
  description = "Instances complètes des workers pour le Load Balancer"
  value = [
    for instance in google_compute_instance.swarm_worker : {
      name       = instance.name
      self_link  = instance.self_link
      private_ip = instance.network_interface[0].network_ip
      zone       = instance.zone
    }
  ]
}

output "all_swarm_nodes_instances" {
  description = "Toutes les instances Swarm pour le Load Balancer"
  value = concat(
    [
      for instance in google_compute_instance.swarm_manager : {
        name       = instance.name
        self_link  = instance.self_link
        private_ip = instance.network_interface[0].network_ip
        zone       = instance.zone
        role       = "manager"
      }
    ],
    [
      for instance in google_compute_instance.swarm_worker : {
        name       = instance.name
        self_link  = instance.self_link
        private_ip = instance.network_interface[0].network_ip
        zone       = instance.zone
        role       = "worker"
      }
    ]
  )
}

output "primary_zone" {
  description = "Zone principale pour l'Instance Group"
  value = google_compute_instance.swarm_manager[0].zone
}