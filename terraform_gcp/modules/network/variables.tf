variable "project" {
  description = "Le projet GCP à utiliser"
  type        = string
}

variable "region" {
  description = "La région GCP où déployer les ressources"
  type        = string
  default     = "europe-west1"
}

variable "vpc_cidr" {
  description = "Le CIDR du réseau VPC"
  type        = string
  # default     = "10.0.0.0/16"
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
