# Déploiement complet d’une infrastructure Docker Swarm avec Ansible

Ce playbook Ansible orchestre le provisionnement et le déploiement d’une infrastructure Docker Swarm autoscalée, incluant la création/utilisation d’utilisateurs SSH, l’installation Docker, la configuration Swarm, le monitoring, la sauvegarde MySQL et le déploiement applicatif (frontend, backend).

> [!NOTE]
> - Gestion centralisée des utilisateurs SSH et accès sudo
> - Installation complète de Docker et ses dépendances
> - Provisioning du cluster Docker Swarm (manager/workers)
> - Sauvegarde automatisée de la base MySQL
> - Mise en place d’un monitoring multi-nœuds (Node Exporter, Prometheus, Grafana)
> - Build et push d’images front/back personnalisées avec tags dynamiques
> - Déploiement applicatif (stack Swarm)
> - Injection automatisée de données SQL initiales
> - Configuration DNS & SSL (Let’s Encrypt ou autres)

L’ensemble est orchestré via un playbook structuré et des rôles réutilisables.

## Prérequis

> - Ansible >= 2.9
> - Un inventaire compatible (fichier INI dynamique auto-généré après terraform)
> - Une clé SSH publique prête à être injectée (via la variable ssh_public_key)
> - Docker Hub accessible et credentials
> - Variables principales définies dans group_vars/all.yml (voir section dédiée)

## Déclenchement

### Automatique

> - Via GitHub Actions CI/CD, par exemple à chaque merge/push sur main
Déclenche le workflow build-deploy-gcp.yml

### Manuel

```bash
cd ansible
ansible-playbook -i inventories/hosts.ini playbooks/playbook.yml --private-key ../chemin-vers-ta-cle.pem
```

## Structure du playbook principal

Chaque section correspond à un ensemble logique de tâches ou à l’exécution d’un rôle :

### 1. Collecte des facts et informations système

> - Récupère les informations système de chaque hôte du cluster
> - Vérifie la connectivité et la cohérence de l’inventaire

```yml
- name: Gather facts from all servers
  hosts: all
  gather_facts: yes
  ...
```

### 2. Configuration utilisateur SSH

> - Crée/modifie l’utilisateur {{ ssh_user }}
> - Provisionne la clé publique d’accès SSH
> - Accorde les droits sudo sans mot de passe
> - Prépare l’environnement .ssh avec les bonnes permissions

### 3. Installation des prérequis Docker

> - Installation des dépendances système nécessaires pour Docker
> - Ajout du dépôt officiel Docker / GPG key
> - Installation de Docker CE, Docker Compose et Python Docker SDK
> - Démarrage et activation du service Docker
> - Ajout de l’utilisateur {{ ssh_user }} au groupe docker

### 4. Initialisation du cluster Docker Swarm

> - Provisionne le cluster :
>    - Exécution sur le groupe swarm_managers et swarm_workers
>    - Les tâches d’initialisation, prise de token, join cluster, etc. sont gérées par le rôle docker_swarm

### 5. Configuration des backups MySQL

> - Déploiement d’un mécanisme automatisé de sauvegarde MySQL
> - Exécuté uniquement sur le premier manager (swarm_managers[0])
> - Piloté via le rôle mysql_backup

### 6. Build des fichiers l’application

> - Création des dossiers qui accueilleront la configuration de docker swarm

### 7. Gestion des images Docker et versionning applicatif

> - Build/push des images Docker localement
> - passage de la variable de version à la suite 
> - génération du fichier Compose 

### 8. déploiement
> - déploiement de la stack Swarm via le rôle app_deploy.

### 9. Injection SQL post-déploiement

> - Injection automatique des premières données applicatives dans MySQL.

### 10. Installation monitoring simple (Node Exporter)

> - Déploiement de Node Exporter sur tous les serveurs avec gestion de l’utilisateur dédié, permissions, etc.
> - Le rôle node_exporter s’occupe du cycle de vie complet (install, service, vérification)

### 11. Déploiement de la stack de monitoring complète

> - Déployée sur le manager principal (swarm_managers[0])
> - Utilise le rôle monitoring (Prometheus, Grafana, dashboards…)

### 12. Gestion DNS & SSL

> - Rôle dédié sur le leader pour gestion automatisée (DNS, certificats SSL/LetsEncrypt...).


## Arborescence du projet

├── ansible.cfg
├── files
│   └── gcp-ssh-key.pub
├── inventories
│   ├── group_vars
│   │   └── all
│   └── swarm-hosts.ini
├── playbooks
│   ├── check_vars.yml
│   ├── playbook.yml
│   └── roles
│       ├── app_build
│       ├── app_deploy
│       ├── dns_management
│       ├── docker_swarm
│       ├── monitoring
│       ├── mysql_backup
│       └── node_exporter
├── README.md
├── ssh-config

## Détail des rôles principaux

### Rôle : docker_swarm

> - Initialise le cluster Swarm
> - Gère l’adhésion des workers et managers
> - Modulaire et idempotent

### Rôle : mysql_backup

> - Installe les outils de backup MySQL (dump, script)
> - Déploie/crée un cron pour l’exécution récurrente et la gestion des logs

### Rôle : monitoring

> - Mise en place de l’environnement Prometheus + Grafana (config + docker-compose)
> - Gestion des variables et dashboards

### Rôle : node_exporter

> - Installation binaire
> - Création de l’utilisateur et group dédiés
> - Déploiement service systemd et vérification de l’endpoint

### Rôle : app_build

> - crée les différents dossiers importants de la configuration

### Section Images et versionning

