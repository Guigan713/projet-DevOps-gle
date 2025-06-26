# Rôle app_deploy

## Partie déploiement

### Installer jsondiff pour python3 (utilisé par Ansible) :

> - Installe la librairie Python jsondiff avec pip3, requise pour certaines tâches Ansible.

### Nettoyer les images Docker inutilisées :

> - Supprime toutes les images Docker qui ne sont plus utilisées pour libérer de l’espace.

### Nettoyer les conteneurs Docker inutilisés :

> - Supprime les conteneurs Docker arrêtés/obsolètes qui ne sont plus utilisés.

### Supprimer la stack existante (si elle existe) :

> - Retire la stack Docker nommée {{ project_name }} si elle existe déjà, afin de repartir sur une base propre.

### Attendre la suppression de la stack :

> - Pause de 10 secondes pour s’assurer que la stack précédente est bien supprimée avant de continuer.

### Créer le réseau Docker overlay app_network :

> - S’assure que le réseau Docker app_network de type overlay, utilisable en swarm, existe.

### Déployer la stack applicative :

> - Lance le déploiement de la stack Docker à partir du fichier compose compose-swarm.yml dans le dossier de l’application.

### Attendre le démarrage des services :

> - Pause de 30 secondes pour laisser le temps aux services Docker de démarrer correctement.

## Partie Vérification

### Vérifier le statut de déploiement de la stack :

> - Récupère les informations sur la stack Docker déployée.

### Filtrer pour trouver la stack spécifiquement nommée myapp :

> - Récupère uniquement les détails de la stack dont le nom correspond à myapp.

### Afficher le nombre de services de la stack :

> - Affiche combien de services sont actuellement déployés dans la stack (si trouvée).

### Vérifier chaque service du stack :

> - Vérifie (pour chaque nom de service dans app_services) si le service Swarm associé existe.

### Échouer si des services sont manquants :

> - Arrête l’exécution si tous les services attendus ne sont pas présents, et liste lesquels manquent.

### Afficher les endpoints des services déployés :

> - Résume les URLs d’accès aux différents composants de l’application : frontend, API backend, Grafana, Prometheus, Traefik Dashboard.



# Rôle docker_swarm

## Explication des tâches d'initialisation du cluster Docker Swarm

### Initialisation du Swarm

- **Initialize Swarm on first manager**
  - Vérifie si le mode Swarm est déjà activé sur le premier manager.
  - Initialise le cluster Swarm si ce n'est pas déjà fait sur ce noeud.
  - Récupère le token d'ajout des managers et des workers.
  - Les tokens et l’adresse IP du leader sont stockés pour la suite du playbook.
  - **Exécuté uniquement sur le premier manager du cluster.**

---

### Vérification de l’état Swarm sur tous les noeuds

> - **Check if node is already in the swarm (for all)**
>  - Vérifie si chaque noeud est déjà intégré au cluster Swarm.

---

### Ajout des membres au cluster Swarm

> - **Join additional managers**
>  - Les managers secondaires rejoignent le cluster, si ce n’est pas déjà le cas, à l’aide du token manager.
>  - Ignore les erreurs si elles se produisent.

> - **Join workers**
>  - Les workers rejoignent le cluster, si ce n’est pas déjà fait, à l’aide du token worker.

---

### Configuration avancée (uniquement sur le leader/manager principal)

> - **Create application networks**
>  - Crée les réseaux Docker nécessaires (`app_network`, `traefik-public`, `monitoring_network`) avec le driver overlay pour le multihost.

> - **Create Docker volumes for persistence**
>  - Crée les volumes Docker pour garantir la persistance des données des services (`mysql_data`, `prometheus_data`, `grafana_data`).

> - **Get manager node hostname**
>  - Récupère le nom d’hôte du noeud manager principal via Docker.

> - **Label manager node for specific services**
>  - Ajoute des labels spécifiques (`traefik.enable`, `monitoring.enable`) au manager principal pour contrôler le placement des services Traefik et Monitoring sur ce noeud.

---

> **Remarque :**  
> Toutes les étapes de configuration réseau, de création des volumes et d’ajout de labels ne sont exécutées que sur le manager principal du cluster Swarm.

# Rôle mysql_backup

## Automatisation du backup MySQL avec Ansible

### Étapes automatisées

> - **Create backup scripts directory**
>  - Crée le répertoire `/opt/scripts` (avec droits 755) destiné à accueillir les scripts de sauvegarde sur la machine cible.

> - **Installer le script de backup MySQL**
>  - Déploie le script de sauvegarde MySQL (`mysql-backup.sh`), généré à partir d'un template Jinja2, dans `/opt/scripts` et le rend exécutable par root.

> - **Configurer le cron job de backup**
>  - Planifie une tâche cron pour exécuter le script de backup tous les jours à 2h du matin, en journalisant les sorties dans `/var/log/mysql-backup.log`.

