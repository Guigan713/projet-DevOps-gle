# projet-DevOps-gle

## Introduction

Ce projet de fin détude a pour but de mettre en avant les compétences aquises lors de ma formation (administrateur système DevOps). 
Le but de ce projet est de déployer une application (Sneaker Portfolio) développée par mes soins à la suite de mon précédent cursus de développeur web full stack. Les technologies utilisées pour cette application sont **ReactJs** pour la partie frontend, **Express.Js** pour la partie backend et **MySQL** comme base de données.

Le but est d'automatiser la *création de l'infrastructure*, le *déploiement continu* et le *monitoring* d'une plateforme de microservices à l'aide des outils DevOps modernes : **Terraform**, **Ansible**, **Docker Swarm**, **Traefik**, **Prometheus/Grafana**, et une chaîne **CI/CD GitHub Actions**.

Pour la partie DevOps, les technologies utilisées sont:

> [!NOTE]
> - **Terraform** : Création de l'infrastructure globale qui accueillera l'application
> - **Ansible** : Configuration des serveurs qui accueilleront les différents services 
> - **Docker** : Conteneurisation des différents services
> - **CI/CD GitHub Actions** : automatisation des tests, builds et déploiements sur les serveurs de production
> - **Prometheus & Grafana** : Monitoring de l'application
> - **Reverse Proxy/Load balancer** : Load Balancer GCP + Traefik pour le routage interne

## Architecture technique

> [!NOTE]
> - **Infrastructure Cloud** : GCP compute instances, VPC, Firewall rules et Load Balancer — *provisionnée par Terraform*
> - **Cluster applicatif** : Docker Swarm multi-nœuds (managers & workers)
> - **Reverse Proxy / Load Balancing** : Load Balancer GCP en frontal + Traefik interne pour le routage des services
> - **Certificats SSL** : Certificats managés automatiquement par Google Cloud Load Balancer (google_compute_managed_ssl_certificate)
> - **Monitoring** : Prometheus (collecte), Grafana (visualisation), Node Exporter (métriques système)
> - **Sauvegarde** : Backup MySQL automatisé et export vers Google Cloud Storage
> - **DNS** : Gestion automatisée via Ansible et API Google Cloud DNS
> - **CI/CD & Orchestration** : Pipelines GitHub Actions pour build/push/test/deploy

## Terraform_GCP

> [!NOTE]
> - **Infrastructure core** :
>   - Création des Instances compute-instances (nodes) qui accueilleront les différents services
>   - Création des VPC et sous-réseaux qui accueilleront les instances
>   - Création des règles de sécurité (quels services sont accessibles publiquement, par quels ports...)
> - **Load Balancer & SSL** :
>   - Déploiement d'un Load Balancer GCP managé avec health checks
>   - Certificats SSL automatiquement managés par Google (`google_compute_managed_ssl_certificate`)
>   - Gestion des domaines et sous-domaines (*.sneakerportfolio.eu)
> - **Sauvegarde & Scripts** :
>   - Création d'une sauvegarde automatisée de la base de données sur un bucket Google/GCP
>   - Mise en place d'un script bash qui automatise la création des hosts pour Ansible

## Ansible

