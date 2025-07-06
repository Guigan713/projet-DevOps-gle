resource "null_resource" "generate_swarm_config" {
  triggers = {
    # Se déclenche à chaque changement d'infrastructure
    swarm_managers = join(",", module.instances.swarm_manager_ips)
    swarm_workers  = join(",", module.instances.swarm_worker_ips)
    swarm_lb_ip    = module.load-balancer.swarm_lb_ip
    leader_ip      = module.instances.swarm_leader_ip
    bastion_public_ip = module.instances.bastion_public_ip
    always_run     = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo " Génération des fichiers de configuration Swarm..."
      
      # Rendre les scripts exécutables
      chmod +x ./generate_hosts.sh
      chmod +x ./generate_ssh_config.sh  
      
      # Exécuter les scripts
      ./generate_hosts.sh
      ./generate_ssh_config.sh
      
      echo " Configuration Swarm générée avec succès !"
    EOT
    working_dir = path.module
  }

  depends_on = [
    module.instances,
    module.network,
    module.security_groups
  ]
}