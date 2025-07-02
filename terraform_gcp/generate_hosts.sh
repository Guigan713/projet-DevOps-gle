#!/bin/bash

set -e

# Variables
INVENTORY_FILE="../ansible/inventories/swarm-hosts.ini"
SSH_KEY="${HOME}/.ssh/gcp-ssh-key"
CACHE_FILE=".terraform/swarm-ips-cache"

echo " Génération inventaire Swarm (format INI)..."

# Fonctions
error_exit() { echo " $1" >&2; exit 1; }

# Vérifications
[ ! -f "main.tf" ] && error_exit "Pas de Terraform ici"
[ ! -d ".terraform" ] && error_exit "Terraform non initialisé"

# Récupération des IPs
MANAGER_IPS=$(terraform output -json swarm_manager_ips | jq -r '.[]') || error_exit "Pas d'output managers"
WORKER_IPS=$(terraform output -json swarm_worker_ips | jq -r '.[]') || error_exit "Pas d'output workers"
LEADER_PRIVATE_IP=$(terraform output -raw swarm_leader_ip) || error_exit "Pas d'IP leader"
BASTION_PUBLIC_IP=$(terraform output -raw bastion_public_ip) || error_exit "Pas d'IP publique de bastion"
LB_IP=$(terraform output -raw swarm_load_balancer_ip) || error_exit "Pas d'IP LB"

# Créer dossier
mkdir -p ../ansible/inventories

# Génération du fichier INI
cat > "$INVENTORY_FILE" << INI_END
# INVENTAIRE DOCKER SWARM

# Variables globales
[all:vars]
ansible_user=deploy
ansible_ssh_private_key_file=${SSH_KEY}
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o ProxyJump=deploy@${BASTION_PUBLIC_IP}"

# MANAGERS
[swarm_managers]
INI_END

# Ajouter les managers
MANAGER_COUNT=1
for ip in $MANAGER_IPS; do
    leader_option=""
    [ "$ip" == "$LEADER_PRIVATE_IP" ] && leader_option="swarm_leader=true" || leader_option="swarm_leader=false"
    echo "manager_${MANAGER_COUNT} ansible_host=${ip} swarm_role=manager ${leader_option}" >> "$INVENTORY_FILE"
    ((MANAGER_COUNT++))
done

# Ajouter section workers
cat >> "$INVENTORY_FILE" << INI_WORKERS

# WORKERS
[swarm_workers]
INI_WORKERS

# Ajouter les workers
WORKER_COUNT=1
for ip in $WORKER_IPS; do
    echo "worker_${WORKER_COUNT} ansible_host=${ip} swarm_role=worker" >> "$INVENTORY_FILE"
    ((WORKER_COUNT++))
done

# Groupes finaux
cat >> "$INVENTORY_FILE" << INI_GROUPS

[swarm_cluster:children]
swarm_managers
swarm_workers

[swarm_nodes:children]
swarm_managers
swarm_workers

[swarm_deploy]
manager_1

[bastion]
swarm_bastion ansible_host=${BASTION_PUBLIC_IP} private_ip=${LEADER_PRIVATE_IP} lb_ip=${LB_IP} swarm_role=bastion
INI_GROUPS

echo " Inventaire INI généré: $INVENTORY_FILE"
echo " $(($MANAGER_COUNT-1)) managers, $(($WORKER_COUNT-1)) workers"
echo " Commande test: ansible swarm_cluster -i $INVENTORY_FILE -m ping"
