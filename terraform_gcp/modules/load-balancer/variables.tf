variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west1-b"
}

variable "manager_instances" {
  description = "List of manager instance self links"
  type        = list(string)
}

variable "worker_instances" {
  description = "List of worker instance self links"
  type        = list(string)
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west1"
}

variable "swarm_lb_ip" {
  description = "IP address of the load balancer"
  type        = string
}