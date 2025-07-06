# Module Terraform : Load Balancer GCP

Ce module Terraform configure un load balancer global Google Cloud Platform pour un cluster Docker Swarm, incluant la gestion des certificats SSL, health checks, et la répartition de charge entre tous les nœuds du cluster.

## Architecture déployée

```
Internet (Global)
       │
       ▼ IP Statique (34.8.188.63)
┌─────────────────────────────────┐
│    Global Load Balancer GCP    │
│  ┌─────────────┬─────────────┐  │
│  │    HTTP     │    HTTPS    │  │
│  │   (Port 80) │  (Port 443) │  │
│  └─────────────┴─────────────┘  │
└─────────────────┬───────────────┘
                  │
            ┌─────▼─────┐
            │ URL Map   │ (Routing)
            └─────┬─────┘
                  │
        ┌─────────▼─────────┐
        │  Backend Service  │
        │   (Health Check)  │
        └─────────┬─────────┘
                  │
    ┌─────────────▼─────────────┐
    │     Instance Group        │
    │  ┌─────┬─────┬─────────┐  │
    │  │ M1  │ M2  │ M3      │  │ (Managers)
    │  └─────┴─────┴─────────┘  │
    │  ┌─────┬─────┐           │
    │  │ W1  │ W2  │           │  │ (Workers)
    │  └─────┴─────┘           │
    └───────────────────────────┘
```

## Fonctionnalités principales

> [!NOTE]
> - **Load Balancer Global** : Distribution du trafic mondial avec IP statique
> - **Health Check automatique** : Surveillance de santé via endpoint `/ping` de Traefik
> - **Certificats SSL managés** : Génération et renouvellement automatique par Google
> - **Support multi-domaines** : 5 domaines configurés (principal + API + monitoring)
> - **Répartition équilibrée** : Inclut managers et workers dans le backend
> - **Headers personnalisés** : Transmission des informations client originales

## Ressources créées

### 1. Health Check

**Description :** Mécanisme de surveillance automatique qui vérifie périodiquement la santé des instances backend via l'endpoint `/ping` de Traefik pour détecter et exclure automatiquement les nœuds défaillants du pool de distribution.

```tf
google_compute_health_check.swarm_health_check
```

> [!NOTE]
> - **Endpoint** : `/ping` sur port 80 (endpoint Traefik)
> - **Fréquence** : Vérification toutes les 10 secondes
> - **Seuils** : 2 succès = healthy, 3 échecs = unhealthy
> - **Timeout** : 10 secondes par vérification
> - **Logs** : Activés pour monitoring et debugging

### 2. Instance Group

**Description :** Groupe logique qui rassemble toutes les instances du cluster Docker Swarm (managers et workers) dans une entité unique, permettant au load balancer de distribuer le trafic vers l'ensemble des nœuds disponibles.

```tf
google_compute_instance_group.swarm_nodes
```

> [!NOTE]
> - **Membres** : Tous les managers et workers du cluster (5 instances)
> - **Named Ports** :
>   - `http` : 80 (trafic HTTP principal)
>   - `https` : 443 (trafic HTTPS)
>   - `traefik-api` : 8080 (dashboard Traefik)
> - **Zone** : europe-west1-b

### 3. Backend Service

**Description :** Service principal qui définit comment le trafic est distribué vers les instances du groupe, incluant les algorithmes de load balancing, les health checks, et la configuration des headers pour préserver les informations client originales.

```tf
google_compute_backend_service.swarm_backend
```

> [!NOTE]
> - **Protocole** : HTTP (terminaison SSL au niveau du LB)
> - **Balancement** : Mode UTILIZATION avec capacity_scaler 1.0
> - **Health Check** : Intégré pour détection automatique des nœuds défaillants
> - **Headers personnalisés** :
>   - `X-Forwarded-Proto: $scheme` : Protocole original (HTTP/HTTPS)
>   - `X-Real-IP: $remote_addr` : IP client réelle
> - **Timeout** : 30 secondes par requête

### 4. URL Map

**Description :** Table de routage qui détermine vers quel backend service diriger les requêtes en fonction de l'URL demandée. Actuellement configurée pour router tout le trafic vers le backend Swarm par défaut.

```tf
google_compute_url_map.swarm_url_map
```

> [!NOTE]
> - **Routing par défaut** : Toutes les requêtes vers le backend Swarm
> - **Service par défaut** : `swarm_backend`
> - **Extensible** : Peut être complété avec des règles de routage spécifiques

### 5. Certificats SSL Managés

**Description :** Certificats SSL/TLS automatiquement provisionnés et gérés par Google Cloud pour sécuriser les communications HTTPS. Génère, valide et renouvelle automatiquement les certificats pour tous les domaines configurés sans intervention manuelle.

```tf
google_compute_managed_ssl_certificate.swarm_ssl_cert_new
```

**Domaines couverts :**
- `sneakerportfolio.eu` : Application principale
- `api.sneakerportfolio.eu` : API backend  
- `grafana.sneakerportfolio.eu` : Interface Grafana
- `prometheus.sneakerportfolio.eu` : Interface Prometheus
- `traefik.sneakerportfolio.eu` : Dashboard Traefik

> [!NOTE]
> - **Gestion automatique** : Génération, validation et renouvellement par Google
> - **Provisioning DNS** : Requiert que les domaines pointent vers l'IP du LB
> - **Certificat unifié** : Un seul certificat couvrant tous les domaines de l'application

