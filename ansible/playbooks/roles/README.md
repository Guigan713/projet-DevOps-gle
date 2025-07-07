# Rôles Ansible - Projet DevOps

Ce répertoire contient l'ensemble des rôles Ansible utilisés pour le déploiement et la gestion de l'infrastructure du projet DevOps complet.

## Vue d'ensemble de l'architecture

Le projet déploie une application full-stack (React/Express/MySQL) sur Google Cloud Platform avec une architecture haute disponibilité basée sur Docker Swarm, Traefik comme reverse proxy, et un stack de monitoring Prometheus/Grafana.

## Rôles disponibles

### 🐳 [docker_swarm](./docker_swarm/README.md)
**Initialisation et configuration du cluster Docker Swarm**
- Configuration du manager et des workers
- Mise en place des réseaux overlay
- Gestion des tokens de sécurité

### 🏗️ [app_build](./app_build/README.md)
**Construction des images Docker**
- Build des images frontend (React) et backend (Express)
- Optimisation multi-stage des Dockerfiles
- Gestion des dépendances et artefacts

### 🚀 [app_deploy](./app_deploy/README.md)
**Déploiement de l'application sur Docker Swarm**
- Déploiement du stack complet (app + infrastructure)
- Configuration Traefik (reverse proxy + SSL)
- Services : frontend, backend, base de données, monitoring

### 🌐 [dns_management](./dns_management/README.md)
**Gestion automatisée du DNS et certificats SSL**
- Configuration des enregistrements DNS sur Google Cloud DNS
- Génération automatique de certificats SSL via Let's Encrypt
- Gestion des domaines et sous-domaines

### 📊 [monitoring](./monitoring/README.md)
**Déploiement du stack de monitoring**
- Configuration Prometheus (collecte de métriques)
- Mise en place Grafana (visualisation)
- Alerting et dashboards prédéfinis

### 💾 [mysql_backup](./mysql_backup/README.md)
**Stratégie de sauvegarde automatisée**
- Sauvegardes MySQL automatiques et planifiées
- Upload vers Google Cloud Storage
- Rétention et rotation des sauvegardes

### 📈 [node_exporter](./node_exporter/README.md)
**Collecte de métriques système**
- Configuration Node Exporter pour Prometheus
- Déployé via Docker Swarm (approche moderne)
- Métriques CPU, mémoire, disque, réseau

## Ordre d'exécution recommandé

Les rôles sont conçus pour être exécutés dans l'ordre suivant :

1. **docker_swarm** - Initialisation du cluster
2. **app_build** - Construction des images
3. **dns_management** - Configuration DNS/SSL
4. **app_deploy** - Déploiement de l'application
5. **monitoring** - Stack de monitoring
6. **mysql_backup** - Configuration des sauvegardes
7. **node_exporter** - (Inclus automatiquement dans app_deploy)

## Variables globales

Les variables communes sont définies dans `group_vars/all/` et incluent :
- Configuration GCP (projet, région, zones)
- Paramètres de domaine et SSL
- Configuration Docker Swarm
- Paramètres de monitoring et backup

## Prérequis techniques

- **Terraform** : Infrastructure GCP provisionnée
- **Docker** : Installé sur toutes les instances
- **Python** : Pour l'exécution des modules Ansible
- **Accès GCP** : Service account avec permissions appropriées

## Architecture réseau

```
Internet → Load Balancer → Traefik (443/80) → Services Docker Swarm
                                           ├── Frontend (React)
                                           ├── Backend (Express)
                                           ├── Database (MySQL)
                                           ├── Monitoring (Prometheus/Grafana)
                                           └── Node Exporter
```

## Sécurité

- **SSL/TLS** : Certificats Let's Encrypt automatiques
- **Firewall** : Règles restrictives (seuls ports 80/443/22 ouverts)
- **Secrets** : Gestion via Docker Swarm secrets
- **Réseau** : Isolation via réseaux overlay dédiés

## Monitoring et observabilité

- **Métriques** : Prometheus + Node Exporter
- **Visualisation** : Grafana avec dashboards pré-configurés
- **Logs** : Centralisés via Docker Swarm
- **Alerting** : Notifications automatiques

## Support et maintenance

Chaque rôle contient sa propre documentation détaillée avec :
- Description des tâches exécutées
- Variables configurables
- Prérequis et dépendances
- Exemples d'utilisation
- Troubleshooting

## Liens utiles

- **[Architecture complète](../../../ARCHITECTURE_SCHEMA.md)** - Schéma détaillé de l'infrastructure
- **[Présentation projet](../../../PRESENTATION_SLIDE.md)** - Support de présentation
- **[Workflow CI/CD](../../../.github/workflows/)** - Pipeline d'intégration continue
