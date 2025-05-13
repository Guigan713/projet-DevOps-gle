#!/bin/bash

DATE=$(date +%F_%H-%M)
BACKUP_DIR="/var/backups/mysql"
CONTAINER_NAME="mysql"  # <-- adapte ici si ton conteneur a un autre nom
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql"

# Création du dossier s’il n’existe pas
mkdir -p $BACKUP_DIR

# Dump depuis le conteneur
docker exec $CONTAINER_NAME \
  sh -c "mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME" > $BACKUP_FILE

# Suppression des anciens dumps locaux
find $BACKUP_DIR -type f -name "*.sql" -mtime +7 -exec rm {} \;

# Envoi vers S3
aws s3 cp $BACKUP_FILE s3://{{ s3_bucket_name }}/