### 6. Proxies HTTP/HTTPS

**Description :** Proxies de terminaison qui interceptent le trafic entrant, gèrent les protocoles HTTP/HTTPS et redirigent les requêtes vers les services backend appropriés via l'URL map configurée.

```tf
google_compute_target_http_proxy.swarm_http_proxy
google_compute_target_https_proxy.swarm_https_proxy
```

> [!NOTE]
> - **HTTP Proxy** : Redirige le trafic HTTP vers le backend
> - **HTTPS Proxy** : Terminaison SSL avec certificat managé, puis HTTP vers backend
> - **URL Map** : Utilise la même URL map pour cohérence du routage

### 7. Forwarding Rules

**Description :** Règles de redirection globales qui associent l'IP statique du load balancer aux proxies HTTP/HTTPS, définissant les ports d'écoute et permettant l'accès mondial au cluster via une adresse IP unique.

```tf
google_compute_global_forwarding_rule.swarm_http (port 80)
google_compute_global_forwarding_rule.swarm_https (port 443)
```

> [!NOTE]
> - **IP statique** : 34.8.188.63 (fournie via variable)
> - **Portée globale** : Accessible depuis n'importe où dans le monde
> - **Port 80** : HTTP → Proxy HTTP → Backend
> - **Port 443** : HTTPS → Proxy HTTPS (SSL termination) → Backend HTTP

## Variables d'entrée

| Variable | Type | Description | Défaut |
|----------|------|-------------|---------|
| `project_id` | string | ID du projet GCP | - |
| `project_name` | string | Nom du projet pour nommage des ressources | - |
| `zone` | string | Zone GCP pour l'instance group | `europe-west1-b` |
| `region` | string | Région GCP | `europe-west1` |
| `manager_instances` | list(string) | Self-links des instances managers | - |
| `worker_instances` | list(string) | Self-links des instances workers | - |
| `swarm_lb_ip` | string | IP statique du load balancer | - |

## Outputs générés

| Output | Description |
|--------|-------------|
| `swarm_lb_ip` | IP du load balancer (34.8.188.63) |
| `backend_service_id` | ID du service backend |
| `health_check_id` | ID du health check |
| `instance_group_id` | ID du groupe d'instances |
| `forwarding_rules` | Informations des règles HTTP/HTTPS |
| `url_map_id` | ID de la URL map |
| `proxies` | Informations des proxies HTTP/HTTPS |
| `ssl_certificate` | Informations du certificat SSL |

## Exemple d'utilisation

```hcl
module "load_balancer" {
  source = "./modules/load-balancer"

  project_id   = "geometric-watch-455507-m6"
  project_name = "projet-devops-gle"
  zone         = "europe-west1-b"
  region       = "europe-west1"
  
  manager_instances = module.instances.manager_self_links
  worker_instances  = module.instances.worker_self_links
  swarm_lb_ip      = google_compute_global_address.swarm_lb.address
}
```

## Flux de trafic

### Requête HTTP (port 80)
```
Client → LB IP:80 → HTTP Proxy → URL Map → Backend Service → Instance Group → Node Swarm
```

### Requête HTTPS (port 443)
```
Client → LB IP:443 → HTTPS Proxy (SSL termination) → URL Map → Backend Service → Instance Group → Node Swarm
```

## Intégration avec Traefik

Le load balancer fonctionne en parfaite synergie avec Traefik :

> [!NOTE]
> - **Health Check** : Utilise l'endpoint `/ping` exposé par Traefik
> - **Headers préservés** : `X-Real-IP` et `X-Forwarded-Proto` transmis à Traefik
> - **SSL Offloading** : Terminaison SSL au niveau GCP, HTTP en interne
> - **Service Discovery** : Traefik route vers les services internes du cluster

## Avantages de cette architecture

> [!NOTE]
> - **Performance globale** : CDN et points de présence Google mondiaux
> - **Haute disponibilité** : Health checks automatiques et basculement
> - **Scalabilité** : Support de montée en charge automatique
> - **Sécurité** : Certificats SSL managés et protection DDoS intégrée
> - **Monitoring** : Logs et métriques intégrés Google Cloud
> - **Coût optimisé** : Pas de redondance inutile, SSL managé gratuit

## Prérequis

> [!NOTE]
> - **Instances Swarm** : Managers et workers déployés et fonctionnels
> - **IP statique** : Réservée via `google_compute_global_address`
> - **DNS configuré** : Tous les domaines pointent vers l'IP du LB
> - **Traefik déployé** : Endpoint `/ping` disponible sur port 80
> - **Permissions GCP** : Compute Admin, DNS Admin pour certificats

## Monitoring et troubleshooting

### Vérifications de santé

```bash
# Test health check direct
curl -f http://34.8.188.63/ping

# Vérification certificats SSL
openssl s_client -connect sneakerportfolio.eu:443 -servername sneakerportfolio.eu

# Test des domaines
for domain in sneakerportfolio.eu api.sneakerportfolio.eu grafana.sneakerportfolio.eu; do
  curl -I https://$domain
done
```

### Logs et métriques

- **Health Check Logs** : Cloud Console → Load Balancing → Backend services
- **Métriques LB** : Cloud Monitoring → Load Balancer metrics
- **Certificats SSL** : Cloud Console → Network Security → SSL certificates
