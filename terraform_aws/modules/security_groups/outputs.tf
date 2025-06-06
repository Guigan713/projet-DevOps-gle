output "frontend_sg_id" {
  value = aws_security_group.frontend.id
}

output "backend_sg_id" {
  value = aws_security_group.backend.id
}

output "reverse_proxy_sg_id" {
  value = aws_security_group.reverse_proxy.id
}

output "database_sg_id" {
  value = aws_security_group.database.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}