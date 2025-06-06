# Déploiement d'une stack applicative avec Ansible

## Introduction

Ce projet Ansible permet d'automatiser le déploiement complet d'une stack applicative comprenant :

> [!NOTE]
> - Un backend
> - Un frontend
> - Une base de données
> - Un reverse proxy NGINX
> - Un système de monitoring avec Prometheus & Grafana
> - L'export de métriques via node_exporter sur tous les serveurs

## Prérequis

> [!NOTE]
> - Ansible >= 2.9
> - Configuration de l'inventaire automatisé par un script (**generate_hosts.sh**) lors du lancement de l'infrastructure terraform
> - Accès SSH avec privilèges sudo sur toutes les machines

## Déclenchement

Le déclenchement intervient de 2 façons:

> [!NOTE]
> - au déclenchemet du workflow GitHub Actions build-deploy.yml
> - Déclenchement manuel:
```bash
cd ansible
ansible-playbook -i inventories/hosts.ini playbooks/playbook.yml --private-key ../gle-key.pem
```


## Structure de playbook.yml

#### 1. node_exporter
> [!NOTE]
> - Déploiement de **node_exporter** sur tous les serveurs pour collecter les métriques système

#### 2. frontend
> [!NOTE]
> - Déploiement de l’application frontend sur les hôtes du groupe frontend.

#### 3. backend
> [!NOTE]
> - Déploiement de l’application backend sur les hôtes du groupe backend.

#### 4. database
> [!NOTE]
> - Déploiement et configuration de la base de données sur les hôtes du groupe database.

#### 5. Monitoring
> [!NOTE]
> - Déploiement de Prometheus et Grafana sur les hôtes du groupe monitoring pour la surveillance et la visualisation des métriques.

#### 6. reverse-proxy (NGINX)
> [!NOTE]
> - Mise en place d’un reverse proxy NGINX sur les hôtes du groupe reverse_proxy pour centraliser et sécuriser l’accès aux différents composants de la stack.



## Rôle backend

Ce rôle Ansible permet d’automatiser l’installation de Docker et Docker Compose, la création d’un répertoire de backend, la copie des fichiers nécessaires et le démarrage des services à l’aide de docker-compose sur le serveur backend de notre infrastructure

### Liste des tasks

#### 1. Installation de Docker et Docker-compose

> [!NOTE]
> - Installe les paquets docker.io et docker-compose, en s’assurant que la liste des paquets est à jour.

#### 2. Création du dossier backend

> [!NOTE]
> - Crée le dossier /home/ubuntu/backend avec les bons droits pour l’utilisateur ubuntu.

#### 3. Copie des fichiers backend

> [!NOTE]
> - Copie l’intégralité du dossier local backend (contenant le Dockerfile et le fichier docker-compose.yml) dans le dossier /home/ubuntu/backend sur la machine distante.

#### 4. Lancement du service avec Compose

> [!NOTE]
> - Exécute `docker-compose up -d` depuis le dossier /home/ubuntu/backend pour démarrer les services en arrière-plan.



## Rôle database

### Liste des tasks

#### 1. Installation de Docker et Docker Compose

> [!NOTE]
> - Mise à jour du cache et installation des paquets docker.io et docker-compose.

#### 2. Création du répertoire Database

> [!NOTE]
> - Création du dossier /home/ubuntu/database appartenant à l’utilisateur ubuntu.

#### 3. Copie des fichiers du service MySQL

> [!NOTE]
> - Copie tout le contenu local du dossier database vers /home/ubuntu/database sur la machine cible.

#### 4. Démarrage des services via Compose

> [!NOTE]
> - Exécution de `docker-compose up -d` dans ce dossier pour démarrer les conteneurs MySQL (et éventuellement d’autres services définis dans le compose).

#### 5. Déploiement du script de sauvegarde

> [!NOTE]
> - Copie du script mysql_backup.sh (stocké dans /templates) dans /usr/local/bin/, avec les droits d’exécution (0700).

#### 6. Planification des sauvegardes automatiques

> [!NOTE]
> - Ajout d’une tâche cron exécutant chaque jour à 2h du matin le script de backup, avec log des sorties dans /var/log/mysql_backup.log.



## Rôle frontend

Ce rôle Ansible permet d’automatiser l’installation de Docker et Docker Compose, la création d’un répertoire de frontend, la copie des fichiers nécessaires et le démarrage des services à l’aide de docker-compose sur le serveur frontend de notre infrastructure

### Liste des tasks

#### 1. Installation de Docker et Docker-compose

> [!NOTE]
> - Installe les paquets docker.io et docker-compose, en s’assurant que la liste des paquets est à jour.

#### 2. Création du dossier frontend

> [!NOTE]
> - Crée le dossier /home/ubuntu/frontend avec les bons droits pour l’utilisateur ubuntu.

#### 3. Copie des fichiers frontend

> [!NOTE]
> - Copie l’intégralité du dossier local frontend (contenant le Dockerfile et le fichier docker-compose.yml) dans le dossier /home/ubuntu/frontend sur la machine distante.

#### 4. Lancement du service avec Compose

> [!NOTE]
> - Exécute `docker-compose up -d` depuis le dossier /home/ubuntu/frontend pour démarrer les services en arrière-plan.



