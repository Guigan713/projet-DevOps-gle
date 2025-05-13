output "frontend_public_ip" {
  value = google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip
}

output "reverse_proxy_public_ip" {
  value = google_compute_instance.reverse_proxy.network_interface[0].access_config[0].nat_ip
}

output "backend_private_ip" {
  value = google_compute_instance.backend.network_interface[0].network_ip
}

output "database_private_ip" {
  value = google_compute_instance.database.network_interface[0].network_ip
}

output "monitoring_private_ip" {
  value = google_compute_instance.monitoring.network_interface[0].network_ip
}