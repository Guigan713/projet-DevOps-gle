# projet-DevOps-gle

## Introduction

Ce projet de fin détude a pour but de mettre en avant les compétences aquises lors de ma formation (administrateur système DevOps). 
Le but de ce projet est de déployer une application (Sneaker Portfolio) développée par mes soins à la suite de mon précédent cursus de développeur web full stack. Les technologies utilisées pour cette application sont **ReactJs** pour la partie frontend, **Express.Js** pour la partie backend et **MySQL** comme base de données.

Le but est d’automatiser la *création de l’infrastructure*, le *déploiement continu* et le *monitoring* d’une plateforme de microservices à l’aide des outils DevOps modernes : **Terraform**, **Ansible**, **Docker Swarm**, **Traefik**, **Prometheus/Grafana**, et une chaîne **CI/CD GitHub Actions**.

Pour la partie DevOps, les technologies utilisées sont:

> [!NOTE]
> - **Terraform** : Création de l'infrastructure globale qui accueillera l'application
> - **Ansible** : Configuration des serveurs qui accueilleront les différents services 
> - **Docker** : Conteneurisation des différents services
> - **CI/CD GitHub Actions** : automatisation des tests, builds et déploiements sur les serveurs de production
> - **Prometheus & Grafana** : Monitoring de l'application
> - **Reverse Proxy/Load balancer Traefik** : sécurité et répartition des requêtes vers les différents services de l'application

## Architecture technique

> [!NOTE]
> - **Infrastructure Cloud** : GCP compute instances, VPC et Firewall rules — *provisionnée par Terraform*
> - **Cluster applicatif** : Docker Swarm multi-nœuds (managers & workers)
> - **Reverse Proxy / Load Balancing** : Traefik en frontal, gestion automatique des certificats SSL (Let's Encrypt/DNS Google)
> - **Monitoring** : Prometheus (collecte), Grafana (visualisation), Node Exporter (métriques système)
> - **Sauvegarde** : Backup MySQL automatisé et export vers Google Cloud Storage
> - **DNS & SSL** : Automatisés via Ansible, API Google Cloud DNS et Certbot
> - **CI/CD & Orchestration** : Pipelines GitHub Actions pour build/push/test/deploy

## Terraform_GCP

> [!NOTE]
> - Création des Instances compute-instances (nodes) qui accueilleront les différents services
> - Création des VPC et sous-réseaux qui accueilleront les instances
> - Création des règles de sécurité (quels services sont accessibles publiquement, par quels ports...)
> - Création d'une sauvegarde automatisée de la base de données sur un bucket Google/GCP,
> - Mise en place d'un script bash qui automatise la création des hosts (nodes accueillant les différents services) qui serviront a la configuration des serveurs avec Ansible

## Ansible

> [!NOTE]
> - **Installation des outils sur chaque nœud**:
>    - Docker & Docker Compose Plugin
>    - Traefik (Reverse Proxy/Load balancer)
>    - **node_exporter** pour la gestion de la partie monitoring (métriques)
> - **Configuration fine** :
>    - Gestion des utilisateurs/admins et accès SSH sécurisés
>    - Configuration sudoers, ouverture des ports, sécurisation bas niveau
>    - Déploiement automatisé du cluster Docker Swarm (init/join, labels, overlay networks)
>    - Déploiement des stacks applicatives via Docker Compose (playbooks dynamiques, tag d’image versionné)
> - **Monitoring essentiel** :
>    - Déploiement de node_exporter sur chaque nœud (scrap Prometheus)
>    - Monitoring : installation, gestion des dashboards Grafana, alertes
> - **Sauvegarde / Sécurité des données** :
>    - Script et cron de backup MySQL, upload dans un bucket Google/GCP, rotation et gestion des logs
> - **Gestion du DNS et des certificats SSL** :
>    - Création/mise à jour automatique des entrées DNS pour chaque service (Traefik, API, Prometheus, …) via Google Cloud DNS API
>    - Génération (Certbot + plugin Google) et renouvellement automatique de tous les certificats SSL (y compris wildcard)
> - **Déploiement post-install** :
>    - Injection automatique du schéma et des données de base MySQL après le déploiement des services

---

## Docker & Swarm

> [!NOTE]
> - **Conteneurisation complète** :
>    - *Dockerfiles* dédiés pour chaque service (frontend, backend)
>    - Déploiement via Docker Compose en local ET via stack Docker Swarm pour la prod
> - **Cluster Swarm sur AWS** :
>    - Déploiement manager/worker multi-nœuds avec labels/service affinities
>    - Service discovery : accès par noms de services internes et par sous-domaines Traefik
>    - Déploiement blue/green ou rolling via stack Swarm, versionné à chaque release
> - **Reverse Proxy & Load-Balancer** : 
>    - Traefik automatique (auto-découverte, gestion HTTPS, dashboard realtime, letsencrypt…)

---

## CI/CD : GitHub Actions

> [!NOTE]
> - **Automatisation complète :**
>    - Pipeline déclenché à chaque commit `main` ou tag (Build & push images Docker, scan qualité)
>    - Tests automatisés : SonarQube, lint front/back, unitaires
>    - Génération d’un tag d’image unique pour chaque release/merge automatique
>    - Déploiement automatique : connexion SSH, exécution ciblée des playbooks Ansible
>    - Propagation automatique du tag de version dans les templates compose/swarm avant déploiement
>    - Release automatique (sémantique) avec changelog généré à chaque version

---

## Monitoring & Supervision

> [!NOTE]
> - **Stack de monitoring déployée automatiquement** :
>    - **node_exporter** sur tous les nœuds pour récupérer les métriques systèmes
>    - **Prometheus** pour la collecte et l’analyse des métriques (Swarm + système)
>    - **Grafana** pour la visualisation, dashboards dynamiques, alerting
>    - Dashboards personnalisés pour l’App, le Cluster et la base MySQL

---

## DNS et Sécurité SSL

> [!NOTE]
> - Gestion et déploiement *automatique* :
>    - Sous-domaines des services générés/MAJ par Ansible via Google Cloud DNS
>    - Certificats automatiques avec Certbot, plugin Google, wildcard et gestion du renouvellement
>    - Traefik effectue le hot-reload des certificats sans downtime

---

## Sauvegarde & restauration

> [!NOTE]
> - Script de sauvegarde automatisé, scheduled via cron sur le Manager principal
> - Dump MySQL journalier, compressé et uploadé dans Google Cloud Storage (GCS)
> - Rotation des logs et conservation sur 30 jours via logrotate

---

## À retenir

> [!NOTE]
> - **Toute l’infrastructure est déclarative et reproductible** (Infrastructure as Code)
> - **Sécurité** : VPN VPC privé, accès SSH restreint, backup externalisé, SSL partout
> - **Scalabilité** et **résilience** grâce à Swarm et l’auto-configuration Ansible
> - **Pipelines CI/CD robustes et audités (versionnés, logs et releases automatiques)**
> - **Proche production/labo :** montée en charge facile, rollback rapide, surveillance proactive

---

> [!NOTE]
> - Ce projet mélange gestion du cycle de vie applicatif, infrastructure cloud, sécurité, backup, supervision et automatisation avancée.

> - **Contact** : Guigan713
