# projet-DevOps-gle

## Introduction

Ce projet de fin détude a pour but de mettre en avant les compétences aquises lors de ma formation (administrateur système DevOps). 
Le but de ce projet est de déployer une application (Sneaker Portfolio) développée par mes soins à la suite de mon précédent cursus de développeur web full stack. Les technologies utilisées pour cette application sont **ReactJs** pour la partie frontend, **Express.Js** pour la partie backend et **MySQL** comme base de données.

Pour la partie DevOps, les technologies utilisées sont:

> [!NOTE]
> - **Terraform** : Création de l'infrastructure globale qui accueillera l'application
> - **Ansible** : Configuration des serveurs qui accueilleront les différents services 
> - **Docker** : Conteneurisation des différents services
> - **CI/CD GitHub Actions** : automatisation des tests, builds et déploiements sur les serveurs de production
> - **Prometheus & Grafana** : Monitoring de l'application
> - **Reverse Proxy NGINX** : sécurité et répartition des requêtes vers les différents services de l'application

## Terraform AWS

> [!NOTE]
> - Création des Instances EC2 qui accueilleront les différents services
> - Création des VPC et sous-réseaux qui accueilleront les instances
> - Création des security-groups et leurs règles de sécurité (quels services sont accessibles publiquement, par quels ports...)
> - Création d'une sauvegarde automatisée de la base de données sur un bucket s3
> - Mise en place d'un script bash qui automatise la création des hosts (instances accueillant les différents services) qui serviront a la configuration des serveurs avec Ansible

## Ansible

> [!NOTE]
> - Installation des outils nécessaires au fonctionnement de l'application sur les serveurs:
    - **Docker**
    - **Nginx** pour le serveur reverse-proxy
    - **node_exporter** pour la gestion de la partie monitoring (métriques)
> - Copie des fichiers de l'application sur les serveurs (pour frontend et backend et bdd) et des fichiers de configuration (monitoring et reverse-proxy)
> - Déclenchement des Docker-compose pour installer les différents services sur les serveurs

## Docker

> [!NOTE]
> - Création des Dockerfile pour chaque services (frontend et backend)
> - Création des docker-compose pour chaque services (sauf nginx)
> - Création d'un docker-compose global pour tester en local

## CI/CD GitHub Actions

> [!NOTE]
> - Workflow de tests (déclenche un scan SonarQube qui analyse et détecte les erreurs, des failles de sécurité, de la duplication... )
> - Workflow de déploiement (builde l'application et installe ansible avant de déclencher les playbooks qui installeront la configuration Ansible sur les serveurs)
> - Workflow de Release qui met un place un versionning sémantique après chaque push sur GitHub
