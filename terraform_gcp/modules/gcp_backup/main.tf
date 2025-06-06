resource "google_storage_bucket" "mysql_backup" {
    project = var.project
    name = "mysql-backup-${var.project_name}"
    location = var.location
    storage_class = var.storage_class

    # Versioning pour garder plusieurs versions des backups
    versioning {
        enabled = true
    }
    
    force_destroy = true
    labels = {
        name = "mysql-backup"
    }
}

