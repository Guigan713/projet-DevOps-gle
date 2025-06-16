# Module Terraform - Google Cloud Firewall Rules

Ce module Terraform configure un ensemble complet de règles de pare-feu pour une architecture multi-tiers sécurisée avec bastion host et monitoring.
Description

## Le module configure automatiquement :

> - **Accès SSH sécurisé** : Via reverse proxy comme bastion host
> - **Règles applicatives** : Communication entre services
> - **Monitoring** : Accès aux métriques et dashboards
> - **Sécurité par défaut **: Principe du moindre privilège

## Architecture de sécurité

```
Internet
    ↓ SSH (22), HTTP (80), HTTPS (443)
[Reverse Proxy] (Bastion Host)
    ↓ SSH (22) vers instances internes
    ↓ HTTP (3000) vers Frontend
    ↓ HTTP (3000, 9090) vers Monitoring
[Frontend] ←→ [Backend] ←→ [Database]
    ↑             ↑          ↑
[Monitoring] ←←←←←←←←←←←←←←←←←←←
```

## Resources créées

| Resource | Nom | Direction | Protocol/Ports | Source → Target | Description |
|----------|-----|-----------|----------------|-----------------|-------------|
| `google_compute_firewall` | reverse-proxy-ssh | INGRESS | TCP/22 | Internet → reverse-proxy | SSH public |
| `google_compute_firewall` | reverse-proxy-to-internal-ssh | INGRESS | TCP/22 | reverse-proxy → services | Bastion SSH |
| `google_compute_firewall` | reverse-proxy-ingress | INGRESS | TCP/80,443 | Internet → reverse-proxy | Web traffic |
| `google_compute_firewall` | monitoring-services | INGRESS | TCP/3000,9090,9000 | Admin IP → monitoring | Admin access |
| `google_compute_firewall` | reverse-proxy-to-frontend | INGRESS | TCP/3000 | reverse-proxy → frontend | App access |
| `google_compute_firewall` | frontend-to-backend | INGRESS | TCP/5000 | frontend → backend | API calls |
| `google_compute_firewall` | backend-to-database | INGRESS | TCP/3306 | backend → database | DB access |
| `google_compute_firewall` | admin-to-database | INGRESS | TCP/3306 | Admin IP → database | DB admin |
| `google_compute_firewall` | monitoring-to-services-node-exporter | INGRESS | TCP/9100 | monitoring → services | Metrics |
| `google_compute_firewall` | monitoring-to-database-mysql-exporter | INGRESS | TCP/9104 | monitoring → database | DB metrics |
| `google_compute_firewall` | reverse-proxy-to-grafana | INGRESS | TCP/3000 | reverse-proxy → monitoring | Grafana |
| `google_compute_firewall` | reverse-proxy-to-prometheus | INGRESS | TCP/9090 | reverse-proxy → monitoring | Prometheus |
| `google_compute_firewall` | allow-outbound | EGRESS | ALL | services → Internet | Internet access |

## Variables requises

| Variable | Type | Description | Exemple |
|----------|------|-------------|---------|
| `vpc_name` | string | Nom du réseau VPC | `"main-vpc"` |
| `mon_ip` | string | Adresse IP administrateur | `"203.0.113.1"` |
| `vpc_id` | string | ID du réseau VPC | `""` |

## Tags utilisés

| Tag | Services | Usage |
|-----|----------|-------|
| `reverse-proxy` | Reverse proxy | Point d'entrée, bastion |
| `frontend` | Frontend | Interface utilisateur |
| `backend` | Backend | API/logique métier |
| `database` | Base de données | Stockage |
| `monitoring` | Monitoring | Prometheus, Grafana |

## Sécurité implémentée

### Principe du moindre privilège
- Chaque service n'a accès qu'aux ports nécessaires
- Sources définies par tags ou IP spécifiques
- Pas d'accès SSH direct aux services internes

### Bastion Host (Reverse Proxy)
- Seul point d'entrée SSH depuis Internet
- Accès SSH vers toutes les instances internes
- Simplifie la gestion des accès

### Isolation réseau
- Services internes non accessibles depuis Internet
- Communication inter-services contrôlée
- Monitoring centralisé mais sécurisé

## Ports et services

| Port | Service | Usage |
|------|---------|-------|
| 22 | SSH | Administration |
| 80/443 | HTTP/HTTPS | Trafic web |
| 3000 | Grafana/Frontend | Dashboard/App |
| 5000 | Backend API | API REST |
| 3306 | MySQL | Base de données |
| 9090 | Prometheus | Métriques |
| 9100 | Node Exporter | Métriques système |
| 9104 | MySQL Exporter | Métriques DB |

