# Générateur d'Inventaire Ansible pour Swarm (Terraform/GCP)

Ce script Bash automatise la création d’un inventaire Ansible au format INI, à partir des outputs Terraform d’un cluster Docker Swarm Google Cloud Platform.

## Fonctionnalités

> - Récupère dynamiquement :
>    - IPs privées des managers et workers Swarm
>    - IP publique et privée du manager leader (bastion/SSH proxy)
>    - IP du load balancer (entrée cluster)
> - Génère un fichier INI structuré compatible Ansible, avec gestion automatique du bastion.
> - Ajoute les variables SSH et groupes nécessaires pour vos playbooks.

## Prérequis

> - Terraform (infrastructure prète à être déployée)
> - Ansible.tf configuré pour lancer le script lors du `terraform apply`
> - jq (pour parser le JSON)

## Contenu généré

> - Fichier d’inventaire INI : ../ansible/inventories/swarm-hosts.ini

> - Groupes créés :
>   - [swarm_managers] – tous les managers Swarm (le 1er est leader et bastion)
>   - [swarm_workers] – tous les workers, accès SSH par bastion
>   - [swarm_cluster:children] – managers + workers
>   - [bastion] – le manager leader, utilisé comme jump host
>   - [swarm_deploy] – manager leader

> - Variables SSH :
>    - ansible_user=deploy
>    - ansible_ssh_private_key_file=~/.ssh/gcp-ssh-key
>    - ansible_ssh_common_args pour désactiver la vérif des clés et configurer le ProxyJump SSH