> - Authentification à Docker Hub avec des credentials sécurisés
> - Génération automatique d’un tag unique pour chaque build (deploy_version) basé sur un horodatage
> - Build et push distincts des images backend et frontend depuis le répertoire local vers Docker Hub, avec le tag correspondant
> - Partage de la variable deploy_version entre la machine de build (localhost) et le manager Swarm :
>    - Stockage temporaire du tag dans /tmp/deploy_version.txt
>    - Rapatriement sur le manager principal pour utilisation dans les templates
> - Injection dynamique du tag/version dans le template de déploiement (compose-swarm.yml), garantissant que seules les images fraichement construites/taguées soient déployées sur le cluster

### Rôle : app_deploy

> - Déploie, configure et lance votre application (frontend, backend)
> - Prend en charge le lancement en swarm stack ou via Compose selon config

### Section Injection SQL

> - Détection dynamique du nœud porteur du service DB. Utilise docker service ps pour identifier le nœud Swarm (manager ou worker) sur lequel tourne le container MySQL
> - Transfert contextuel du script SQL:
>    - Le fichier SQL à injecter est copié en direct sur le bon hôte, grâce à la délégation (delegate_to).
>    - Sécurité des droits : propriété et permissions adéquates.
> - Sélection du container cible, Recherche l’ID du container MySQL réel (pour Docker Swarm, le nom de l’instance varie dynamiquement)
> - Injection automatisée des données:
>    - Exécution du script dans le container via docker exec, respectant le mot de passe stocké dans les variables Vault.
>    - Injection robuste (résiste aux titulaires dynamiques de services Swarm).

### Rôle : dns_management 

> - configuration DNS, SSL, letsencrypt.

## Variables globales principales

## Variables à retrouver dans group_vars/all.yml (extrait) :

```yml
# Application & Infra
project_name: "projet-devops-gle"
app_version: "v1.0.0"
app_environment: production
app_directory: "/opt/{{ project_name }}"
docker_data_dir: "/var/lib/docker"

# Utilisateurs SSH
ssh_user: "deploy"
ssh_port: 22
ssh_public_key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/gcp-ssh-key.pub') }}"

# DNS & Domaines
domain_name: "projet-devops-gle.fr"
api_domain: "api.{{ domain_name }}"
grafana_domain: "grafana.{{ domain_name }}"
prometheus_domain: "prometheus.{{ domain_name }}"
traefik_domain: "traefik.{{ domain_name }}"

# Répertoires (projet, build, volumes, logs)
project_root: /home/guillaume/projet-DevOps-gle
app_build_dir: "{{ app_directory }}/build"
app_volumes_dir: "{{ app_directory }}/volumes"
app_config_dir: "{{ app_directory }}/config"
app_logs_dir: "{{ app_directory }}/logs"

# Backend & DB
db_name: "sneakerportfolio"
db_user: "guillaume"
db_host: "database"
db_port: "3306"

# Volumes Docker
prometheus_data_volume: "{{ project_name }}_prometheus_data"
grafana_data_volume: "{{ project_name }}_grafana_data"
traefik_data_volume: "{{ project_name }}_traefik_data"
app_uploads_volume: "{{ project_name }}_uploads"
app_static_volume: "{{ project_name }}_static"
app_media_volume: "{{ project_name }}_media"

# Traefik
traefik_version: "v3.0"
traefik_dashboard_port: 8080
traefik_dashboard_enabled: true
traefik_api_dashboard: true
traefik_api_debug: false

# SSL/TLS
ssl_enabled: false
ssl_provider: "letsencrypt"
ssl_email: "admin@projet-devops-gle.fr"
```

Toutes ces variables sont centralisées pour piloter le comportement du cluster, des services Docker et des tâches Ansible selon l’environnement et les besoins métier.
Modèle d’inventaire

## Exemple de fichier inventories/hosts.ini (bastion inclus, proxy SSH) :

```ini
# ===== INVENTAIRE DOCKER SWARM =====

# Variables globales
[all:vars]
ansible_user=deploy
ansible_ssh_private_key_file=/home/guillaume/.ssh/gcp-ssh-key
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o ProxyJump=deploy@34.140.50.4"

# ===== MANAGERS =====
[swarm_managers]
manager_1 ansible_host=10.0.1.4 swarm_role=manager swarm_leader=true public_ip=34.140.50.4
manager_2 ansible_host=10.0.1.3 swarm_role=manager swarm_leader=false ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@34.140.50.4'
manager_3 ansible_host=10.0.1.2 swarm_role=manager swarm_leader=false ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@34.140.50.4'

# ===== WORKERS =====
[swarm_workers]
worker_1 ansible_host=10.0.2.2 swarm_role=worker ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@34.140.50.4'
worker_2 ansible_host=10.0.2.3 swarm_role=worker ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@34.140.50.4'

# ===== GROUPES =====
[swarm_cluster:children]
swarm_managers
swarm_workers

[swarm_nodes:children]
swarm_managers
swarm_workers

[swarm_deploy]
manager_1

[bastion]
swarm_bastion ansible_host=34.140.50.4 private_ip=10.0.1.4 lb_ip=34.140.50.4 ansible_ssh_common_args='' swarm_role=bastion
```

> [NOTE] 

> - Utilisation d’un proxy jump (bastion) pour l’accès aux nœuds privés
> - Rôle précis de chaque serveur (swarm_role, swarm_leader)
> - Possibilité de filtrer/target à l’exécution via les groupes

### Vérification post-déploiement

À la fin de l’exécution, le playbook vérifie que tous les services Docker Swarm critiques (Traefik, frontend, backend, database, Prometheus, Grafana…) sont bien créés et actifs sur le(s) manager(s) principaux.  
Des logs explicites « Service <nom> exists » confirment leur présence.

En cas d'absence d’un service attendu, la commande retournera un code d’échec et l’erreur « Service <nom> does not exist ».