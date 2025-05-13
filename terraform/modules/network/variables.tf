variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR du sous-réseau public"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR du sous-réseau privé"
  type        = string
}
