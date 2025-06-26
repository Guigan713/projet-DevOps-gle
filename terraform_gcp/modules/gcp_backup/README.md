# Module Terraform - Google Cloud Storage Backup MySQL

Ce module Terraform permet de créer un bucket Google Cloud Storage dédié au stockage des sauvegardes MySQL avec gestion des versions.

## Description

### Le module configure automatiquement :

> [!NOTE]
> - **Création automatique d’un bucket Google Cloud Storage optimisé pour les sauvegardes**
> - **Versioning** : conservation de plusieurs versions de chaque fichier de sauvegarde
> - **Gestion du cycle de vie** : automatisation du passage en Coldline/archivage et de la suppression des anciens fichiers
> - **Labels** : pour l’organisation, le suivi environnement et la facturation
> - **Gestion fine des accès** avec un Service Account dédié
> - **Distribution de clé de service** : permet l’usage sécurisé côté script ou VM


### Resources créées

> - **google_storage_bucket** : Bucket principal pour stocker les sauvegardes
> - **google_service_account** : Service Account dédié pour réaliser les sauvegardes
> - **google_storage_bucket_iam_member** : Attribution du rôle d’écriture (objectAdmin) au Service Account sur ce bucket
> - **google_service_account_key** : Génération d’une clé privée pour accéder au bucket côté scripts/serveurs


## Variables requises

| Variable | Type | Description | Exemple | Défaut |
|----------|------|-------------|---------|---------|
| `project` | string | ID du projet Google Cloud | `"my-gcp-project"` | - |
| `project_name` | string | Nom du projet (utilisé dans le nom du bucket) | `"myapp"` | - |
| `location` | string | Région/zone du bucket | `"europe-west1"` | - |
| `storage_class` | string | Classe de stockage du bucket | `"STANDARD"` | - |
| `environment` | string |  	Environnement d'usage (pour les labels) | `"prod"` | - |

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

