# Module Terraform - Google Cloud Storage Backup MySQL

Ce module Terraform permet de créer un bucket Google Cloud Storage dédié au stockage des sauvegardes MySQL avec gestion des versions.

## Description

### Le module configure automatiquement :

> [!NOTE]
> - Un bucket Google Cloud Storage optimisé pour les sauvegardes
> - Versioning activé pour conserver plusieurs versions des backups
> - Labels pour faciliter l'organisation et la facturation

### Resources créées

> - google_storage_bucket : Bucket de stockage pour les sauvegardes MySQL

## Variables requises

| Variable | Type | Description | Exemple | Défaut |
|----------|------|-------------|---------|---------|
| `project` | string | ID du projet Google Cloud | `"my-gcp-project"` | - |
| `project_name` | string | Nom du projet (utilisé dans le nom du bucket) | `"myapp"` | - |
| `location` | string | Région/zone du bucket | `"europe-west1"` | - |
| `storage_class` | string | Classe de stockage du bucket | `"STANDARD"` | - |

## Classes de stockage disponibles

> [!NOTE]
> - STANDARD : Pour un accès fréquent
> - NEARLINE : Pour un accès mensuel (économique pour backups)
> - COLDLINE : Pour un accès trimestriel (très économique)
> - ARCHIVE : Pour un accès annuel (archivage long terme)

### Exemple d'utilisation

```hcl
module "mysql_backup_storage" {
  source = "./modules/gcs-mysql-backup"
  
  project       = "mon-projet-123"
  project_name  = "ecommerce"
  location      = "europe-west1"
  storage_class = "NEARLINE"
}
```

