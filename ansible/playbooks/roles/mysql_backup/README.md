# MySQL Backup Role

## Description
Ce rôle configure un système de sauvegarde automatisé pour MySQL avec upload vers Google Cloud Storage, incluant la rotation des logs et la planification via cron.

## Tâches principales

### 1. Préparation de l'environnement
- **Create backup scripts directory** : Crée le répertoire `/opt/scripts/`
  - Permissions : 755
  - Utilisé pour stocker les scripts de sauvegarde

### 2. Installation du script de sauvegarde
- **Installer le script de backup MySQL** : Déploie le script de sauvegarde
  - Source : `templates/mysql-backup.sh.j2`
  - Destination : `/opt/scripts/mysql-backup.sh`
  - Permissions : 755 (exécutable)
  - Propriétaire : root

### 3. Planification automatique
- **Configurer le cron job de backup** : Programme l'exécution quotidienne
  - **Nom** : "MySQL Backup quotidien"
  - **Planification** : Tous les jours à 2h00 (minute: 0, heure: 2)
  - **Commande** : `/opt/scripts/mysql-backup.sh >> /var/log/mysql-backup.log 2>&1`
  - **Utilisateur** : root
  - **Logs** : Redirection vers `/var/log/mysql-backup.log`

### 4. Gestion des logs
- **Gérer la rotation de logs** : Configure logrotate pour le fichier de logs
  - **Fichier** : `/etc/logrotate.d/mysql-backup`
  - **Fréquence** : quotidienne
  - **Rétention** : 30 jours
  - **Compression** : activée
  - **Options** : `missingok`, `notifempty`

## Script de sauvegarde (mysql-backup.sh)

### Variables d'environnement
- `BUCKET_NAME` : Nom du bucket Google Cloud Storage
- `DB_NAME` : Nom de la base de données (défaut: "myapp")
- `MYSQL_ROOT_PASSWORD` : Mot de passe root MySQL
- `BACKUP_DIR` : Répertoire temporaire (`/tmp/backups`)
- `DATE` : Timestamp pour nommer les fichiers

### Processus de sauvegarde

#### 1. Préparation
- Création du répertoire temporaire `/tmp/backups`
- Génération du timestamp pour nommer le backup

#### 2. Dump MySQL
```bash
docker exec $(docker ps -qf "name=mysql") \
  mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
  --all-databases \
  --routines \
  --triggers > mysql_backup_$DATE.sql
```
- **Conteneur cible** : Trouve automatiquement le conteneur MySQL
- **Options** : Toutes les bases, routines et triggers inclus
- **Format** : Fichier SQL non compressé

#### 3. Compression
- Compression gzip du fichier SQL
- Réduction significative de la taille

#### 4. Upload vers GCS
```bash
gsutil cp mysql_backup_$DATE.sql.gz \
  gs://$BUCKET_NAME/mysql/mysql_backup_$DATE.sql.gz
```
- Upload vers le sous-répertoire `mysql/` du bucket
- Nom de fichier avec timestamp

#### 5. Nettoyage
- Suppression des fichiers temporaires locaux
- Libération de l'espace disque

## Configuration logrotate

### Fichier de configuration
```
/var/log/mysql-backup.log {
    daily
    rotate 30
    compress
    missingok
    notifempty
}
```

### Paramètres
- **daily** : Rotation quotidienne
- **rotate 30** : Garde 30 fichiers (30 jours)
- **compress** : Compression des anciens logs
- **missingok** : Pas d'erreur si le fichier n'existe pas
- **notifempty** : Pas de rotation si le fichier est vide

## Prérequis

### Système
- Docker installé et service MySQL en cours d'exécution
- Google Cloud SDK (`gsutil`) installé et configuré
- Cron service actif

### Variables d'environnement
- `BUCKET_NAME` : Bucket GCS de destination
- `MYSQL_ROOT_PASSWORD` : Mot de passe root MySQL
- Authentification GCS configurée

### Permissions
- Le script s'exécute en tant que root
- Accès Docker pour exécuter des commandes dans les conteneurs
- Permissions d'écriture sur `/tmp/backups`
- Accès réseau vers Google Cloud Storage

## Monitoring
- **Logs** : `/var/log/mysql-backup.log`
- **Rotation** : Automatique via logrotate
- **Planification** : Vérifiable via `crontab -l`
- **Dernière exécution** : Timestamp dans les logs
