# Script de Génération d'Inventaire Ansible

Ce script Bash automatise la génération du fichier d'inventaire Ansible (`hosts.ini`) en récupérant les adresses IP des instances depuis les outputs Terraform.

## Description

Ce script permet de :
- Extraire automatiquement les IPs des outputs Terraform
- Générer un fichier d'inventaire Ansible structuré
- Détecter les conflits d'IP avant mise à jour
- Créer des sauvegardes automatiques
- Valider l'environnement Terraform

## Prérequis

- **Terraform** installé et configuré
- **Bash** version 4.0 ou supérieure
- Projet Terraform initialisé avec `terraform init`

## Outputs Terraform requis

Le script nécessite les outputs suivants dans votre configuration Terraform :

```hcl
output "frontend_ip" {
  description = "Adresse IP publique de l'instance frontend"
  value       = module.instances.frontend_private_ip
}

output "reverse_proxy_ip" {
  description = "Adresse IP publique de l'instance reverse proxy"
  value       = module.instances.reverse_proxy_public_ip
}

output "backend_ip" {
  description = "Adresse IP privée de l'instance backend"
  value       = module.instances.backend_private_ip
}

output "database_ip" {
  description = "Adresse IP privée de l'instance MySQL"
  value       = module.instances.database_private_ip
}

output "monitoring_ip" {
  description = "Adresse IP privée de l'instance Prometheus/Grafana"
  value       = module.instances.monitoring_private_ip
}
```

## Utilisation

Utilisation basique : `./generate_hosts.sh`
Utilisation régulière : A chaque `terraform apply`

### Exemples d'utilisation

```bash
# Génération normale avec vérification de conflits
./generate_inventory.sh

# Forcer la mise à jour
./generate_inventory.sh --force

# Afficher l'aide
./generate_inventory.sh --help
```

## Fonctionnalités

### Vérifications automatiques

- **Environnement Terraform** : Vérification de l'initialisation et de l'état
- **Outputs requis** : Validation de la présence de tous les outputs nécessaires
- **Répertoire de travail** : Contrôle de la présence des fichiers Terraform

### Détection de conflits

Le script compare les IPs existantes avec les nouvelles :

```bash
⚠️  IP différente détectée pour [frontend]:
   Existante: 192.168.1.10
   Nouvelle:  192.168.1.1
```

### Sauvegarde automatique

Chaque exécution crée une sauvegarde: 

`Sauvegarde créée: ../ansible/inventories/hosts.ini.backup`

### Format de sortie

```ini
[frontend]
203.0.113.10 ansible_user=ubuntu

[reverse_proxy]
203.0.113.11 ansible_user=ubuntu

[backend]
10.0.1.20 ansible_user=ubuntu

[database]
10.0.1.21 ansible_user=ubuntu

[monitoring]
203.0.113.12 ansible_user=ubuntu
```
