# Module DNS

## Resource pour la zone DNS

```hcl
resource "google_dns_managed_zone" "my_zone" {
    # replace(var.domain_name, ".", "-") : Remplace les points par des tirets
    name = "${replace(var.domain_name, ".", "-")}-zone"
    dns_name = "${var.domain_name}."
    description = "Zone DNS pour ${var.domain_name}"

    project = var.project
}
```

> [!NOTE]
> - **resource "google_dns_managed_zone"** : Type de ressource Terraform pour créer une zone DNS managée dans Google Cloud
> - **"my_zone"** : Nom local de la ressource dans Terraform (utilisé pour les références)
> - **name** : Nom de la zone dans Google Cloud (doit être unique dans le projet)
> - **dns_name** : Le domaine exact (avec le point final obligatoire selon les standards DNS)
> - **description** : Description lisible pour identifier la zone
> - **project** : ID du projet GCP où créer la ressource

## Enregistrement DNS

```hcl
resource "google_dns_record_set" "a_record" {
    name = "${var.domain_name}."
    managed_zone = google_dns_managed_zone.my_zone.name
    type = "A"
    ttl = 300
    rrdatas = ["1.2.3.4"]
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
resource "google_dns_record_set" "www_cname" {
  name         = "www.${var.domain_name}."
  managed_zone = google_dns_managed_zone.my_zone.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [module.instance.reverse_proxy_public_ip]
}
```

> [!NOTE]
> - **type = "CNAME"** : Canonical Name, alias qui pointe vers un autre nom de domaine
> - **www.${var.domain_name}.** : rajoute Le sous-domaine www 
> - **managed_zone** : Référence à la zone créée précédemment (google_dns_managed_zone.my_zone.name)
> - **type = "A"** : Type d'enregistrement qui pointe vers une adresse IPv4
> - **ttl = 300** : Time To Live en secondes (durée de cache)
> - **rrdatas** : Liste des valeurs (ici l'adresse IP)

##  Différences clés

| Aspect | Enregistrement A | Enregistrement WWW |
|--------|------------------|-------------------|
| **Nom** | `mondomaine.com` | `www.mondomaine.com` |
| **Type** | Domaine racine (apex) | Sous-domaine |
| **Usage** | Accès direct | Accès traditionnel web |
| **IP** | ✅ Même IP | ✅ Même IP |

##  Pourquoi avoir les deux ?

```bash
# Les deux URLs fonctionnent et pointent vers le même serveur :
curl http://mondomaine.com      # ✅ Fonctionne
curl http://www.mondomaine.com  # ✅ Fonctionne aussi
```