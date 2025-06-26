variable "project" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "europe-west1-b"
}

variable "image" {
  description = "Image pour les nœuds Swarm"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé SSH publique"
  type        = string
  default     = "~/.ssh/gcp-ssh-key.pub"
}

variable "swarm_manager_count" {
  description = "Nombre de managers Swarm"
  type        = number
  default     = 3
}

variable "swarm_worker_count" {
  description = "Nombre de workers Swarm"
  type        = number
  default     = 2
}

variable "manager_machine_type" {
  description = "Type de machine pour les managers"
  type        = string
  default     = "e2-small"
}

variable "worker_machine_type" {
  description = "Type de machine pour les workers"
  type        = string
  default     = "e2-micro"
}