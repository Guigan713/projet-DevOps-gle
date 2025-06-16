# Infrastructure Terraform - Google Cloud Platform

Ce projet Terraform déploie une infrastructure complète sur Google Cloud Platform avec une architecture multi-tiers sécurisée, incluant réseau, instances, sécurité, sauvegarde et DNS.
Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                             │
└─────────────────────┬───────────────────────────────────────┘
                      │ DNS (Cloud DNS)
              ┌───────▼───────┐
              │ Reverse Proxy │ (Public Subnet)
              │   (Bastion)   │
              └───────┬───────┘
                      │ Firewall Rules
        ┌─────────────▼─────────────┐
        │     Private Network       │
        │  ┌─────┐ ┌─────┐ ┌─────┐  │
        │  │Front│ │Back │ │ DB  │  │
        │  │ end │ │ end │ │     │  │
        │  └─────┘ └─────┘ └─────┘  │
        │           │               │
        │      ┌─────▼─────┐        │
        │      │Monitoring │        │
        │      │(Grafana)  │        │
        │      └───────────┘        │
        └───────────────────────────┘
```

## Modules

### Network Module
> - **VPC** avec sous-réseaux public/privé
> - **Router** et **NAT Gateway**
> - **Flow Logs** pour l'audit

### Instances Module
> - **Reverse Proxy** (sous-réseau public)
> - **Frontend, Backend, Database** (sous-réseau privé)
> - **Monitoring** avec Prometheus/Grafana
> - Clés SSH automatiquement configurées

### Security Groups Module
> - **Règles de pare-feu** granulaires
> - **Bastion host** pour SSH sécurisé
> - **Principe du moindre privilège**
> - Tags de sécurité par service

### GCP Backup Module
> - **Snapshots automatiques** des disques
> - **Politique de rétention** configurable
> - **Sauvegarde cross-region**

### DNS Module
> - **Cloud DNS** pour la résolution
> - **Enregistrements A** automatiques
> - **Sous-domaines** pour chaque service

## Configuration requise

### Versions
> - **Terraform**: >= 1.0.0
> - **Google Provider**: ~> 5.0

### Authentification
```json
// credentials/gcp-sa-key.json
{
  "type": "service_account",
  "project_id": "your-project-id",
  // ... autres clés
}
```

## Variables

### Variables obligatoires

| Variable | Type | Description | Exemple |
|----------|------|-------------|---------|
| `project` | string | ID du projet Google Cloud | `"my-gcp-project"` |
| `region` | string | Région GCP | `"europe-west1"` |
| `zone` | string | Zone GCP | `"europe-west1-b"` |
| `domain_name` | string | Nom de domaine | `"example.com"` |
| `mon_ip` | string | IP administrateur | `"203.0.113.1"` |
| `ssh_public_key_path` | string | Chemin vers clé SSH publique | `"~/.ssh/id_rsa.pub"` |

### Variables réseau

| Variable | Type | Description | Défaut |
|----------|------|-------------|--------|
| `vpc_cidr` | string | CIDR du VPC | `"10.0.0.0/16"` |
| `public_subnet_cidr` | string | CIDR sous-réseau public | `"10.0.1.0/24"` |
| `private_subnet_cidr` | string | CIDR sous-réseau privé | `"10.0.2.0/24"` |

### Variables optionnelles

| Variable | Type | Description | Défaut |
|----------|------|-------------|--------|
| `image` | string | Image des instances | `"ubuntu-2204-lts"` |
| `project_name` | string | Nom du projet | `var.project` |
| `location` | string | Région de sauvegarde | `var.region` |

## Utilisation

### 1. Prérequis
```bash
# Installer Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Authentification Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Configuration

```bash
# Cloner le projet
git clone <repository-url>
cd terraform-gcp-infrastructure

# Créer le fichier de variables
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec vos valeurs

# Placer les credentials GCP
mkdir -p credentials/
# Copier votre fichier de service account dans credentials/gcp-sa-key.json
```

### 3. Déploiement

```bash
# Initialiser Terraform
terraform init

# Planifier les changements
terraform plan

# Appliquer l'infrastructure
terraform apply
```

### 4. Accès aux services

```bash 
# SSH vers le bastion
ssh -i ~/.ssh/id_rsa user@$(terraform output reverse_proxy_ip)

# SSH vers les services internes (via bastion)
ssh -J user@$(terraform output reverse_proxy_ip) user@<internal-ip>

# Accès web
# Frontend: http://your-domain.com
# Grafana: http://monitoring.your-domain.com
```

## Outputs

> - output "frontend_ip" {}
> - output "reverse_proxy_ip" {}
> - output "backend_ip" {}
> - output "database_ip" {}
> - output "monitoring_ip" {}
> - output "bucket_name" {}
