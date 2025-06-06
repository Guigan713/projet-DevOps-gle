variable "server_ip" {
  description = "IP address of the remote server"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  description = "SSH user for the server"
  type        = string
  default     = "Guillaume713"
}

variable "domain" {
  description = "Le domaine ou sous-domaine pointant vers le Pi"
  type = string
  default     = "localhost"
}

variable "mysql_root_password" {
    description = "mot de passe root MySQL"
    type = string
    sensitive = true
}

variable "mysql_database" {
  description = "Nom de la base de données"
  type        = string
}

variable "mysql_user" {
  description = "Utilisateur MySQL"
  type        = string
}

variable "mysql_password" {
  description = "Mot de passe utilisateur MySQL"
  type        = string
  sensitive   = true
}

# variable "backend_port" {
#   description = "Port du backend"
#   type        = number
#   default     = 5000
# }

# variable "frontend_port" {
#   description = "Port du frontend"
#   type        = number
#   default     = 80
# }