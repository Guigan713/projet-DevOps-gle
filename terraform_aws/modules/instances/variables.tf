variable "ami" {
  description = "ID de l'AMI à utiliser pour les instances EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "ID du sous-réseau public"
  type        = string
}

variable "private_subnet_id" {
  description = "ID du sous-réseau privé"
  type        = string
}

variable "reverse_proxy_sg_id" {
  description = "ID du security group Reverse-proxy"
  type = string
}

variable "frontend_sg_id" {
  description = "ID du security group public"
  type        = string
}

variable "backend_sg_id" {
  description = "ID du security group privé"
  type        = string
}

variable "database_sg_id" {
  description = "ID du security group privé"
  type        = string
}

variable "monitoring_sg_id" {
  description = "ID du security group privé"
  type        = string
}

variable "instance_profile_name" {
  type = string
}