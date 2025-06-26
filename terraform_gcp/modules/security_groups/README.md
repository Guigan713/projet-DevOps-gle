# Module Terraform - Google Cloud Firewall Rules

Ce module Terraform configure un ensemble complet de règles de pare-feu pour une architecture multi-tiers sécurisée avec bastion host et monitoring.
Description

## Le module configure automatiquement :

> - **Accès SSH sécurisé** : Sur managers, via IP ou bastion
> - **Règles applicatives** : Communication entre services (Swarm, overlay, etc.)
> - **Monitoring** : Accès aux métriques et dashboards sécurisés par IP
> - **Sécurité par défaut** : Principe du moindre privilège


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

| Resource                     | Nom                       | Direction | Protocol/Ports            | Source → Target             | Description      |
|------------------------------|---------------------------|-----------|---------------------------|-----------------------------|------------------|
| `google_compute_firewall`    | swarm-manager-ssh         | INGRESS   | TCP/22                    | admin IP → managers         | SSH sécurisé     |
| `google_compute_firewall`    | swarm-internal-ssh        | INGRESS   | TCP/22                    | managers → nodes            | Bastion SSH      |
| `google_compute_firewall`    | swarm-internal-communication | INGRESS   | TCP,UDP,ICMP              | subnets → nodes             | Swarm overlay    |
| `google_compute_firewall`    | swarm-cluster-ports       | INGRESS   | TCP/2377,7946; UDP/4789,7946 | subnets → nodes          | Docker Cluster   |
| `google_compute_firewall`    | swarm-web-ingress         | INGRESS   | TCP/80,443                | Internet → managers         | Web traffic      |
| `google_compute_firewall`    | swarm-monitoring          | INGRESS   | TCP/3000,9090,9093        | admin IP → managers         | Monitoring       |
| `google_compute_firewall`    | swarm-outbound            | EGRESS    | ALL                       | nodes → Internet            | Internet access  |


## Variables requises

| Variable             | Type    | Description                                         | Exemple              |
|----------------------|---------|-----------------------------------------------------|----------------------|
| `vpc_name`           | string  | Nom du réseau VPC                                   | `"main-vpc"`         |
| `vpc_id`             | string  | ID du réseau VPC                                    | `"..."`              |
| `mon_ip`             | string  | Adresse IP administrateur (ssh/monitoring)          | `"203.0.113.1"`      |
| `public_subnet_cidr` | string  | CIDR du sous-réseau public                          | `"10.0.1.0/24"`      |
| `private_subnet_cidr`| string  | CIDR du sous-réseau privé                           | `"10.0.2.0/24"`      |


## Tags utilisés

| Tag             | Services         | Usage                                 |
|-----------------|------------------|---------------------------------------|
| `swarm-manager` | Managers         | Cluster managers, exposés (web/ssh)   |
| `swarm-worker`  | Workers          | Workers Swarm                         |
| `swarm-node`    | Tous (label)     | Scopes inter-Swarm & overlay network  |

## Outputs

| Output                | Description                                              |
|-----------------------|----------------------------------------------------------|
| `swarm_firewall_rules`| Liste des règles firewall créées par le module           |
| `swarm_network_tags`  | Tags réseau managers / workers Swarm à propager sur VMs  |


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

| Port  | Service              | Usage                                         |
|-------|----------------------|-----------------------------------------------|
| 22    | SSH                  | Administration/admin nodes                    |
| 80/443| HTTP/HTTPS           | Trafic web public                             |
| 2377  | Swarm Manager        | Cluster management (only TCP)                 |
| 4789  | Swarm Overlay        | Overlay network (only UDP)                    |
| 7946  | Node Communication   | Node comm. overlay (TCP/UDP)                  |
| 3000  | Grafana/Frontend     | Monitoring/Dashboards                         |
| 9090  | Prometheus           | Metrics server                                |
| 9093  | Alertmanager         | Alerts (optionnel)                            |


