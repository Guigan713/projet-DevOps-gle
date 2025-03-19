output "frontend_ip" {
    value = aws_instance.frontend.public_ip
}

output "reverse_proxy_ip" {
  value = aws_instance.reverse_proxy.public_ip
}

output "bastion_ip" {
    value = aws_instance.bastion.public_ip
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