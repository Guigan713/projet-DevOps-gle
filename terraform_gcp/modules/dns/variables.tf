variable "project" {
    description = "ID du projet gcp"
    type = string
}

variable "domain_name" {
    description = "nom de domaine du projet"
    type = string
}

variable "swarm_lb_ip" {
  description = "IP du Load Balancer Swarm"
  type        = string
}

variable "create_api_subdomain" {
  description = "Créer un sous-domaine api.domain.com"
  type        = bool
  default     = false
}