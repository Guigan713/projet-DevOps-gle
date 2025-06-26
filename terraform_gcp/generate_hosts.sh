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
LEADER_PUBLIC_IP=$(terraform output -json swarm_manager_public_ips | jq -r '.[0]') || error_exit "Pas d'IP publique"
LEADER_PRIVATE_IP=$(terraform output -raw swarm_leader_ip) || error_exit "Pas d'IP leader"
LB_IP=$(terraform output -raw swarm_load_balancer_ip) || error_exit "Pas d'IP LB"

# Créer dossier
mkdir -p ../ansible/inventories

# Génération du fichier INI (BEAUCOUP plus simple!)
cat > "$INVENTORY_FILE" << INI_END
# ===== INVENTAIRE DOCKER SWARM =====

# Variables globales
[all:vars]
ansible_user=deploy
ansible_ssh_private_key_file=${SSH_KEY}
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o ProxyJump=deploy@${LEADER_PUBLIC_IP}"

# ===== MANAGERS =====
[swarm_managers]
INI_END

# Ajouter les managers
MANAGER_COUNT=1
for ip in $MANAGER_IPS; do
    if [ $MANAGER_COUNT -eq 1 ]; then
        # Premier = Leader avec IP publique
        echo "manager_${MANAGER_COUNT} ansible_host=${ip} swarm_role=manager swarm_leader=true public_ip=${LEADER_PUBLIC_IP}" >> "$INVENTORY_FILE"
    else
        # Autres = Followers via bastion
        echo "manager_${MANAGER_COUNT} ansible_host=${ip} swarm_role=manager swarm_leader=false ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@${LEADER_PUBLIC_IP}'" >> "$INVENTORY_FILE"
    fi
    ((MANAGER_COUNT++))
done

# Ajouter section workers
cat >> "$INVENTORY_FILE" << INI_WORKERS

# ===== WORKERS =====
[swarm_workers]
INI_WORKERS

# Ajouter les workers
WORKER_COUNT=1
for ip in $WORKER_IPS; do
    echo "worker_${WORKER_COUNT} ansible_host=${ip} swarm_role=worker ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=deploy@${LEADER_PUBLIC_IP}'" >> "$INVENTORY_FILE"
    ((WORKER_COUNT++))
done

# Groupes finaux
cat >> "$INVENTORY_FILE" << INI_GROUPS

# ===== GROUPES =====
[swarm_cluster:children]
swarm_managers
swarm_workers

[swarm_nodes:children]
swarm_managers
swarm_workers

[swarm_deploy]
manager_1

[bastion]
swarm_bastion ansible_host=${LEADER_PUBLIC_IP} private_ip=${LEADER_PRIVATE_IP} lb_ip=${LB_IP} ansible_ssh_common_args='' swarm_role=bastion
INI_GROUPS

echo " Inventaire INI généré: $INVENTORY_FILE"
echo " $(($MANAGER_COUNT-1)) managers, $(($WORKER_COUNT-1)) workers"
echo " Commande test: ansible swarm_cluster -i $INVENTORY_FILE -m ping"
