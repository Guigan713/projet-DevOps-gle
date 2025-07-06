variable "project" {
  description = "ID du projet GCP"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west1"
}

variable "location" {
  description = "Location pour les ressources régionales"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "europe-west1-b"
}

variable "image" {
  description = "Image OS pour les instances"
  type        = string
  default     = "debian-cloud/debian-12"
}

# network vars
variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé"
  type        = string
  default     = "10.0.2.0/24"
}

variable "mon_ip" {
  description = "Votre adresse IP publique"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique"
  type        = string
  default     = "~/.ssh/gcp-ssh-key.pub"
}

# swarm vars
variable "swarm_manager_count" {
  description = "Nombre de managers Swarm"
  type        = number
  default     = 3
  validation {
    condition     = var.swarm_manager_count % 2 == 1 && var.swarm_manager_count >= 1
    error_message = "Le nombre de managers doit être impair (1, 3, 5, etc.) pour le quorum."
  }
}

variable "swarm_worker_count" {
  description = "Nombre de workers Swarm"
  type        = number
  default     = 2
}

variable "manager_machine_type" {
  description = "Type de machine pour les managers"
  type        = string
  default     = "e2-medium"
}

variable "worker_machine_type" {
  description = "Type de machine pour les workers"
  type        = string
  default     = "e2-standard-2"
}

variable "enable_auto_scaling" {
  description = "Activer l'auto-scaling des workers"
  type        = bool
  default     = false
}

variable "min_workers" {
  description = "Nombre minimum de workers"
  type        = number
  default     = 1
}

variable "max_workers" {
  description = "Nombre maximum de workers"
  type        = number
  default     = 5
}

# service vars
variable "enable_monitoring" {
  description = "Activer le monitoring ()"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Activer le logging centralisé"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Activer les backups automatiques"
  type        = bool
  default     = true
}

#storage vars
variable "storage_class" {
  description = "Classe de stockage pour les backups"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "La classe de stockage doit être STANDARD, NEARLINE, COLDLINE ou ARCHIVE."
  }
}

variable "backup_retention_days" {
  description = "Durée de rétention des backups en jours"
  type        = number
  default     = 30
}

# Variables d'environnement
variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "development"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "L'environnement doit être development, staging ou production."
  }
}

variable "domain_name" {
  description = "Nom de domaine principal"
  default     = "sneakerportfolio.eu"
}

variable "create_api_subdomain" {
  default = true
}