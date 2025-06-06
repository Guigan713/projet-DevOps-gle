output "application_url" {
  description = "URL of the application"
  value       = "http://${var.server_ip}"
}

output "monitoring_url" {
  description = "URL of Grafana monitoring"
  value       = "http://${var.server_ip}:8080"
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    server_ip    = var.server_ip
    frontend_url = "http://${var.server_ip}"
    backend_url  = "http://${var.server_ip}/api"
    grafana_url  = "http://${var.server_ip}:8080"
  }
}
