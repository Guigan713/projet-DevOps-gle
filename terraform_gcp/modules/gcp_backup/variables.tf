variable "project" {
  description = "ID du projet GCP"
  type        = string
}

variable "project_name" {
  description = "nom du projet GCP"
  type        = string
}

variable "location" {
  description = "localisation du bucket (région)"
  type = string
}

variable "storage_class" {
  description = "Classe de stockage du bucket"
  type        = string
  default     = "STANDARD"
}

variable "environment" {
  description = "Environnement (dev/staging/prod)"
  type        = string
  default     = "prod"
}

variable "backup_retention_days" {
  description = "Nombre de jours de rétention des backups"
  type        = number
  default     = 30
}