# Module Terraform - Google Cloud VPC Network

Ce module Terraform permet de créer une infrastructure réseau complète sur Google Cloud Platform avec VPC, sous-réseaux public/privé, routeur et NAT Gateway.
Description

## Le module configure automatiquement :

> - **VPC Network** : Réseau virtuel principal sans sous-réseaux automatiques
> - **Sous-réseau public** : Pour les ressources accessibles depuis Internet
> - **Sous-réseau privé** : Pour les ressources internes avec accès Google APIs
> - **Cloud Router** : Routage dynamique pour le réseau
> - **Cloud NAT** : Accès Internet sortant pour les ressources privées

## Architecture

```
Internet
    ↕
[Sous-réseau Public] ← → [Cloud Router + NAT] ← → [Sous-réseau Privé]
    ↕                                                     ↕
Resources publiques                               Resources privées
                                                 (accès sortant uniquement)
```

## Resources créées

| Resource | Nom | Description |
|----------|-----|-------------|
| `google_compute_network` | main-vpc | VPC principal |
| `google_compute_subnetwork` | public-subnet | Sous-réseau public |
| `google_compute_subnetwork` | private-subnet | Sous-réseau privé |
| `google_compute_router` | main-router | Routeur Cloud |
| `google_compute_router_nat` | main-nat | Passerelle NAT |

## Variables requises

| Variable | Type | Description | Exemple | Défaut |
|----------|------|-------------|---------|---------|
| `project` | string | ID du projet Google Cloud | `"my-gcp-project"` | - |
| `region` | string | Région Google Cloud | `"europe-west1"` | - |
| `public_subnet_cidr` | string | Plage CIDR du sous-réseau public | `"10.0.1.0/24"` | - |
| `private_subnet_cidr` | string | Plage CIDR du sous-réseau privé | `"10.0.2.0/24"` | - |

## Outputs

> - output "vpc_id" {}
> - output "public_subnet_id" {}
> - output "private_subnet_id" {}
> - output "vpc_name" {}