> - **Gérer la rotation de logs pour mysql-backup**
>  - Crée une configuration logrotate pour `/var/log/mysql-backup.log` :
>    - Rotation quotidienne
>    - Conservation des 30 derniers fichiers
>    - Compression
>    - Ignore si le fichier log n’existe pas ou est vide

---

### Contenu du script de backup (`mysql-backup.sh`)

Ce script shell effectue les opérations suivantes :

1. **Initialisation**
    - Définit les variables d’environnement (nom du bucket GCS, nom de la base, dossier de backup, date).

2. **Préparation**
    - Crée le dossier local temporaire de backup.

3. **Dump de la base MySQL**
    - Lance un dump de toutes les bases MySQL via `mysqldump` à l’intérieur du conteneur Docker nommé `mysql`.

4. **Compression**
    - Gzip le fichier SQL généré.

5. **Upload vers Google Cloud Storage**
    - Transfère le backup compressé vers un bucket GCS via `gsutil`.

6. **Nettoyage**
    - Supprime le dossier de backup local pour ne pas saturer l’espace disque.

---

#### Exemple du script généré par le template (`mysql-backup.sh`)

```bash
#!/bin/bash
set -e

# Variables d'environnement
BUCKET_NAME="${BUCKET_NAME}"
DB_NAME="${DB_NAME:-myapp}"
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Création du répertoire de backup
mkdir -p $BACKUP_DIR

# Backup MySQL depuis le service Docker Swarm
echo " Démarrage du backup MySQL..."
docker exec $(docker ps -qf "name=mysql") \
  mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
  --all-databases \
  --routines \
  --triggers > $BACKUP_DIR/mysql_backup_$DATE.sql

# Compression
gzip $BACKUP_DIR/mysql_backup_$DATE.sql

# Upload vers GCS
echo " Upload vers Google Cloud Storage..."
gsutil cp $BACKUP_DIR/mysql_backup_$DATE.sql.gz \
  gs://$BUCKET_NAME/mysql/mysql_backup_$DATE.sql.gz

# Nettoyage local
rm -rf $BACKUP_DIR

echo " Backup terminé: mysql_backup_$DATE.sql.gz"
```

# Rôle dns_managment

## Gestion automatisée du DNS Google Cloud & Certificats SSL (dns_setup)

### 1. Installation et configuration du Google Cloud SDK

- **Ajout de la clé du dépôt Google Cloud SDK**
  - Télécharge la clé GPG du dépôt Google Cloud et l’ajoute à l'autorité de confiance du système.

- **Ajout du dépôt Google Cloud SDK**
  - Ajoute le dépôt `cloud-sdk` dans la liste des sources APT pour permettre l'installation via le gestionnaire de paquets.

- **Installation du Google Cloud SDK et des outils réseau**
  - Installe les paquets nécessaires : `google-cloud-sdk`, `curl` et `dnsutils` sur le poste de contrôle (localhost) et sur les serveurs distants.

- **Détection de l’IP externe du Load Balancer**
  - Récupère l’adresse IP publique du poste de gestion (utilisée pour la configuration des enregistrements DNS).

- **Authentification sur Google Cloud**
  - Utilise un fichier de compte de service pour authentifier la CLI Google Cloud (`gcloud`) et prépare la configuration pour le bon projet.

---

### 2. Gestion dynamique des enregistrements DNS

- **Vérification de la zone DNS**
  - Vérifie que la zone DNS Google Cloud existe bien dans le projet ; stoppe l’exécution si la zone est absente.

- **Création ou mise à jour des enregistrements DNS A**
  - Pour chaque sous-domaine de service activé, tente de créer l’enregistrement ; met à jour l’enregistrement existant en cas de conflit ou changement d’IP.

- **Pause propagation DNS**
  - Attend que la propagation DNS soit effective avant de continuer (pause de 15 secondes).

- **Vérification des enregistrements DNS**
  - Vérifie que les nouveaux sous-domaines pointent bien vers la bonne IP publique via une requête `dig` (DNS Google).

- **Affichage du récapitulatif DNS**
  - Affiche un état résumé de la configuration DNS déployée (IP détectée, zone, domaine, sous-domaines/services configurés).

---

## ssl_setup

### 3. Génération des certificats SSL avec Certbot

- **Installation de Certbot et du plugin DNS Google**
  - Installe les paquets nécessaires pour générer des certificats SSL via DNS Google (supporte le wildcard et les sous-domaines).

- **Création du répertoire de stockage des certificats SSL**
  - Crée et sécurise le dossier `/opt/ssl-certificates` destiné à accueillir les certificats générés.

- **Génération des certificats SSL**
  - Génère un certificat principal pour le domaine racine.
  - Génère, pour chaque service/sous-domaine activé, le certificat SSL correspondant.
  - Génère un certificat wildcard pour `*.{{ domain_name }}` si besoin, via validation DNS Google.

- **Configuration de la tâche de renouvellement automatique**
  - Ajoute une task cron pour renouveler automatiquement les certificats tous les 15 jours et redéployer Traefik à la volée pour les prendre en compte.

