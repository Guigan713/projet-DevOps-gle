# Module DNS

Ce module permet de créer automatiquement une zone DNS et les enregistrements DNS associés (A records) sur Google Cloud DNS pour un cluster Docker Swarm. Il gère également l’option d’un sous-domaine admin.

## Création de la zone DNS

```hcl
resource "google_dns_managed_zone" "swarm_zone" {
  name        = "${replace(var.domain_name, ".", "-")}-zone"
  dns_name    = "${var.domain_name}."
  description = "Zone DNS pour Docker Swarm - ${var.domain_name}"
  project     = var.project
}
```

> [!NOTE]
> - **resource "google_dns_managed_zone"** : Type de ressource Terraform pour créer une zone DNS managée dans Google Cloud
> - **"swarm_zone"** : Nom local de la ressource dans Terraform (utilisé pour les références)
> - **name** : Nom de la zone dans Google Cloud (doit être unique dans le projet)
> - **dns_name** : Le domaine exact (avec le point final obligatoire selon les standards DNS)
> - **description** : Description lisible pour identifier la zone
> - **project** : ID du projet GCP où créer la ressource

## Enregistrement DNS

Chaque enregistrement pointe vers l’adresse IP publique du Load Balancer Swarm (var.swarm_lb_ip) :

```hcl
resource "google_dns_record_set" "swarm_a_record" {
  name         = "${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}
```
> [!NOTE]
> - **google_dns_record_set** : Ressource pour créer un enregistrement DNS
> - **name** : Le nom complet du domaine (FQDN - Fully Qualified Domain Name)
> - **managed_zone** : Référence à la zone créée précédemment (google_dns_managed_zone.my_zone.name)
> - **type = "A"** : Type d'enregistrement qui pointe vers une adresse IPv4
> - **ttl = 300** : Time To Live en secondes (durée de cache)
> - **rrdatas** : Liste des valeurs (ici l'adresse IP)

## Enregistrement www_record

```hcl
resource "google_dns_record_set" "swarm_www_record" {
  name         = "www.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}
```

> [!NOTE]
> - **name: www.${var.domain_name}.** : rajoute Le sous-domaine www 
> - **managed_zone** : Référence à la zone créée précédemment (google_dns_managed_zone.my_zone.name)
> - **type = "A"** : Type d'enregistrement qui pointe vers une adresse IPv4
> - **ttl = 300** : Time To Live en secondes (durée de cache)
> - **rrdatas** : Liste des valeurs (ici l'adresse IP)

###  Différences clés

| Aspect | Enregistrement A | Enregistrement WWW |
|--------|------------------|-------------------|
| **Nom** | `mondomaine.com` | `www.mondomaine.com` |
| **Type** | Domaine racine (apex) | Sous-domaine |
| **Usage** | Accès direct | Accès traditionnel web |
| **IP** | ✅ Même IP | ✅ Même IP |

###  Pourquoi avoir les deux ?

```bash
# Les URLs fonctionnent et pointent vers le même serveur :
curl http://mondomaine.com
curl http://www.mondomaine.com  
curl http://api.mondomaine.com
curl http://grafana.mondomaine.com
curl http://prometheus.mondomaine.com
curl http://traefik.mondomaine.com
```

## Sous domaine api

```hcl
resource "google_dns_record_set" "api_record" {
  count        = var.create_api_subdomain ? 1 : 0
  name         = "api.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}
```

## Sous domaines grafana, prometheus, traefik

```hcl
variable "subdomains" {
  default = ["grafana", "prometheus", "traefik"]
}

resource "google_dns_record_set" "service_records" {
  count        = length(var.subdomains)
  name         = "${var.subdomains[count.index]}.${var.domain_name}."
  managed_zone = google_dns_managed_zone.swarm_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.swarm_lb_ip]
}
```