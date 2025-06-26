output "bucket_name" {
  value = google_storage_bucket.swarm_backup.name
}


output "bucket_url" {
  description = "URL du bucket de backup"
  value       = google_storage_bucket.swarm_backup.url
}

output "backup_service_account" {
  description = "Email du Service Account de backup"
  value       = google_service_account.backup_sa.email
}

output "backup_key_json" {
  description = "Clé JSON du Service Account"
  value       = base64decode(google_service_account_key.backup_key.private_key)
  sensitive   = true
}

# Output pour Docker Compose
output "backup_config" {
  description = "Configuration complète pour Docker Swarm"
  value = {
    bucket_name           = google_storage_bucket.swarm_backup.name
    service_account_email = google_service_account.backup_sa.email
    project_id           = var.project
    location             = var.location
  }
}