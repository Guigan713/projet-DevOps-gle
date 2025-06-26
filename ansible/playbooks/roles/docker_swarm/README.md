# Rôle Ansible : docker_swarm

Initialisation et configuration automatisée d’un cluster Docker Swarm (multi-managers & workers, réseaux, labels)

## Objectif

Ce rôle Ansible permet de créer, configurer et labelliser automatiquement un cluster Docker Swarm haute disponibilité prêt pour l’orchestration de stacks de microservices.

Il couvre l’initialisation Swarm (leader, tokens), la jointure automatique des nœuds managers et workers, la création des réseaux/volumes nécessaires, et la labellisation sélective des managers pour les services spécialisés (Traefik, monitoring...).

## Fonctionnalités principales

> - Initialise Swarm sur le premier nœud manager.
> - Récupère dynamiquement les tokens d’adhésion managers/workers.
> - Joint automatiquement tous les autres managers et tous les workers au cluster, en diffusant les tokens et l’IP du leader
>    - Supporte le ré-exécution sur un cluster déjà partiellement monté (détection automatique du statut Swarm)
>    - Ignore proprement les erreurs de double jointure ou si le nœud est déjà dans le cluster
> - Crée les réseaux overlay nécessaires à l’application (app_network, traefik-public, monitoring_network, modulables)
> - Crée les volumes Docker persistants pour les bases et le monitoring (mysql_data, prometheus_data, grafana_data)
> - Labellise le leader pour activer les fonctionnalités avancées (Traefik, monitoring, etc.)

## Structure du role

> - Initialisation Swarm si besoin (leader)
> - Récupération et injection des tokens pour managers et workers
> - Jointure de tous les managers restants au cluster
> - Jointure de tous les workers au cluster
> - Sur le leader seulement :
>    - Provisionnement des réseaux overlay
>    - Création des volumes
>    - Labellisation pour habiliter certains services

## Variables & Groupes attendus

> - **groups['swarm_managers']** : liste des hosts managers Swarm (prend le 1er comme leader)
> - **groups['swarm_workers']** : liste de tous les workers (peut être vide ou non défini si seulement du HA manager)
> - ****ansible_default_ipv4.address**** : utilisé pour l’init et pour propager l’adresse publique du leader
> - **Liste des réseaux/volumes/labels** : modifiables à souhait (voir tâches en loop)

## Exemples d’inventaire minimal attendu

```ini
[swarm_managers]
manager1 ansible_host=1.2.3.4
manager2 ansible_host=1.2.3.5

[swarm_workers]
worker1 ansible_host=1.2.3.10
worker2 ansible_host=1.2.3.11
```

## Exemple d’utilisation

```yml
- hosts: swarm_managers:swarm_workers
  become: yes
  roles:
    - docker_swarm
```