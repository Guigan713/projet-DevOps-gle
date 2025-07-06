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
                          +---------------------+
                          |      Internet       |
                          +---------------------+
                                   |
                                   v
                   +----------------------------------+
                   |   Load Balancer (Public IP)      |
                   +----------------------------------+
                       /        |         \
                      /         |          \
                     v          v           v
             +---------+   +---------+   +---------+
             |Manager1 |   |Manager2 |   |Manager3 |
             |10.0.1.4 |   |10.0.1.3 |   |10.0.1.2 |
             +---------+   +---------+   +---------+
                \    | \    /  |    /  |   /
                 \   |  \  /   |   /   |  /
                  \  |   \/    |  /    | /
                   Full-mesh entre Managers
                     (ports Swarm, overlay)
                      /    |        \
                     /     |         \
           +--------v-------+     +--------v--------+
           |   Worker1      |     |    Worker2      |
           |   10.0.2.2     |     |   10.0.2.3      |
           +----------------+     +-----------------+
                  |                     |
                  |                     |
         +-------------------+       +---------------------------+
         |     Bastion SSH   |<------|  Admin (ssh/monitoring)   |
         |     (10.0.1.10)   |       +---------------------------+
         +-------------------+
                  |
           +---------------+
           |   Backup GCS  |
           +---------------+
```


- **LB HTTP/HTTPS → Managers**
- **Managers** : full-mesh entre eux, accès aux Workers  
- **Workers** : aucun accès direct depuis Internet  
- **SSH** : seulement via Bastion  
- **Monitoring** : via manager, restreint à IP admin

---

## Règles Firewall créées

| Resource                     | Nom                       | Direction | Protocol/Ports                  | Source → Target                 | Description      |
|------------------------------|---------------------------|-----------|------------------------------|-------------------------------|------------------|
| `google_compute_firewall`    | swarm-lb-to-nodes         | INGRESS   | TCP/80,443                      | LB / subnet → managers         | HTTP/HTTPS via LB|
| `google_compute_firewall`    | lb-health-check           | INGRESS   | TCP/80,443                      | IPs GCP → managers             | Health check LB  |
| `google_compute_firewall`    | ssh-bastion-admin         | INGRESS   | TCP/22                           | IP admin → bastion             | SSH sécurisé     |
| `google_compute_firewall`    | bastion-ssh-to-nodes      | INGRESS   | TCP/22                           | bastion → managers/workers     | SSH proxy interne|
| `google_compute_firewall`    | swarm-internal-ssh        | INGRESS   | TCP/22                           | manager → all nodes            | SSH interne      |
| `google_compute_firewall`    | swarm-internal-communication | INGRESS | TCP/2377,7946; UDP/4789,7946     | subnets → swarm nodes          | Swarm/overlay    |
| `google_compute_firewall`    | swarm-monitoring          | INGRESS   | TCP/3000,9090,9093               | IP admin → managers            | Monitoring       |
| `google_compute_firewall`    | swarm-node-exporter       | INGRESS   | TCP/9100                         | subnets → swarm nodes          | Node exporter    |
| `google_compute_firewall`    | swarm-outbound            | EGRESS    | ALL                              | swarm nodes → Internet         | Internet access  |

---

## Variables requises

| Variable             | Type    | Description                                         | Exemple              |
|----------------------|---------|-----------------------------------------------------|----------------------|
| `vpc_name`           | string  | Nom du réseau VPC                                   | `"main-vpc"`         |
| `vpc_id`             | string  | ID du réseau VPC                                    | `"..."`              |
| `mon_ip`             | string  | Adresse IP administrateur (SSH/monitoring)          | `"203.0.113.1"`      |
| `public_subnet_cidr` | string  | CIDR du sous-réseau public                          | `"10.0.1.0/24"`      |
| `private_subnet_cidr`| string  | CIDR du sous-réseau privé                           | `"10.0.2.0/24"`      |
| `project`            | string  | ID du projet GCP                                    | `"my-gcp-project"`   |
| `project_name`       | string  | Nom du projet                                      | `"swarm-prod"`       |

---

## Tags utilisés

| Tag             | Services         | Usage                                 |
|-----------------|------------------|---------------------------------------|
| `swarm-manager` | Managers         | Cluster managers, ports web/moni/ssh  |
| `swarm-worker`  | Workers          | Workers Swarm                         |
| `swarm-node`    | Tous (label)     | Swarm/Overlay, cluster interne        |
| `bastion`       | Bastion          | Permet SSH via IP admin               |

---

## Outputs

| Output                | Description                                              |
|-----------------------|----------------------------------------------------------|
| `swarm_firewall_rules`| Liste des règles firewall créées                        |
| `swarm_network_tags`  | Tags réseau managers / workers / bastion à appliquer    |

---

## Sécurité implémentée

- Accès SSH seulement via Bastion ou IP admin déclarée
- LB GCP en frontal et règles Health Check GCP obligatoires
- Managers & workers séparés, aucun accès direct public  
- Tous les ports restreints : moindre privilège absolu
- Monitoring restreint à l’IP de l’admin


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


