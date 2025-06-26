# Rôle Ansible : dns_management

Gestion automatisée DNS Google Cloud, création/renouvellement SSL avec Certbot, et configuration Traefik via Ansible

## Objectif

Centraliser toutes les opérations d’exposition DNS des services Swarm sur Google Cloud DNS,
générer automatiquement les certificats SSL Let’s Encrypt (support wildcard, principaux services),
et préparer la configuration dynamique de reverse proxy (Traefik) via templates Ansible.

## Fonctionnalités majeures

> - Gestion DNS (Google Cloud DNS) :
>    - Création/mise à jour des enregistrements A selon la topologie exposée (load balancer automatique)
>    - Vérification propagation et reporting intégré
>    - Prise en charge dynamique de la liste dns_services

> - Obtention automatique de certificats SSL/TLS :
>    - Multi-domaines (traefik, grafana, prometheus, portainer, api, admin…)
>    - Wildcard (*.domain.tld) & spécifiques
>    - Création des dossiers et automatisation renouvellement (cron)
>    - Déclencheur pour mise à jour du reverse proxy (Traefik) après renouvellement

> - Compatibilité GCP :
>    - Authentification avec Service Account Vaulté, gestion repo apt + gcloud SDK
>    - Validations automatiques (existence zone DNS, autorisations)

> - Configuration dynamique Traefik :
>    - Génération du fichier de configuration dynamique (traefik-dynamic.yml) par template
>    - Prêt à être notifié/redémarré après modif certificat

## Prérequis

> - Service Account GCP avec droits DNS Manager
> - Auth/Gcloud configuré sur localhost (ou VM cible)
> - Certbot et plugin DNS Google installés (automatisé)
> - Traefik déployé côté reverse proxy (pour notification/reload auto)

## Variables clefs & exemples

À définir (dans defaults/main.yml, group_vars, ou un autre inventaire) :

#### GCP
> - **gcp_credentials_file**: "/chemin/vers/credentials.json"
> - **gcp_project**: "<project-id>"
> - **gcp_service_account_file**: "{{ gcp_credentials_file }}"
> - **dns_zone_name**: "<ma-zone-dns>"

#### Domaine principal
> - **domain_name**: "exemple.com"
> - **api_domain**: "api.{{ domain_name }}"
> - **grafana_domain**: "grafana.{{ domain_name }}"
> - **prometheus_domain**: "prometheus.{{ domain_name }}"
> - **traefik_domain**: "traefik.{{ domain_name }}"
> - **dns_ttl**: 300

#### Services exposés

```yml
dns_services:
  - name: "traefik"
    subdomain: "traefik"
    port: 8080
    enabled: true
  - name: "grafana"
    subdomain: "grafana"
    port: 3000
    enabled: true
  - name: "api"
    subdomain: "api"
    port: 5000
    enabled: "{{ create_api_subdomain | default(false) }}"
```

#### SSL
> - **ssl_enabled**: true
> - **ssl_email**: "admin@{{ domain_name }}"

## Dans le playbook principal :

```yml
- hosts: localhost
  roles:
    - role: dns_management
```