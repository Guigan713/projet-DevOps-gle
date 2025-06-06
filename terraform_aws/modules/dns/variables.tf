variable "region" {
    description = "Région AWS"
    type        = string
}

variable "domain_name" {
    description = "nom de domaine du projet"
    type = string
}

variable "reverse_proxy_ip" {
    type = string
}