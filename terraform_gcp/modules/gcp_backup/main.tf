resource "google_storage_bucket" "mysql_backup" {
    name = "mysql-backup-${var.project}"
    force_destroy = true
    labels = {
        Name = "MySQL Backup"
    }
}