- **Affichage des résultats de génération SSL**
  - Affiche un résumé des certificats obtenus : domaine principal, Traefik, Grafana, Prometheus, API, et wildcard.

---

## traefik_config

### 4. Configuration dynamique de Traefik

- **Création du dossier de configuration Traefik**
  - Crée le dossier `/opt/docker/traefik/config` pour stocker la configuration dynamique de Traefik.

- **Déploiement de la config dynamique Traefik**
  - Déploie la configuration dynamique générée via un template Ansible/Jinja (`traefik-dynamic.yml.j2`).

---

## main.yml

### 5. Contrôles complémentaires & Enchaînement SSL/DNS

- **Vérification de la propagation DNS de chaque sous-domaine**
  - Vérifie pour chaque sous-domaine configuré que la résolution pointe bien vers l’adresse IP attendue, côté Google DNS.

- **Affichage récapitulatif de l’état DNS**
  - Liste pour chaque service le sous-domaine configuré et l’IP détectée.

- **Génération et validation du certificat wildcard**
  - Génère le certificat wildcard pour *.{{ domain_name }} et le domaine racine, si l'option SSL est activée.

---

# playbook.yml

## Déroulé du Playbook d’Infrastructure et de Déploiement

### 1. Configuration SSH

- **Collecte des facts sur tous les serveurs**
  - Affiche des informations sur chaque serveur (nom d’hôte, adresse, rôle Swarm).
- **Création de l’utilisateur SSH**
  - Crée un utilisateur dédié, avec shell bash, accès sudo sans mot de passe, et home directory.
- **Préparation du dossier `.ssh`**
  - Crée le dossier sécurisé pour les clés SSH de l'utilisateur.
- **Déploiement de la clé publique**
  - Installe la clé publique sur chaque nœud (si définie).
- **Configuration du sudo**
  - Ajoute l’utilisateur au sudoers sans mot de passe via un fichier dédié et validation syntaxique avec visudo.

---

### 2. Installation de Docker sur tous les nœuds Swarm

- **Mise à jour des paquets**
  - Met à jour le cache des paquets APT.
- **Install des prérequis Docker**
  - Installe paquets essentiels et dépendances Python pour Docker (Ansible modules).
- **Ajout de la clé GPG et du dépôt Docker**
  - Configure les dépôts officiels et la clé de sécurité Docker.
- **Installation de Docker Engine et outils**
  - Installe le moteur, CLI, containerd et plugin Compose.
- **Activation du service**
  - Active et démarre le service Docker de manière persistante.
- **Ajout de l'utilisateur SSH au groupe Docker**
  - Permet à l’utilisateur de lancer les commandes docker sans sudo.
- **Nettoyage des services/ports conflictuels**
  - Force l’arrêt et suppression des containers exposant les ports 3000 ou 5000 (backend/Grafana).

---

### 3. Configuration du cluster Docker Swarm

- **Initialisation ou jointure du cluster Swarm**
  - Utilise un rôle dédié pour l'init/join du cluster Swarm (managers et workers).
  - Tag : `swarm`

---

### 4. Mise en place des backups MySQL

- **Déploiement du backup autom. MySQL**
  - Installe le rôle Ansible pour gérer le backup via script, cron daily.
  - Tag : `mysql`

---

### 5. Installation du monitoring système

- **Déploiement node_exporter sur tous les nœuds**
  - Installe l’exporter Prometheus sur chaque serveur pour relever les métriques de monitoring bas niveau.
  - Tag : `node_exporter`

- **Configuration avancée du monitoring**
  - Applique le rôle de monitoring (Prometheus, Grafana…) sur le manager principal.
  - Tag : `monitoring`

---

### 6. Build des applications et gestion des images

- **Build de l’application sur les nœuds Swarm**
  - Prépare l’arborescence ou les fichiers nécessaires sur tous les nœuds.
  - Tag : `build`

- **Build et push des images Docker (frontend/backend)**
  - Depuis la machine de build :
      - Authentifie sur DockerHub.
      - Génére un tag unique pour versionner les images.
      - Build et push l’image backend puis frontend avec le tag généré.

- **Propagation du tag d’image sur le manager**
  - Récupère le tag généré localement.
  - Passe ce tag Ansible comme variable pour templater les fichiers de déploiement de stack/docker compose (swarm).

---

### 7. Déploiement de l’application

- **Déploiement de la stack applicative**
  - Applique la stack Docker Swarm sur le manager principal.
  - Tag : `deploy`

- **Initialisation des données MySQL**
  - Cible le nœud hébergeant le conteneur MySQL, copie et injecte le script d’initialisation SQL dans la base via exec docker.

---

### 8. Gestion du DNS et des certificats SSL

- **Configuration DNS (Google Cloud) et SSL**
  - Sur le manager principal, utilise le rôle dédié pour :
    - Gérer les enregistrements DNS (Google Cloud DNS) pour chaque service ou sous-domaine.
    - Générer (certbot) et renouveler automatiquement les SSL pour les domaines/services déployés.
  - Tag : `dns`

---