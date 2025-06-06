variable "region" {
  description = "Région AWS dans laquelle déployer l'infrastructure"
  type        = string
}

variable "vpc_cidr" {
  description = "Plage CIDR du VPC principal"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Plage CIDR du sous-réseau public"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Plage CIDR du sous-réseau privé"
  type        = string
}

variable "ami" {
  description = "ID de l'AMI à utiliser pour toutes les instances EC2"
  type        = string
}

variable "mon_ip" {
  description = "Adresse IP publique autorisée à accéder à SSH et aux services de monitoring"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}
