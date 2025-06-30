output "swarm_firewall_rules" {
  description = "Liste des règles firewall pour Docker Swarm"
  value = [
    google_compute_firewall.swarm_manager_ssh.name,
    google_compute_firewall.swarm_internal_ssh.name,
    google_compute_firewall.swarm_internal_communication.name,
    google_compute_firewall.swarm_web_ingress.name,
    google_compute_firewall.swarm_monitoring.name,
    google_compute_firewall.swarm_outbound.name,
  ]
}

output "swarm_network_tags" {
  description = "Tags réseau pour les instances Swarm"
  value = {
    manager = ["swarm-node", "swarm-manager"]
    worker  = ["swarm-node", "swarm-worker"]
  }
}