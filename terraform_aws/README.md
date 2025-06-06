# Déploiement d'une Infrastructure AWS avec Terraform

Ce projet utilise Terraform pour déployer une infrastructure complète sur AWS, intégrant une solution de backup S3, une architecture réseau (VPC, subnets), des groupes de sécurité personnalisés et un ensemble d’instances EC2 réparties par rôle (frontend, backend, database, monitoring, reverse proxy).

## Architecture

> [!NOTE]
> - **S3 Backup** : Provisionne un bucket S3 pour les backups et le rôle IAM associé.
> - **Réseau** : Crée un VPC, subnets publics et privés.
> - **Groupes de sécurité** : Sécurise les accès aux différents composants selon leur rôle (frontend, backend, base de données, monitoring, reverse proxy).
> - **Instances EC2** : Lance et configure les instances selon l’architecture cible, avec les groupes de sécurité appropriés et l’instance profile permettant le backup S3.

## Pré-requis

> [!NOTE]
> - Terraform >= 1.0
> - Un compte AWS
> - Les identifiants AWS (AWS_ACCESS_KEY_ID et AWS_SECRET_ACCESS_KEY) configurés
> - Une clé SSH pour accéder aux instances (optionnel, selon la configuration des modules)

## Variables

Le projet utilise les variables suivantes (à définir dans un fichier terraform.tfvars) :

| Variable            | Description                           | Exemple             |
| :------------------ | :------------------------------------ | :------------------ |
| region              | Région AWS                            | us-east-1           |
| project_name        | Nom du projet                         | mon_projet          |
| vpc_cidr            | CIDR du VPC                           | 10.0.0.0/16         |
| public_subnet_cidr  | CIDR du subnet public                 | 10.0.1.0/24         |
| private_subnet_cidr | CIDR du subnet privé                  | 10.0.2.0/24         |
| mon_ip              | IP publique autorisée (accès admin)   | 1.2.3.4/32          |
| ami                 | ID de l'ami EC2 a deployer            | ami-12345678        |

## Utilisation

### 1. Cloner le dépot puis se placer à la racine du projet

```bash
git clone <repository>
cd <repository>
```

### 2. Initialisation de Terraform

`terraform init`

### 3. Vérification du plan

`terraform plan`

### 4. Application de la configuration

`terraform apply`

### 5. Détruire l'infrastructure (lorsque on en a plus besion)

`terraform destroy`

## Modules

### 1. s3_backup
Provisionne un bucket S3 dédié pour les backups et affecte un IAM Instance Profile à vos instances pour y accéder.

### 2. network
Déploie un VPC, un subnet public et un subnet privé selon les CIDR indiqués.

### 3. security_groups
Crée les groupes de sécurité nécessaires à la sécurité de chaque service du projet (frontend, backend, DB, monitoring, reverse proxy).

### 4. instances
Lance les EC2, les associe aux bons groupes de sécurité et leur attribue un rôle IAM pour les backups.

## generate_hosts.sh

### Génération automatique de l’inventaire Ansible (hosts.ini)

Un script shell (generate_hosts.sh) est fourni afin de faciliter l’intégration entre Terraform et Ansible. Ce script s’assure dans un premier temps que la stack est bien déployée (via terraform apply), puis récupère automatiquement les adresses IP publiques/privées des différentes instances créées grâce aux outputs Terraform. Il génère ensuite le fichier hosts.ini placé dans ansible/inventories/, formaté pour être directement exploité par Ansible lors des déploiements ou configurations automatisées.