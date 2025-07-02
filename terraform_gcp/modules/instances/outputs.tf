output "swarm_manager_ips" {
  description = "IPs privées des managers Swarm"
  value = google_compute_instance.swarm_manager[*].network_interface[0].network_ip
}

output "swarm_worker_ips" {
  description = "IPs privées des workers Swarm"
  value = google_compute_instance.swarm_worker[*].network_interface[0].network_ip
}

output "swarm_lb_ip" {
  description = "IP publique du Load Balancer Swarm"
  value = google_compute_address.swarm_lb_ip.address
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
    lb_ip     = google_compute_address.swarm_lb_ip.address
    bastion_ip = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
  }
}