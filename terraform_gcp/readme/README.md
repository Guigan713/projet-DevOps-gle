# Infrastructure Terraform - Google Cloud Platform

Ce projet déploie une infrastructure prod-ready Docker Swarm sur Google Cloud via Terraform.
Il inclut : provisioning réseau, VM managers/workers, sécurité firewall, load balancer, DNS, sauvegarde et monitoring.

```
                  Internet & Cloud DNS
                           │
                ┌──────────▼──────────┐
                │   Load Balancer     │   ← Point d'entrée (HTTP/HTTPS/SSH)
                └───────┬─────────────┘
                        │
          ┌─────────────┴─────────────┐
   [Public Subnet]              [Private Subnet]
   ┌─────────────┐            ┌──────────────────────────────┐
   │Swarm Manager│───(overlay)│   Swarm Workers              │
   │  (Bastion)  │───(SSH)—→  │   (pas d'accès direct Ext.)  │
   │+ReverseProxy│◄──────────►│ Manager-Worker, InterNodes   │
   └─────────────┘            └──────────────────────────────┘
             │
     ┌───────▼─────────┐
     │Monitoring /     │
     │Backup / Logging │
     └─────────────────┘
```

## Modules

### Network Module
> - **VPC dédié** : sous-réseau public pour managers & reverse proxy, privé pour workers uniquement (pas d’Internet direct).
> - **Router & NAT Gateway** : accès sortant privé sécurisé pour update/backup.

### Instances Module
> - **Managers** : 1+ VMs, accès SSH & API GCP via bastion/ReverseProxy, tag swarm-manager.
> - **Workers** : 1+ VMs, tag swarm-worker, accès interne uniquement.
> - **Load balancer** : IP publique fixe, routage vers managers (ex : HAProxy/Traefik).
> - **SSH** : accès clé publique, bastion unique (sécurité accrue).

### Security Groups Module
> - **Pare-feu granulaire** (TCP/22 restreint, ports du cluster Swarm…).
> - **HTTP/HTTPS** et monitoring ouverts si besoin.
> - **Isolation réseau par tag**.
> - **Sortie Internet workers via NAT uniquement**.

### GCP Backup Module
> - **Bucket GCP storage** avec politique de rétention
> - **Cross-region** configurable.

### DNS Module
> - **Cloud DNS** domain/subdomain pointant sur IP du load balancer
> - **Sous-domaines automatiques pour services**

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

## Fichiers / Structure type

> - main.tf : root config, providers, appel modules
> - outputs.tf / variables.tf : variables d'entrée et de sortie principales
> - modules/ : sous-modules (network, instances, security_groups, gcp_backup, dns)
> - credentials/gcp-sa-key.json : clé de service GCP
> - terraform.tfvars : variables d’environnement


## Variables

### Variables obligatoires

| Variable             | Type    | Description              | Exemple               |
|----------------------|---------|--------------------------|-----------------------|
| `project`            | string  | ID projet GCP            | `"my-gcp-project"`    |
| `region`             | string  | Région GCP               | `"europe-west1"`      |
| `zone`               | string  | Zone VM principale       | `"europe-west1-b"`    |
| `domain_name`        | string  | Domaine application      | `"swarm.example.com"` |
| `mon_ip`             | string  | IP admin SSH             | `"203.0.113.1"`       |
| `ssh_public_key_path`| string  | Chemin clé SSH publique  | `"~/.ssh/id_rsa.pub"` |

### Swarm Control

| Variable              | Type    | Description               | Exemple/Défaut      |
|-----------------------|---------|---------------------------|---------------------|
| `swarm_manager_count` | number  | Nb de managers            | `3`                 |
| `swarm_worker_count`  | number  | Nb de workers             | `2`                 |
| `manager_machine_type`| string  | Type VM managers          | `"e2-medium"`       |
| `worker_machine_type` | string  | Type VM workers           | `"e2-small"`        |
| `image`               | string  | Image OS (manager/worker) | `"ubuntu-2204-lts"` |

### Variables réseau

| Variable             | Type    | Description              | Défaut            |
|----------------------|---------|--------------------------|-------------------|
| `vpc_cidr`           | string  | CIDR du VPC principal    | `"10.0.0.0/16"`   |
| `public_subnet_cidr` | string  | CIDR public              | `"10.0.1.0/24"`   |
| `private_subnet_cidr`| string  | CIDR privé               | `"10.0.2.0/24"`   |

### Outputs

| Output                                | Description                                         |
|----------------------------------------|-----------------------------------------------------|
| `swarm_manager_ips`                    | IPs privées des managers Swarm                      |
| `swarm_manager_public_ips`             | IP publique principale du manager leader            |
| `swarm_worker_ips`                     | IPs privées des workers Swarm                       |
| `swarm_leader_ip`                      | IP privée du manager leader                         |
| `swarm_load_balancer_ip`               | IP publique Load Balancer (entrée)                  |
| `ssh_connection_manager`               | Commande SSH leader manager                         |
| `docker_swarm_status`                  | Vérification cluster Swarm                          |
| `vpc_id`, `public_subnet_id`, `private_subnet_id` | Ressources réseau principales             |
| `backup_bucket_name`, `url`            | Infos bucket de backup                              |
| `domain_name_servers`                  | Serveurs NS Cloud DNS à configurer sur le registrar |


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

