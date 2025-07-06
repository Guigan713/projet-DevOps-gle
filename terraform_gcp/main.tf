terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "google" {
  credentials = file("credentials/gcp-sa-key.json")
  project = var.project
  region = var.region
  zone = var.zone
}

resource "google_compute_global_address" "swarm_lb_ip" {
  name         = "${var.project_name}-lb-ip"
  project      = var.project
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

module "instances" {
  source = "./modules/instances"

  project = var.project
  region  = var.region
  zone    = var.zone
  image   = var.image
  
  # Réseau
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  
  # Configuration Swarm
  swarm_manager_count  = var.swarm_manager_count
  swarm_worker_count   = var.swarm_worker_count
  manager_machine_type = var.manager_machine_type
  worker_machine_type  = var.worker_machine_type
  
  # SSH
  ssh_public_key_path = var.ssh_public_key_path
  
  depends_on = [module.network, module.security_groups]
}

module "network" {
  source = "./modules/network"
  
  project             = var.project
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  region              = var.region
}

module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id              = module.network.vpc_id
  vpc_name            = module.network.vpc_name
  mon_ip              = var.mon_ip
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  project_name = var.project_name
  project = var.project
  
  depends_on = [module.network]
}


module "gcp_backup" {
  source = "./modules/gcp_backup"

  project      = var.project
  project_name = var.project_name
  location     = var.location
  
  # Options Swarm
  storage_class         = var.storage_class
  backup_retention_days = var.backup_retention_days
  environment          = var.environment
}

# Module Load Balancer
module "load-balancer" {
  source = "./modules/load-balancer"

  project_id   = var.project
  project_name = "projet-devops-gle"
  zone         = var.zone

  swarm_lb_ip = google_compute_global_address.swarm_lb_ip.address
  manager_instances = module.instances.swarm_manager_self_links
  worker_instances  = module.instances.swarm_worker_self_links

  depends_on = [
    module.instances,
    module.network
  ]
}