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

variable "public_sg_id" {
  description = "ID du security group public"
  type        = string
}

variable "private_sg_id" {
  description = "ID du security group privé"
  type        = string
}

variable "instance_profile_name" {
  type = string
}