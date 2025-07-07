# DNS Management Role

## Description
Ce rôle gère la configuration DNS pour tous les services de l'application, incluant la vérification de la propagation DNS et la configuration des certificats SSL via Google Cloud DNS.

## Tâches principales

### 1. Récupération de l'IP du Load Balancer
- **Récupérer l'IP du Load Balancer** : Récupère l'IP publique du Load Balancer
  - Essaie plusieurs sources : `dns_setup`, premier manager, variable d'environnement
  - Stocke dans la variable `lb_ip`

### 2. Vérification de la propagation DNS
- **Vérifier la propagation DNS des sous-domaines** : Vérifie via Google DNS (8.8.8.8)
  - Teste chaque service dans `dns_services`
  - Utilise la commande `dig` pour vérifier les enregistrements A
  - Exécuté uniquement sur le premier manager

- **Attendre la propagation DNS si nécessaire** : Pause conditionnelle
  - Attend 30 secondes si l'IP ne correspond pas encore
  - Ne s'exécute que si la propagation n'est pas complète

### 3. Configuration des certificats SSL
- **Copier la clé GCP DNS Challenge** : Copie le fichier de credentials GCP
  - Source : `{{ gcp_credentials_file }}`
  - Destination : `{{ app_directory }}/gcp-service-account.json`
  - Permissions sécurisées (600)
  - Nécessaire pour la validation DNS ACME

## Configuration par défaut

### Credentials GCP
- `gcp_credentials_file` : Chemin vers le fichier JSON des credentials
- `gcp_project` : ID du projet GCP
- `gcp_auth_kind` : "serviceaccount"
- `gcp_service_account_file` : Alias du fichier de credentials

### Configuration DNS
- `domain_name` : Domaine principal (ex: sneakerportfolio.eu)
- `dns_ttl` : 300 secondes
- Sous-domaines automatiques :
  - `api.{{ domain_name }}`
  - `grafana.{{ domain_name }}`
  - `prometheus.{{ domain_name }}`
  - `traefik.{{ domain_name }}`

### Services DNS exposés
Structure de `dns_services` :
```yaml
dns_services:
  - name: "traefik"
    subdomain: "traefik"
    port: 8080
    enabled: true
  - name: "frontend"
    subdomain: "app"
    port: 80
    enabled: true
  # ... autres services
```

## Logique de vérification DNS

### Conditions de vérification
- Exécuté sur le premier manager uniquement
- Vérifie seulement les services avec `enabled: true`
- Utilise Google DNS (8.8.8.8) pour la résolution

### Conditions d'attente
- Attente seulement si :
  - La tâche n'a pas été sautée
  - Le service est activé
  - L'IP résolue ne correspond pas à `lb_ip`
  - Une IP a été résolue (pas vide)

## Sécurité

### Fichier de credentials
- **Permissions** : 600 (lecture/écriture propriétaire uniquement)
- **Propriétaire** : `{{ ssh_user }}`
- **Emplacement sécurisé** : Dans le répertoire de l'application

### Validation DNS
- Utilise le service DNS public Google (8.8.8.8)
- Vérification avant déploiement des certificats
- Évite les échecs de validation ACME

## Variables requises
- `domain_name` : Domaine principal
- `lb_ip` : IP publique du Load Balancer
- `gcp_credentials_file` : Chemin vers les credentials GCP
- `app_directory` : Répertoire de destination
- `ssh_user` : Propriétaire des fichiers

## Prérequis
- Enregistrements DNS configurés dans Google Cloud DNS
- Load Balancer GCP déployé avec IP statique
- Credentials GCP avec permissions Cloud DNS
- Commande `dig` disponible sur le système local
