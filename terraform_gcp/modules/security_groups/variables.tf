variable "vpc_id" {
  description = "ID du VPC auquel les security groups sont rattachés"
  type        = string
}

variable "mon_ip" {
  description = "IP publique perso"
  type        = string
}

variable "vpc_name" {
  description = "Nom du VPC"
  type = string
}

variable "public_subnet_cidr" {
  description = "Le CIDR du subnet public"
  type        = string
  # default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Le CIDR du subnet privé"
  type        = string
  # default     = "10.0.2.0/24"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "project" {
  description = "ID du projet GCP"
  type        = string
}