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
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
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
  public_sg_id      = module.security_groups.public_sg_id
  private_sg_id     = module.security_groups.private_sg_id
  instance_profile_name = module.s3_backup.instance_profile_name
}