> [!NOTE]
> - **Installation des outils sur chaque nœud**:
>    - Docker & Docker Compose Plugin
>    - Traefik (Reverse Proxy/Load balancer interne)
>    - **node_exporter** pour la gestion de la partie monitoring (métriques)
> - **Configuration fine** :
>    - Gestion des utilisateurs/admins et accès SSH sécurisés
>    - Configuration sudoers, ouverture des ports, sécurisation bas niveau
>    - Déploiement automatisé du cluster Docker Swarm (init/join, labels, overlay networks)
>    - Déploiement des stacks applicatives via Docker Compose (playbooks dynamiques, tag d'image versionné)
> - **Monitoring essentiel** :
>    - Déploiement de node_exporter sur chaque nœud (scrap Prometheus)
>    - Monitoring : installation, gestion des dashboards Grafana, alertes
> - **Sauvegarde / Sécurité des données** :
>    - Script et cron de backup MySQL, upload dans un bucket Google/GCP, rotation et gestion des logs
> - **Gestion du DNS** :
>    - Création/mise à jour automatique des entrées DNS pour chaque service (Traefik, API, Prometheus, …) via Google Cloud DNS API
>    - Propagation automatisée des enregistrements A vers l'IP du Load Balancer GCP
> - **Déploiement post-install** :
>    - Injection automatique du schéma et des données de base MySQL après le déploiement des services

---

## Docker & Swarm

> [!NOTE]
> - **Conteneurisation complète** :
>    - *Dockerfiles* dédiés pour chaque service (frontend, backend)
>    - Déploiement via Docker Compose en local ET via stack Docker Swarm pour la prod
> - **Cluster Swarm sur GCP** :
>    - Déploiement manager/worker multi-nœuds avec labels/service affinities
>    - Service discovery : accès par noms de services internes et par sous-domaines Traefik
>    - Déploiement blue/green ou rolling via stack Swarm, versionné à chaque release
> - **Reverse Proxy & Load-Balancer** : 
>    - Load Balancer GCP managé en frontal (HTTPS/SSL terminaison)
>    - Traefik interne pour le routage des services (auto-découverte, dashboard realtime)

---

## CI/CD : GitHub Actions

> [!NOTE]
> - **Automatisation complète :**
>    - Pipeline déclenché à chaque push sur `main` (après succès des tests)
>    - Build & push automatisé des images Docker vers le registry
>    - Tests automatisés : lint front/back, tests unitaires (SonarQube en option)
>    - Génération d'un tag d'image unique pour chaque release/commit
>    - Déploiement automatique : connexion SSH sécurisée, exécution des playbooks Ansible
>    - Propagation automatique du tag de version dans les templates Docker Swarm
>    - Workflow en deux étapes : Test → Deploy (si tests OK)

---

## Monitoring & Supervision

> [!NOTE]
> - **Stack de monitoring déployée automatiquement** :
>    - **node_exporter** sur tous les nœuds pour récupérer les métriques systèmes
>    - **Prometheus** pour la collecte et l'analyse des métriques (Swarm + système)
>    - **Grafana** pour la visualisation, dashboards dynamiques, alerting
>    - Dashboards personnalisés pour l'App, le Cluster et la base MySQL

---

## DNS et Sécurité SSL

> [!NOTE]
> - **DNS managé par Ansible** :
>    - Sous-domaines des services générés/MAJ automatiquement via Google Cloud DNS API
>    - Enregistrements A pointant vers l'IP publique du Load Balancer GCP
> - **SSL managé par Terraform** :
>    - Certificats SSL automatiquement provisionnés et renouvelés par Google Cloud
>    - Support wildcard (*.sneakerportfolio.eu) et domaines spécifiques
>    - Aucune intervention manuelle requise, zero-downtime

---

## Sauvegarde & restauration

> [!NOTE]
> - Script de sauvegarde automatisé, scheduled via cron sur le Manager principal
> - Dump MySQL journalier, compressé et uploadé dans Google Cloud Storage (GCS)
> - Rotation des logs et conservation sur 30 jours via logrotate

---

## À retenir

> [!NOTE]
> - **Toute l'infrastructure est déclarative et reproductible** (Infrastructure as Code)
> - **Sécurité** : VPC privé GCP, accès SSH restreint via bastion, Load Balancer managé avec SSL, backup externalisé
> - **Scalabilité** et **résilience** grâce à Swarm et l'auto-configuration Ansible
> - **Pipelines CI/CD robustes et audités (versionnés, logs et releases automatiques)**
> - **Proche production/labo :** montée en charge facile, rollback rapide, surveillance proactive

---

> [!NOTE]
> - Ce projet mélange gestion du cycle de vie applicatif, infrastructure cloud, sécurité, backup, supervision et automatisation avancée.

> - **Contact** : Guigan713
