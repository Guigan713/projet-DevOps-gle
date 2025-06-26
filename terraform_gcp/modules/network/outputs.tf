output "vpc_id" {
  description = "ID du Swarm VPC"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "Nom du Swarm VPC"
  value       = google_compute_network.main.name
}

output "public_subnet_id" {
  description = "ID du public subnet pour Swarm managers"
  value       = google_compute_subnetwork.public.id
}

output "private_subnet_id" {
  description = "ID du private subnet pour Swarm workers"
  value       = google_compute_subnetwork.private.id
}

output "public_subnet_cidr" {
  description = "CIDR block du public subnet"
  value       = google_compute_subnetwork.public.ip_cidr_range
}

output "private_subnet_cidr" {
  description = "CIDR block du private subnet"
  value       = google_compute_subnetwork.private.ip_cidr_range
}