# Module Terraform - Cluster Docker Swarm sur Google Compute Engine

Ce module Terraform permet d’automatiser le déploiement d’un cluster Docker Swarm sur Google Cloud Platform avec Gestion HA (High Availability) : managers + workers, réseau privé/public, et IP statique pour Load Balancer/Accès public/SSH sécurisé.

## Le module configure automatiquement :

> [!NOTE]
> - Provisionne une IP publique statique (Load Balancer/SSH)
> - Déploie automatiquement plusieurs managers Swarm (HA configurable)
> - Déploie automatiquement plusieurs workers Swarm
> - Les accès SSH sont configurés via clé publique fournie
> - Architecture réseau : public pour le leader, privé pour les autres nœuds/machines
> - Séparation claire des rôles avec tags réseau
> - Tous les outputs essentiels sont exposés (pour outputs DNS ou orchestration)


## Architecture

```
Internet
   │
[IP publique statique / Load Balancer]
   │
┌─────────────────────────┐
│  Swarm Manager Leader   │  <-- accès SSH (public)
└─────────┬───────────────┘
          │
   [Managers Swarm (privé)]
   [Workers Swarm (privé)]
```

> - 1 manager avec IP publique (pour accès initial/SSH/bootstrapping)
> - n managers + n workers sur sous-réseaux privés, suivant tes variables
> - IP statique séparée, idéale pour mise à jour DNS/future intégration LB


## Resources créées

| Resource                   | Rôle                        | Réseau      | Spécificité                         |
|----------------------------|-----------------------------|-------------|-------------------------------------|
| `google_compute_address`   | IP statique "swarm_lb_ip"   | Public      | Pour Load Balancer/leader SSH       |
| `google_compute_instance`  | Managers Swarm              | Public/Privé| 1 exposé, autres privés             |
| `google_compute_instance`  | Workers Swarm               | Privé       | Tous privés/not exposés             |


## Variables requises

| Variable              | Type    | Description                              | Exemple                                                                                 |
|-----------------------|---------|------------------------------------------|-----------------------------------------------------------------------------------------|
| `project`             | string  | ID du projet GCP                         | `"my-gcp-project"`                                                                      |
| `region`              | string  | Région Google Cloud                      | `"europe-west1"`                                                                        |
| `zone`                | string  | Zone spécifique                          | `"europe-west1-b"`                                                                      |
| `image`               | string  | Image système à utiliser                 | `"debian-cloud/debian-12"`                                                              |
| `vpc_id`              | string  | ID du réseau VPC                         | `"projects/my-project/global/networks/my-vpc"`                                           |
| `public_subnet_id`    | string  | ID du sous-réseau public                 | `"projects/my-project/regions/europe-west1/subnetworks/public-subnet"`                   |
| `private_subnet_id`   | string  | ID du sous-réseau privé                  | `"projects/my-project/regions/europe-west1/subnetworks/private-subnet"`                  |
| `ssh_public_key_path` | string  | Chemin de la clé SSH publique            | `"~/.ssh/gcp-ssh-key.pub"`                                                              |
| `swarm_manager_count` | number  | Nb de managers Swarm (≥3 pour HA)        | `3`                                                                                      |
| `swarm_worker_count`  | number  | Nb de workers Swarm                      | `2`                                                                                      |
| `manager_machine_type`| string  | Type de VM pour managers                 | `"e2-small"`                                                                            |
| `worker_machine_type` | string  | Type de VM pour workers                  | `"e2-micro"`                                                                            |


## Outputs

| Output                   | Description                                   |
|--------------------------|-----------------------------------------------|
| `swarm_manager_ips`      | IPs privées des managers Swarm                |
| `swarm_worker_ips`       | IPs privées des workers Swarm                 |
| `swarm_lb_ip`            | IP publique statique assignée au cluster/LB   |
| `swarm_leader_ip`        | IP privée du manager leader                   |
| `swarm_leader_public_ip` | IP publique (SSH) du leader                   |
| `swarm_cluster_info`     | Infos globales sur managers / workers / IP LB |


## Sécurité

> - Seul le leader manager dispose d’une IP publique pour SSH.
> - SSH configuré via la clé fournie par la variable ssh_public_key_path, injectée à l’utilisateur deploy par défaut.
> - Les tags réseau permettent une segmentation claire des flux pour firewall GCP.

