resource "google_storage_bucket" "swarm_backup" {
  project       = var.project
  name          = "swarm-backup-${var.project_name}"
  location      = var.location
  storage_class = var.storage_class


  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30  # Après 30 jours
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365  # Après 1 an
    }
    action {
      type = "Delete"  # Suppression automatique
    }
  }

  force_destroy = true
  
  labels = {
    name        = "swarm-backup"
    environment = var.environment
    service     = "mysql"
  }
}

# Service Account pour les backups
resource "google_service_account" "backup_sa" {
  account_id   = "swarm-backup-sa"
  display_name = "Swarm Backup Service Account"
  description  = "Service Account pour les backups Docker Swarm"
}

resource "google_storage_bucket_iam_member" "backup_sa_writer" {
  bucket = google_storage_bucket.swarm_backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backup_sa.email}"
}

# Clé pour le Service Account
resource "google_service_account_key" "backup_key" {
  service_account_id = google_service_account.backup_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