## Rôle monitoring

Ce rôle Ansible permet d’installer Docker et Docker Compose, de préparer l’environnement de monitoring, de transférer les fichiers de configuration nécessaires, puis de lancer la stack Prometheus et Grafana via docker-compose.

### Liste des tasks

#### 1. Installation de Docker et Docker-compose

> [!NOTE]
> - Installe les paquets docker.io et docker-compose, en s’assurant que la liste des paquets est à jour.

#### 2. Création du dossier de monitoring

> [!NOTE]
> - Crée /home/ubuntu/monitoring avec les droits appropriés (utilisateur et groupe : ubuntu).

#### 3. Copie des fichiers de configuration de monitoring

> [!NOTE]
> - Copie l’ensemble du dossier local monitoring (contenant notamment docker-compose.yml et prometheus.yml) vers /home/ubuntu/monitoring sur la machine distante

#### 4. Déploiement de la stack de monitoring via Docker Compose

> [!NOTE]
> - Exécute la commande `docker-compose up -d` dans /home/ubuntu/monitoring pour lancer les conteneurs Prometheus et Grafana (ou tout autre outil de monitoring défini dans le docker-compose.yml).


## Rôle node_exporter

Ce rôle Ansible automatise l’installation, la configuration, et la gestion du service Prometheus Node Exporter sur un serveur Linux, y compris la gestion d’utilisateur système dédié, la création de dossiers, le déploiement binaire, l’intégration systemd, et une vérification de bon fonctionnement.

### Liste des tasks

#### 1. Création d’un groupe système dédié

> [!NODE]
> - Crée le groupe Unix pour node_exporter, si absent.

#### 2. Création de l’utilisateur système node_exporter

> [!NODE]
> - Utilisateur système sans shell pour faire tourner node_exporter de façon sécurisée.

#### 3. Création des dossiers nécessaires

> [!NOTE]    
> - Création des répertoires de configuration (node_exporter_config_dir) et d’export textuel de métriques (node_exporter_textfile_dir) avec les bons droits.

#### 4. Vérification de l’existence et de la version de node_exporter

> [!NOTE]
> - Check si node_exporter est déjà présent et à la bonne version, pour éviter une réinstallation inutile.

#### 5. Téléchargement et extraction de node_exporter

> [!NOTE]
> - Si absent ou de mauvaise version, télécharge l’archive officielle, extrait et positionne le binaire à l’emplacement voulu.

#### 6. Déploiement du binaire

> [!NOTE]
> - Copie le binaire dans le dossier cible avec les bons droits.

#### 7. Nettoyage

> [!NOTE]
> - Supprime l’archive/dossier temporaire d’installation.

#### 8. Déploiement du service systemd
    
> [!NOTE]
> - Installe le service à partir d’un template et (re)charge systemd.

#### 9. Démarrage & enable du service
    
> [!NOTE]
> - Démarre node_exporter au boot et s’assure qu’il tourne.

#### 10. Vérification du fonctionnement
    
> [!NOTE]   
> - Tente d’accéder en HTTP local au port du service pour s’assurer qu’il répond.

#### 11. Message de status

> [!NOTE]
> - Affiche un message clair lorsque node_exporter tourne correctement.

### Items du rôle

> [!NOTE]
> - defaults/main.yml : variables par défaut nécessaires au fonctionnement du rôle
> - handlers/main.yml : ces handlers permettent de recharger la configuration **systemd** et de redémarrer le service **node_exporter**. 
> - templates/node_exporter.service.j2 : template systemd utilisé avec Ansible pour déployer et gérer le service Prometheus Node Exporter sur un serveur Linux. Il exploite les variables du playbook pour configurer dynamiquement le service en fonction de nos besoins de supervision.


## Rôle reverse-proxy

Ce rôle Ansible permet d’installer et de configurer un reverse proxy NGINX sur Ubuntu/Debian, et d’obtenir automatiquement un certificat SSL gratuitement via Certbot (Let's Encrypt).
Il s’appuie sur nos fichiers de configuration et assure le déploiement idempotent.

### Liste des tasks

#### 1. Installation de NGINX et Certbot

> [!NOTE]
> - Installation du serveur web NGINX et du client Certbot (python3-certbot-nginx).

#### 2. Déploiement de la configuration NGINX

> [!NOTE]
> - Copie le fichier nginx.conf fourni dans /etc/nginx/nginx.conf.
> - Redémarrage de NGINX si besoin.

#### 3. Activation & démarrage de NGINX

> [!NOTE]
> - Vérifie que NGINX est lancé et activé au démarrage.

#### 4. Vérification de disponibilité du site
    
> [!NOTE]
> - Attente du fonctionnement de NGINX (pour garantir la réussite de Certbot).

#### 5. Obtention du certificat SSL LetsEncrypt

> [!NOTE]
> - Demande non-interactive et automatique du certificat pour le domaine spécifié.
> - Le certificat et sa clé sont déposés dans /etc/letsencrypt/live/monapp.example.com/.

#### 6. Rechargement de NGINX
    
> [!NOTE]
> - Reload automatique de NGINX pour activer le HTTPS.
