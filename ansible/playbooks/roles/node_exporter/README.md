# Rôle Ansible : node_exporter

## Description

Ce rôle Ansible était initialement conçu pour l'installation et la configuration de Node Exporter en tant que service systemd. Cependant, pour éviter les conflits de ports et maintenir une configuration centralisée, **Node Exporter est maintenant déployé exclusivement via Docker Swarm** dans le stack de monitoring.

## Architecture actuelle

- **Méthode de déploiement** : Docker Swarm (service global)
- **Configuration** : Via `compose-swarm.yml.j2` dans le rôle `app_deploy`
- **Port** : 9100 (exposé uniquement au niveau du réseau Docker)
- **Collecte** : Métriques système collectées par Prometheus

## Variables par défaut

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `node_exporter_version` | `1.7.0` | Version de Node Exporter (référence pour documentation) |

## Tâches exécutées

### 1. Information de déploiement
- **Tâche** : `Node Exporter info`
- **Action** : Affiche un message informatif
- **Objectif** : Informer que Node Exporter sera déployé via Docker Swarm
- **Message** : "Node Exporter will be deployed via Docker Swarm stack - see compose-swarm.yml.j2"

## Historique et évolution

### Ancienne approche (commentée)
Le rôle contenait initialement les tâches suivantes (maintenant désactivées) :
1. **Téléchargement** : Récupération du binaire depuis GitHub Releases
2. **Extraction** : Décompression de l'archive
3. **Installation** : Copie du binaire vers `/usr/local/bin/`
4. **Service systemd** : Création et activation du service
5. **Démarrage** : Lancement automatique du service

### Nouvelle approche (actuelle)
- **Déploiement Docker** : Service global dans le stack Swarm
- **Configuration centralisée** : Via compose file
- **Évitement des conflits** : Pas de services systemd concurrents
- **Scalabilité** : Déploiement automatique sur tous les nœuds du cluster

## Avantages de l'approche Docker Swarm

1. **Gestion centralisée** : Configuration unique pour tout le cluster
2. **Résilience** : Redémarrage automatique des conteneurs
3. **Cohérence** : Même version sur tous les nœuds
4. **Simplicité** : Pas de gestion manuelle des binaires
5. **Monitoring intégré** : Logs centralisés avec Docker

## Prérequis

- Docker Swarm initialisé et configuré
- Rôle `app_deploy` exécuté pour déployer le stack complet
- Réseau overlay `monitoring-network` créé

## Utilisation

Ce rôle est automatiquement inclus dans le playbook principal mais n'effectue aucune installation directe. La configuration effective de Node Exporter se fait via :

1. **Rôle `app_deploy`** : Déploiement du stack Docker Swarm
2. **Template `compose-swarm.yml.j2`** : Configuration du service Node Exporter
3. **Prometheus** : Configuration de la collecte des métriques

## Métriques collectées

Node Exporter collecte automatiquement :
- **CPU** : Utilisation, charge, temps d'exécution
- **Mémoire** : RAM, swap, buffers
- **Disque** : Espace, I/O, système de fichiers
- **Réseau** : Interfaces, paquets, erreurs
- **Processus** : Nombre, états, ressources

## Dépendances

- Rôle `docker_swarm` (pour l'initialisation du cluster)
- Rôle `app_deploy` (pour le déploiement du stack)
- Rôle `monitoring` (pour la configuration Prometheus)

## Notes importantes

⚠️ **Ce rôle ne déploie plus Node Exporter directement**. Il sert uniquement à documenter la transition vers l'approche Docker Swarm et à éviter toute confusion sur la méthode de déploiement actuelle.

La configuration effective de Node Exporter se trouve dans le template `compose-swarm.yml.j2` du rôle `app_deploy`.
