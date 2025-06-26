# Générateur de SSH Config pour Cluster Swarm (Terraform/GCP)

Ce script Bash automatise la création d’une configuration SSH sur-mesure pour accéder facilement à tous les nœuds Docker Swarm provisionnés par Terraform sur Google Cloud.
Fonctionnalités principales

> - Génère le fichier ssh-config pour Ansible et CLI développements/devops.
> - Création de tunnels locaux pratiques : Grafana, Prometheus, Portainer, Frontend web…
> - Ajoute tous les nœuds (managers, workers), bastion/leader, et aliases intelligents.
> - Utilise les outputs Terraform pour rester toujours à jour !

## Prérequis

> - Terraform (infrastructure prète à être déployée)
> - Ansible.tf configuré pour lancer le script lors du `terraform apply`
> - jq (pour parser le JSON)
> - Clé SSH privée existante (~/.ssh/gcp-ssh-key)

## Contenu généré

### Fichier SSH

> - Chemin : ../ansible/ssh-config
> - Pour chaque manager et worker : accès en 1 ligne, avec ProxyJump si privé
> - Bastion/leader = jump host + tunnels (HTTP, monitoring)
> - Alias pratiques (swarm-deploy, swarm-leader, etc.)

### Exemple de tunnels accessibles

> - http://localhost:8080 → Frontend application
> - http://localhost:3000 → Grafana
> - http://localhost:9090 → Prometheus
> - http://localhost:9000 → Portainer

