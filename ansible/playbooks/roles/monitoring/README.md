# Monitoring Role

## Description
Ce rôle configure la stack de monitoring avec Prometheus et Grafana, incluant les configurations, dashboards et la synchronisation entre les managers du swarm.

## Tâches principales

### 1. Création de l'arborescence de monitoring
- **Create monitoring configuration directories** : Crée tous les répertoires nécessaires
  - `/opt/monitoring/prometheus` et ses sous-répertoires (console_libraries, consoles)
  - `/opt/monitoring/grafana/provisioning` (datasources, dashboards)
  - `/opt/monitoring/grafana/dashboards` (app, swarm)

### 2. Configuration de Prometheus
- **Generate Prometheus configuration** : Génère le fichier `prometheus.yml` depuis le template
  - Définit les targets de scraping
  - Configure les règles d'alerte
  - Paramètre la retention des données
  - Exécuté uniquement sur le premier manager

### 3. Configuration de Grafana

#### Sources de données
- **Generate Grafana datasource configuration** : Crée la configuration des datasources
  - Connexion automatique à Prometheus
  - Fichier : `grafana/provisioning/datasources/prometheus.yml`

#### Dashboards
- **Generate Grafana dashboard configuration** : Configure le provider de dashboards
  - Fichier : `grafana/provisioning/dashboards/default.yml`
  - Scan automatique des dashboards JSON

- **Copy Docker Swarm dashboard** : Déploie le dashboard Docker Swarm
  - Métriques du cluster (nœuds, services, conteneurs)
  - Fichier : `grafana/dashboards/docker-swarm.json`

- **Copy Node Exporter dashboard** : Déploie le dashboard Node Exporter
  - Métriques système (CPU, RAM, disque, réseau)
  - Fichier : `grafana/dashboards/node-exporter.json`

### 4. Synchronisation entre managers
- **Fetch files from manager_1** : Récupère les fichiers de configuration depuis le premier manager
  - Stockage temporaire dans `/tmp/monitoring-sync/`
  - Synchronise tous les fichiers de configuration

- **Copy files to other managers** : Distribue les configurations aux autres managers
  - Assure la cohérence entre tous les managers
  - Copie : configurations Prometheus, datasources et dashboards Grafana

## Structure des répertoires créés

```
/opt/monitoring/
├── prometheus/
│   ├── prometheus.yml
│   ├── console_libraries/
│   └── consoles/
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   │   └── prometheus.yml
    │   └── dashboards/
    │       └── default.yml
    └── dashboards/
        ├── docker-swarm.json
        ├── node-exporter.json
        ├── app/
        └── swarm/
```

## Templates utilisés
- `prometheus.yml.j2` : Configuration principale Prometheus
- `grafana_datasource.yml.j2` : Configuration datasource Grafana
- `grafana-dashboard-provider.yml.j2` : Configuration provider dashboards
- `docker-swarm-dashboard.json.j2` : Dashboard Docker Swarm
- `node-exporter-dashboard.json.j2` : Dashboard Node Exporter

## Dashboards inclus

### Docker Swarm Dashboard
- État des nœuds du cluster
- Nombre de services et tâches
- Utilisation des ressources du cluster
- Répartition des conteneurs

### Node Exporter Dashboard
- Métriques CPU par nœud
- Utilisation mémoire et swap
- I/O disque et espace disponible
- Trafic réseau

## Variables utilisées
- `ssh_user` : Propriétaire des fichiers de configuration
- `groups['swarm_managers']` : Liste des managers pour la synchronisation

## Permissions
- **Répertoires** : 755
- **Fichiers** : 644
- **Propriétaire** : `{{ ssh_user }}`

## Prérequis
- Cluster Docker Swarm initialisé
- Node Exporter déployé sur tous les nœuds
- Variables de groupe `swarm_managers` définies
