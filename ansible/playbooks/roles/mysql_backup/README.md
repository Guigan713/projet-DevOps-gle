# Rôle Ansible : mysql_backup

Automatisation des sauvegardes MySQL Docker avec mise en place complète : script, cron, logs, upload cloud, rotation

## Objectif

### Ce rôle configure en une seule passe :

> - l’automatisation des backups MySQL pour un service Swarm ou conteneurisé,
> - l’installation du script de sauvegarde paramétrable,
> - la planification quotidienne via cron,
> - la gestion de la rotation des logs pour éviter l’encombrement disque,
> - l’expédition directement sur Google Cloud Storage

## Détail du workflow

> - Création d’un répertoire centralisé /opt/scripts pour accueillir les scripts d’administration.
> - Déploiement du script de sauvegarde MySQL, prêt à l’emploi (template shell compatible Docker Swarm avec dump/compresse/upload GCS).
> - Programmation automatique du job planifié dans crontab (root) pour sauvegarde chaque nuit à 2h du matin (modifiable).
> - Mise en place d’un fichier de rotation logrotate pour /var/log/mysql-backup.log (limite à 30 jours, compression, sûreté).
> - Exécution du script : dump complet + upload sur bucket GCS avec nettoyage local automatique.

## Variables paramétrables côté script (mysql-backup.sh)

> - **BUCKET_NAME** : nom du bucket Google Cloud Storage cible
> - **DB_NAME** : nom de la base à sauvegarder
> - **MYSQL_ROOT_PASSWORD** : injecté automatiquement depuis l’environnement du conteneur MySQL pour sécurisation
> - **BACKUP_DIR** : dossier temporaire pour stockage avant upload/cloud
> - **DATE** : tag d’identification du backup (timestamp)

## onditions et prérequis

> - Dépendances côté serveur cible :
>    - docker (commande docker exec doit être présente)
>    - gsutil configuré (accès au bucket GCS : soit avec clef de service, soit Workload Identity)
>    - Accès root pour la gestion de cron, scripts et rotation
>    - Variable d’environnement MYSQL_ROOT_PASSWORD

## Dans le playbook principal :

```yml
- hosts: db_servers
  become: yes
  roles:
    - mysql_backup_automation
```