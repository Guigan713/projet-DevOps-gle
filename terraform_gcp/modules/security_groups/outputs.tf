output "swarm_firewall_rule_names" {
  description = "Noms des règles firewall du cluster Swarm"
  value = [
    google_compute_firewall.swarm_lb_to_nodes.name,
    google_compute_firewall.ssh_bastion_from_admin.name,
    google_compute_firewall.bastion_ssh.name,
    google_compute_firewall.swarm_internal_ssh.name,
    google_compute_firewall.swarm_internal_communication.name,
    google_compute_firewall.swarm_monitoring.name,
    google_compute_firewall.swarm_node_exporter.name,
    google_compute_firewall.swarm_outbound.name
  ]
}


output "swarm_network_tags" {
  description = "Tags réseau pour les instances Swarm"
  value = {
    manager = ["swarm-node", "swarm-manager"]
    worker  = ["swarm-node", "swarm-worker"]
    bastion = ["bastion"]
  }
}