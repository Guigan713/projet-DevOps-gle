# Stack Docker Swarm – Projet DevOps GLE

Ce fichier docker-compose.yml définit une stack d’infrastructure orientée microservices, optimisée pour un environnement de production, incluant :
reverse proxy sécurisé (Traefik), frontend-backend, MySQL, monitoring Prometheus+Grafana, et Node Exporter.

## Architecture

> [!NOTE]
> - **Traefik v3** : reverse proxy, HTTPS auto, dashboard sécure, multi-service, Let’s Encrypt, intégration Swarm/Docker
> - **Base de données MySQL 8**
> - **Backend Express.js** (Node.js)
> - **Frontend React.js**
> - **Prometheus** : collecte & scrap de métriques
> - **Grafana** : visualisation monitoring
> - **Node Exporter** : monitoring système natif pour chaque nœud

## Fonctionnalités principales

> [!NOTE]
> - Reverse Proxy, SSL auto via ACME/Let's Encrypt pour tous les services exposés
> - Gestion fine du routage (host/path rules) grâce à Traefik labels
> - Réseaux sur mesure (public, app, monitoring)
> - Secrets, volumes de données persistantes
> - Ressources et santé pilotées en Swarm (replicas, healthchecks, constraints)
> - Déploiement Docker Swarm (production-ready)

## Déploiement

La stack est déployée de plusieurs façons:

> - manuellement: `docker stack deploy -c docker-compose.yml projectname` (pas utilisé dans notre cas)
> - au déclenchement du playbook manuellement: `ansible-playbook -i inventories/swarm-hosts.ini playbooks/playbook.yml -v`
> - Au déclenchement du workflow GitHub Actions lors d'un push git

## Services principaux

### Traefik (reverse proxy)

> - Certificats SSL auto
> - Dashboard admin (https://traefik.<domaine>)
> - Monitoring Prometheus exposé
> - Routage frontend/backend/personnalisé

### Database (MySQL)

> - stockage sur volume externe
> - Ressources limitées
> - Healthcheck natif

### Backend

> - Connecté à la DB (avec credentials sécurisés)
> - Exposé via /api et routé par Traefik (scalable)

### Frontend

> - Routé sur domain/app
> - Redirection HTTP→HTTPS automatique

### Prometheus

> - Monitoring de stack (incl. scrape Docker, exporters)
> - Rétention et config customisables via volume

### Grafana

> - Dashboards personnalisés (auto-provision)
> - Accès sécurisé
> - Dépendance Prometheus

### Node Exporter

> - Monitoring de chaque nœud (mode global)
> - Pour l’analyse fine des ressources systèmes

## Volumes & réseaux

```yml
networks:
  traefik-public:
    external: true
  app_network:
    driver: overlay
    attachable: true
  monitoring_network:
    external: true

volumes:
  mysql_data:
    external: true
  prometheus_data:
    external: true
  grafana_data:
    external: true
```
