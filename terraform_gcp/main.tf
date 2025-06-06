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

module "instances" {
    source = "./modules/instances"
    project = var.project
    image = var.image
    private_subnet_id = module.network.private_subnet_id
    public_subnet_id = module.network.public_subnet_id
    vpc_id = module.network.vpc_id
    region = var.region
}

module "network" {
    source = "./modules/network"
    project = var.project
    private_subnet_cidr = var.private_subnet_cidr
    public_subnet_cidr = var.public_subnet_cidr
    vpc_cidr = var.vpc_cidr
    # region = var.region
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
  mon_ip = var.mon_ip
  vpc_name = module.network.vpc_name
}

module "gcp_backup" {
  source = "./modules/gcp_backup"
  project = var.project
  project_name = var.project_name
  location = var.location
}

module "dns" {
  source = "./modules/dns"
  project = var.project
  domain_name = var.domain_name
  reverse_proxy_ip = module.instances.reverse_proxy_public_ip
}