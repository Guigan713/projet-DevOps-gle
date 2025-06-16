# Module Terraform - Google Compute Instances

Ce module Terraform permet de créer une infrastructure complète d'instances Google Compute Engine avec une architecture multi-tiers incluant frontend, backend, base de données, monitoring et reverse proxy.
Description

## Le module configure automatiquement :

> [!NOTE]
> - **Frontend** : Instance pour l'interface utilisateur (réseau privé)
> - **Backend** : Instance pour la logique métier (réseau privé)
> - **Database** : Instance MySQL (réseau privé)
> - **Monitoring** : Instance de surveillance (réseau privé)
> - **Reverse Proxy** : Instance avec IP publique statique (réseau public)
> - **Adresse IP statique** : IP publique réservée pour le reverse proxy

## Architecture

`Internet → Reverse Proxy (IP publique) → Frontend/Backend/Database/Monitoring (réseau privé)`

## Resources créées

| Resource | Nom | Type d'instance | Réseau | Description |
|----------|-----|-----------------|---------|-------------|
| `google_compute_address` | reverse-proxy-ip | - | Public | IP statique réservée |
| `google_compute_instance` | frontend | e2-micro | Privé | Interface utilisateur |
| `google_compute_instance` | reverse-proxy | e2-micro | Public | Point d'entrée |
| `google_compute_instance` | backend | e2-micro | Privé | API/Services |
| `google_compute_instance` | database-mysql | e2-micro | Privé | Base de données |
| `google_compute_instance` | monitoring | e2-medium | Privé | Surveillance |

## Variables requises

| Variable | Type | Description | Exemple |
|----------|------|-------------|---------|
| `zone` | string | Zone Google Cloud pour les instances | `"europe-west1-b"` |
| `region` | string | Région Google Cloud pour l'IP statique | `"europe-west1"` |
| `project` | string | ID du projet Google Cloud | `"my-gcp-project"` |
| `image` | string | Image système pour les instances | `"ubuntu-os-cloud/ubuntu-2004-lts"` |
| `vpc_id` | string | ID du réseau VPC | `"projects/my-project/global/networks/my-vpc"` |
| `private_subnet_id` | string | ID du sous-réseau privé | `"projects/my-project/regions/europe-west1/subnetworks/private-subnet"` |
| `public_subnet_id` | string | ID du sous-réseau public | `"projects/my-project/regions/europe-west1/subnetworks/public-subnet"` |

## Outputs

> - output "frontend_private_ip" {}
> - output "reverse_proxy_public_ip" {}
> - output "reverse_proxy_static_ip_id" {}
> - output "backend_private_ip" {}
> - output "database_private_ip" {}
> - output "monitoring_private_ip" {}

## Sécurité

### Accès SSH

> - Clé SSH configurée pour l'utilisateur guillaume
> - **Chemin de la clé** : ~/.ssh/gcp-ssh-key.pub

### Tags de réseau

Chaque instance possède des tags pour les règles de firewall :

> - **frontend** : Instance frontend
> - **backend** : Instance backend
> - **database** : Instance database
> - **monitoring** : Instance monitoring
> - **reverse-proxy** : Instance reverse proxy
