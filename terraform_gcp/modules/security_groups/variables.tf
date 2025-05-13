variable "vpc_id" {
  description = "ID du VPC auquel les security groups sont rattachés"
  type        = string
}

variable "mon_ip" {
  description = "Ton IP publique autorisée à accéder à SSH et aux outils de monitoring"
  type        = string
}