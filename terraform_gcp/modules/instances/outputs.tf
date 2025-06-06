output "frontend_private_ip" {
  value = google_compute_instance.frontend.network_interface[0].network_ip
}

output "reverse_proxy_public_ip" {
  # "public IP of reverse-proxy instance"
  # value = google_compute_instance.reverse_proxy.network_interface[0].access_config[0].nat_ip
  value = google_compute_address.reverse_proxy_ip.address
}

output "reverse_proxy_static_ip_id" {
  # "ID of reverse-proxy static IP"
  value = google_compute_address.reverse_proxy_ip.id
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