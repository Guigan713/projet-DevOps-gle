# Module Terraform — Cluster Docker Swarm sur Google Compute Engine

Ce module Terraform automatise le déploiement d’un cluster **Docker Swarm** sur Google Cloud Platform, en mettant l’accent sur la haute disponibilité, la sécurité des accès SSH, et la clarté du découpage réseau (privé/public).  
Il inclut la gestion d’un hôte **bastion** dédié, des managers, des workers, ainsi qu’une sortie d’outputs complète pour vos besoins d'orchestration et d’administration.

---

## Fonctionnalités principales

- Création automatique d'un **bastion** (jump host SSH) public pour accéder au cluster en toute sécurité.
- Déploiement configurable de plusieurs **managers** Swarm (en réseau privé, pour la HA).
- Déploiement de plusieurs **workers** Swarm (en réseau privé).
- Différenciation claire des rôles (bastion, manager, worker) via les labels/tags réseau.
- Toutes les clés SSH sont injectées à l'utilisateur `deploy` (modifiable).
- Sorties d’outputs complètes : IPs, self-links, instances, etc.
- Architecture réseau optimale : seul le bastion est exposé en public.

---

## Architecture déployée


```
+-------------------------------------------------------------+
|                           VPC                               |
|                                                             |
|   +--------------------+      ┌──────────────────────┐      |
|   |    Internet        |      |  Load Balancer       |      |
|   |                    |----->|  IP Publique         |      |
|   +--------------------+      └----+---+---+---+-----┘      |
|                                |   |   |   |                |
|           ------------------------------------------------  |
|                |       |         |                          |
|   ┌────────────▼──┐ ┌──▼─────────▼──┐  ┌───────────────┐    |
|   | Manager1      | | Manager2      |  | Manager3      |    |
|   | 10.0.1.4      | | 10.0.1.3      |  | 10.0.1.2      |    |
|   └───────┬───────┘ └─────┬─────────┘  └───────┬──────┘    |
|           |    \           |    /             /            |
|         --+-----+----------+---+-------------+---          |
|        /   |     \      /       |           /    \         |
|   ┌───▼────┴─┐ ┌─▼──────┴─┐  ┌─▼─────────┐                |
|   | Worker1  | | Worker2   |  | Backup    |                |
|   | 10.0.2.2 | | 10.0.2.3  |  | Bucket    |                |
|   |          | |           |  | (GCS)     |                |
|   └──────────┘ └───────────┘  └───────────┘                |
|                  private subnet                            |
+------------------------------------------------------------+

```

> - Internet/Load Balancer : accès externe, distribue le trafic vers les managers (ports Swarm, API…)
> - Managers : 3 nœuds, tous connectés entre eux (communication full-mesh)
> - Workers : communications internes avec les managers
> - Backup Bucket : stockage GCS (interne, privé)
> - Tout est contenu dans le même VPC et un sous-réseau privé.


---

## Ressources créées

| Ressource                   | Rôle                      | Réseau      | Notes principales                    |
|-----------------------------|---------------------------|-------------|--------------------------------------|
| `google_compute_instance.bastion`      | Bastion SSH         | Public      | Machine d’accès unique (jump host)   |
| `google_compute_instance.swarm_manager`| Nodes managers      | Privé       | Aucun manager n’a d’IP publique      |
| `google_compute_instance.swarm_worker` | Nodes workers       | Privé       | Jamais exposé directement            |
| `google_compute_address`    | (Réservé, optionnel)      | Public      | Pour future gestion LB ou DNS        |

---

## Variables indispensables

| Variable                | Description                                  |
|-------------------------|----------------------------------------------|
| `project`               | ID du projet GCP                             |
| `region`                | Région GCP où déployer le cluster            |
| `zone`                  | Zone GCP principale du cluster               |
| `image`                 | Image VM de base pour tous les nœuds         |
| `vpc_id`                | ID du réseau VPC hébergeant le cluster       |
| `public_subnet_id`      | ID du sous-réseau public (pour le bastion)   |
| `private_subnet_id`     | ID du sous-réseau privé (managers/workers)   |
| `ssh_public_key_path`   | Chemin de la clé publique SSH à injecter     |
| `swarm_manager_count`   | Nombre total de managers Swarm               |
| `swarm_worker_count`    | Nombre total de workers Swarm                |
| `manager_machine_type`  | Type GCP de VM utilisées pour les managers   |
| `worker_machine_type`   | Type GCP de VM utilisées pour les workers    |

---

## Outputs exposés

| Output                         | Description                                          |
|---------------------------------|------------------------------------------------------|
| `swarm_manager_ips`             | IPs privées des managers Swarm                       |
| `swarm_worker_ips`              | IPs privées des workers Swarm                        |
| `bastion_public_ip`             | Adresse IP publique du bastion (accès/SSH)           |
| `swarm_leader_ip`               | IP privée du premier manager (pour bootstrap)        |
| `swarm_cluster_info`            | Détail du cluster (managers, workers, IPs, noms)     |
| `swarm_manager_self_links`      | Self-links GCP des managers (pour LB ou monitoring)  |
| `swarm_worker_self_links`       | Self-links GCP des workers                           |
| `all_swarm_nodes_self_links`    | Tous les self-links (managers + workers)             |
| `swarm_manager_instances`       | Objets détaillés des managers                        |
| `swarm_worker_instances`        | Objets détaillés des workers                         |
| `all_swarm_nodes_instances`     | Objets détaillés de l’ensemble du cluster            |
| `primary_zone`                  | Zone principale d’implantation du cluster            |

---

## Points de sécurité

- **Seul le bastion** dispose d’une IP publique (renforce la surface d’attaque réduite).
- **Tous les accès SSH** (y compris pour Ansible) passent par le bastion en ProxyJump.
- **Réseaux et tags** facilitent la gestion de firewall et la segmentation des flux.
- La clé SSH injectée peut être individuelle par utilisateur (recommandé).

---

## Exemple minimal d’utilisation

```hcl
module "swarm_cluster" {
  source              = "./modules/swarm"
  project             = "my-gcp-project"
  region              = "europe-west1"
  zone                = "europe-west1-b"
  vpc_id              = "projects/my-gcp-project/global/networks/vpc-main"
  public_subnet_id    = "projects/my-gcp-project/regions/europe-west1/subnetworks/public"
  private_subnet_id   = "projects/my-gcp-project/regions/europe-west1/subnetworks/private"
  ssh_public_key_path = "~/.ssh/gcp-ssh-key.pub"
  swarm_manager_count = 3
  swarm_worker_count  = 2
  manager_machine_type= "e2-small"
  worker_machine_type = "e2-micro"
}


