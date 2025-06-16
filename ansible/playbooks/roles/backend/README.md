# Ansible Backend Deployment

Ce playbook Ansible automatise le déploiement d'une application backend sur un serveur distant en utilisant Docker Compose.

## Fonctionnalités

> - Création d'archive du code backend local
> - Transfert sécurisé vers le serveur cible
> - Extraction et configuration des fichiers
> - Génération automatique des fichiers de configuration
> - Déploiement via Docker Compose

## Structure du déploiement

```
/home/guillaume/backend/
├── docker-compose.yml
├── .env
└── [fichiers de l'application backend]
```

## Prérequis

> - Ansible installé sur la machine locale
> - Docker et Docker Compose installés sur le serveur cible
> - Utilisateur `guillaume` configuré sur le serveur distant
> - Templates Jinja2 : `docker-compose.yml.j2` et `.env.j2`

## Variables configurables

| Variable | Description | Défaut |
|----------|-------------|--------|
| `project_root` | Chemin racine du projet local | - |
| `backend_cleanup` | Nettoyer les anciennes images Docker | `false` |
| `backend_force_rebuild` | Forcer la reconstruction des images | `false` |


## Utilisation

### Exécution complète

`ansible-playbook -i inventories/hosts.yml playbooks/playbook.yml`

### Exécution avec tags

```bash
# Déploiement backend uniquement
ansible-playbook -i inventories/hosts.yml playbooks/playbook.yml --tags backend -v

# Avec options avancées
ansible-playbook -i inventories/hosts.yml playbooks/playbook.yml --tags backend \
  -e backend_cleanup=true \
  -e backend_force_rebuild=true
```

## Étapes du déploiement

> - **Archivage local** : Création d'une archive tar.gz du répertoire backend
> - **Transfert** : Copie de l'archive vers le serveur distant
> - **Préparation** : Création des répertoires nécessaires
> - **Extraction** : Décompression des fichiers sur le serveur
> - **Configuration** : Génération des fichiers docker-compose.yml et .env
> - **Déploiement** : Construction et lancement des services Docker

## Handlers

Le playbook utilise un handler restart backend qui sera déclenché lors des modifications des fichiers de configuration.

## Sécurité

> - Le fichier .env est créé avec les permissions 0600 pour protéger les variables sensibles
> - Tous les fichiers sont assignés à l'utilisateur guillaume
> - Nettoyage automatique des archives temporaires
