# Guide d’initialisation & déploiement du projet

Ce guide explique, étape par étape, comment cloner, configurer, déployer et superviser l’ensemble du projet (React + Express + MySQL + Docker Swarm sur GCP, infra as code, CI/CD).

## Prérequis système


> - OS : Linux/macOS/WSL (Windows avec Docker Desktop)
> - Outils nécessaires installés :
>    - Docker
>    - Docker Compose
>    - Node.js (>=18) & npm
>    - Terraform (>=1.0)
>    - Ansible (>=2.9)
>    - Google Cloud CLI (gcloud)
>    - Git

## 1. Cloner le dépt Git

```bash
git clone https://github.com/monorg/monprojet.git
cd monprojet
```

## 2. Initialisation des services applicatifs

### a. Frontend React.js

```bash
cd frontend
npm install
# (optionnel) Configurer le fichier `.env`
npm run build
```

### a. Backend Express.js

```bash
cd backend
npm install
# (optionnel) Configurer le fichier `.env`
npm run build
```

### c. Base de Données MySQL

> - La BDD est provisionnée en tant que service Docker.
> - Les variables de connexion se définissent dans le docker-compose.yml ou .env

## 3. Installation de la Google Cloud CLI

```bash
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-438.0.0-linux-x86_64.tar.gz
# adapter pour obtenir la version souhaitée
tar -xf google-cloud-sdk-*-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
source ~/.bashrc
gcloud init
# suivre les étapes
```

## 4. Déploiement de l’infrastructure Terraform

> - Placer vos credentials de service dans un fichier de type credentials.json.
> - Créer (ou modifier) le fichier terraform.tfvars avec vos variables projet.
> - Depuis le dossier infra/ ou terraform/ :

```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

## 5. Installation/Configuration Ansible

> - Installer Ansible sur votre poste : `pip install ansible` -> avoir Python préalablement installé
> - Configurer vos inventaires pour pointer vers les VM Swarm produites par Terraform (cf. fichier hosts/inventory, dynamique ou non). -> peut être généré automatiquement par un script bash ou python
> - Définir les variables sensibles (mots de passe, clés, emails SSL, etc.) dans les group_vars ou chiffrés via Ansible Vault.
> - Lancer la configuration automatisée :

```bash
ansible-playbook -i hosts/production site.yml
# ou le ou les playbooks de votre projet, ex : deploy_stack.yml
```

## 6. Déploiement de la stack Docker Swarm

> - Les réseaux et volumes externes doivent être créés une fois sur le cluster Swarm :

```bash
docker network create --driver=overlay traefik-public
docker volume create mysql_data
# etc.
```

> - Déployer la stack avec le fichier docker-compose.yml :

`docker stack deploy -c docker-compose.yml projectname`

> - [!NOTE]
> - Le déploiement de la stack peut être automatisé par Ansible -> c'est le cas ici

## 7. CI/CD – GitHub Actions

Fonctionnement automatique :

> - Le projet inclut des workflows GitHub Actions (voir .github/workflows/).
> - Ceux-ci peuvent :
>    - Lancer les tests de lint/build pour frontend/backend,
>    - Builder et publier (auto ou manuellement) les images Docker sur Docker Hub/Gar,
>    - Déclencher un déploiement distant via Ansible,
>    - Notifier des erreurs/succès sur Slack/Discord/Mail.
> - Paramétrez vos secrets dans les settings du repo GitHub (Settings > Secrets and variables > Actions).

> [!NOTE]
> - Tous les services cités ci-dessus peuvent être déclenchés par les Workflows GitHub Actions
> - Dans ce projet, Les workflows sont déclenchés par un push Git sur la branche main. 
> - Le workflow de déploiement déclenche Ansible, qui configure toute la stack.
