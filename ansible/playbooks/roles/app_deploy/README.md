# Rôle Ansible : app_deploy

Déploiement, mise à jour et vérification automatisée du stack applicatif Docker Swarm

## Objectif

Ce rôle gère le cycle complet de déploiement sur cluster Swarm, assure le nettoyage des anciennes ressources inutilisées, prépare le réseau overlay, déploie la stack Docker à partir du compose, puis vérifie de bout en bout la présence et l’état de tous les services attendus.

## Etapes principales du rôle

### Préparation de l’environnement

> - Installation de la dépendance jsondiff en Python3 (utilisée par plusieurs modules Docker d’Ansible)
> - Nettoyage automatisé du serveur Docker : suppression des images et containers orphelins (optimisation de l’espace disque, évite les conflits de nom/image)
> - Suppression de la stack précédente si elle existe (rollback safe)
> - Pause forcée pour garantir que toutes les ressources soient bien libérées

### Provisionnement du réseau et déploiement

> - Création ou validation automatique du réseau overlay Swarm dédié à l’application (app_network)
> - Déploiement du stack applicatif à partir du compose Swarm généré et versionné (compose-swarm.yml)
> - Pause supplémentaire, pour garantir la montée en charge de tous les services

### Vérifications robustes post-déploiement

> - Audit complet de l’état du stack déployé via docker_stack_info
> - Extraction dynamique des services du stack et comptage automatique
> - Vérification individuelle de la présence de chaque service clé attendu (liste dans app_services)
> - Échec explicite et immédiat du déploiement si un service (frontend, backend, database, monitoring...) est manquant ou KO
> - Affichage détaillé des endpoints applicatifs et d’administration directement en sortie (facilite la QA, le monitoring et l’accès rapide pour les dev/ops)

### Variables principales

> - **app_services** : Liste des services attendus dans la stack (modulo autoscale, ex: traefik, frontend, backend, database, prometheus, grafana).
> - **project_name** : Nom du projet/stack Docker Swarm.
> - **app_directory, app_name** : Arborescence du déploiement.
> - **domain_name, grafana_domain, prometheus_domain...** : Pour affichage/monitoring automatique post-déploiement.
> - **grafana_admin_user, prometheus_retention_time...** : Configuration fine des services monitorés.

## Exemple d’utilisation

### Dans le playbook principal :

```yml
- hosts: swarm_managers
  roles:
    - role: app_deploy
```

## Pré-requis

> - La collection Ansible community.docker (installer : ansible-galaxy collection install community.docker)
> - Accès sudo/root sur les nœuds managers (pour les étapes prune, réseau, stack)
> - Fichier compose-swarm.yml généré en amont à l’emplacement requis
> - Variables d’environnement et liste des app_services correctement définies dans group_vars et template .env
