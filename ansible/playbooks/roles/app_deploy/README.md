# App Deploy Role

## Description
Ce rôle déploie la stack applicative complète sur le cluster Docker Swarm en utilisant Docker Compose et vérifie le bon déploiement de tous les services.

## Tâches principales

### 1. Préparation de l'environnement
- **Install jsondiff for python3** : Installe la dépendance Python jsondiff requise par Ansible
- **Prune unused Docker images** : Nettoie les images Docker inutilisées pour libérer l'espace
- **Prune unused Docker containers** : Nettoie les conteneurs Docker arrêtés

### 2. Déploiement de la stack
- **Remove existing stack** : Supprime la stack existante si elle existe (pour redéploiement propre)
- **Wait for stack removal** : Attend 10 secondes pour s'assurer de la suppression complète
- **Ensure Docker overlay network exists** : Vérifie/crée le réseau overlay `app_network`
- **Deploy application stack** : Déploie la stack avec le fichier `compose-swarm.yml`
- **Wait for services to be ready** : Attend 30 secondes le démarrage des services

### 3. Vérification du déploiement
- **Check stack deployment status** : Récupère les informations sur toutes les stacks
- **Trouver mon stack** : Filtre pour trouver notre stack spécifique
- **Display stack services count** : Affiche le nombre de services déployés
- **Vérifier tous les services** : Vérifie individuellement chaque service de la liste
- **Échouer si services manquants** : Fait échouer le déploiement si des services sont manquants

## Configuration réseau

### Réseau overlay créé
- **Nom** : `app_network`
- **Driver** : overlay
- **Attachable** : true
- **Scope** : swarm
- **Internal** : false

## Services vérifiés
La vérification porte sur tous les services définis dans `app_services` :
- traefik
- frontend  
- backend
- database
- prometheus
- grafana

## Variables utilisées
- `project_name` : Nom de la stack Docker Swarm
- `app_directory` : Répertoire contenant le fichier compose-swarm.yml
- `app_services` : Liste des services à vérifier

## Fichiers requis
- `{{ app_directory }}/compose-swarm.yml` : Fichier Docker Compose pour le déploiement Swarm

## Gestion d'erreurs
- Ignore les erreurs lors de la suppression de stack (si elle n'existe pas)
- Vérifie la présence de tous les services attendus
- Fait échouer le playbook si des services sont manquants

## Prérequis
- Cluster Docker Swarm initialisé
- Fichier compose-swarm.yml configuré
- Variables `project_name` et `app_services` définies
- Python3 et pip3 installés sur les nœuds
