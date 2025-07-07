# Docker Swarm Role

## Description
Ce rôle configure un cluster Docker Swarm avec des managers et des workers, initialise les réseaux et volumes nécessaires pour l'application.

## Tâches principales

### 1. Initialisation du Swarm
- **Check if swarm is initialised** : Vérifie si le swarm est déjà initialisé
- **Set swarm status fact** : Définit le statut du swarm comme variable
- **Leave existing swarm** : Force la sortie du swarm existant pour réinitialisation
- **Initialize Docker Swarm on manager-1** : Initialise le swarm sur le premier manager avec force-new-cluster

### 2. Gestion des tokens
- **Get manager join token** : Récupère le token pour joindre d'autres managers
- **Get worker join token** : Récupère le token pour joindre les workers
- **Check if node is already in the swarm** : Vérifie l'état actuel du nœud dans le swarm

### 3. Jointure des nœuds
- **Join managers** : Joint les managers supplémentaires au swarm avec le token manager
- **Join Workers** : Joint les workers au swarm avec le token worker
- Gestion des erreurs pour éviter les doublons

### 4. Configuration avancée (Leader uniquement)
- **Create application networks** : Crée les réseaux overlay (app_network, traefik-public, monitoring_network)
- **Create Docker volumes** : Crée les volumes persistants (mysql_data, prometheus_data, grafana_data)

### 5. Étiquetage des nœuds
- **Get current node hostname** : Récupère le nom d'hôte de chaque manager
- **Label manager node for services** : Applique les labels pour le placement des services
  - `traefik.enable=true`
  - `monitoring.enable=true`
  - `database.allowed=true`
- **Check applied labels** : Vérifie les labels appliqués
- **Print node labels** : Affiche les labels pour debug

### 6. Authentification Docker
- **Docker login** : Connecte tous les nœuds au Docker Hub avec les credentials

## Variables requises
- `docker_hub_username` : Nom d'utilisateur Docker Hub
- `docker_hub_password` : Mot de passe Docker Hub
- Groupes d'inventaire : `swarm_managers`, `swarm_workers`

## Réseaux créés
- `app_network` : Réseau pour l'application (frontend/backend)
- `traefik-public` : Réseau pour le reverse proxy Traefik
- `monitoring_network` : Réseau pour Prometheus/Grafana

## Volumes créés
- `mysql_data` : Données persistantes MySQL
- `prometheus_data` : Données Prometheus
- `grafana_data` : Configuration et dashboards Grafana
