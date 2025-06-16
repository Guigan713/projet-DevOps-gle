# Ansible Database Deployment

Ce playbook Ansible automatise le déploiement et la configuration d'une base de données MySQL avec sauvegarde automatisée.

## Fonctionnalités

> - Déploiement de MySQL via Docker Compose
> - Configuration automatique des utilisateurs et permissions
> - Script de sauvegarde automatisé avec tâche cron
> - Vérification de la disponibilité du service

## Structure du déploiement

```
/home/guillaume/database/
├── docker-compose.yml
├── [fichiers de configuration MySQL]
└── [volumes et données]

/usr/local/bin/
└── mysql_backup.sh
```


## Prérequis

> - Ansible installé sur la machine locale
> - Docker et Docker Compose installés sur le serveur cible
> - Module Python `PyMySQL` pour les opérations MySQL
> - Variables vault configurées pour les mots de passe

## Variables requises

| Variable | Description | Type |
|----------|-------------|------|
| `project_root` | Chemin racine du projet local | Requis |
| `vault_db_password` | Mot de passe utilisateur MySQL (vault) | Requis |
| `vault_db_root_password` | Mot de passe root MySQL (vault) | Requis |
| `db_name` | Nom de la base de données | Requis |

## Installation des dépendances

```bash
# Installation du module Python pour MySQL
pip install PyMySQL

# Ou via le gestionnaire de paquets système
sudo apt install python3-pymysql  # Debian/Ubuntu
sudo yum install python3-PyMySQL      # RHEL/CentOS
```

## Utilisation

### Exécution complète

`ansible-playbook -i inventories/hosts.yml playbooks/playbook.yml`

## Étapes du déploiement

> - **Création des répertoires** : Préparation de l'arborescence
> - **Copie des fichiers** : Transfert des fichiers de configuration MySQL
> - **Lancement des services** : Démarrage de MySQL via Docker Compose
> - **Vérification** : Attente de la disponibilité du service (port 3306)
> - **Configuration utilisateur** : Création de l'utilisateur avec privilèges
> - **Sauvegarde** : Installation du script et configuration cron

## Configuration de la sauvegarde

### Script automatisé

> - **Fréquence** : Quotidienne à 2h00
> - **Emplacement** : /usr/local/bin/mysql_backup.sh
> - **Logs** : /var/log/mysql_backup.log


## Sécurité

> - Mots de passe stockés dans Ansible Vault
> - Script de sauvegarde avec permissions restreintes (0700)
> - Utilisateur MySQL avec privilèges limités à la base spécifique
