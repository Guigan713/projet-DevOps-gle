provider "aws" {
  region = var.region
}

module "s3_backup" {
  source         = "./modules/s3_backup"
  project_name = var.project_name
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  # public_subnet_cidr  = var.public_subnet_cidr
  # private_subnet_cidr = var.private_subnet_cidr
}

module "security_groups" {
  source  = "./modules/security_groups"
  vpc_id  = module.network.vpc_id
  mon_ip  = var.mon_ip
}

module "instances" {
  source            = "./modules/instances"
  ami               = var.ami
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  frontend_sg_id      = module.security_groups.frontend_sg_id
  backend_sg_id     = module.security_groups.backend_sg_id
  database_sg_id = module.security_groups.database_sg_id
  monitoring_sg_id = module.security_groups.monitoring_sg_id
  reverse_proxy_sg_id = module.security_groups.reverse_proxy_sg_id
  instance_profile_name = module.s3_backup.instance_profile_name
}

module "dns" {
  source = "./modules/dns"
  domain_name = var.domain_name
  reverse_proxy_ip = module.instances.reverse_proxy_public_ip
}

