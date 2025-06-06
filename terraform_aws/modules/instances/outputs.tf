output "frontend_private_ip" {
  value = aws_instance.frontend.private_ip
}

output "reverse_proxy_public_ip" {
  value = aws_instance.reverse_proxy.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "database_private_ip" {
  value = aws_instance.database.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring.private_ip
}
