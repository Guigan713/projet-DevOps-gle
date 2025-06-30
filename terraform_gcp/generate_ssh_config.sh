#!/bin/bash

set -e

# Variables
SSH_CONFIG_FILE="../ansible/ssh-config"
SSH_KEY="~/.ssh/gcp-ssh-key"

echo " Génération de la configuration SSH pour Docker Swarm..."

# Fonctions
error_exit() { echo " $1" >&2; exit 1; }

# Vérifications
[ ! -f "main.tf" ] && error_exit "Pas de Terraform"
[ ! -d ".terraform" ] && error_exit "Terraform non initialisé"

# Récupérer les IPs
MANAGER_IPS=$(terraform output -json swarm_manager_ips | jq -r '.[]') || error_exit "Pas d'output managers"
WORKER_IPS=$(terraform output -json swarm_worker_ips | jq -r '.[]') || error_exit "Pas d'output workers"
BASTION_IP=$(terraform output -json swarm_manager_public_ips | jq -r '.[0]') || error_exit "Pas d'IP bastion"
LB_IP=$(terraform output -raw swarm_load_balancer_ip 2>/dev/null) || LB_IP="$BASTION_IP"

# Compter
MANAGER_COUNT=$(terraform output -json swarm_manager_ips | jq '. | length')
WORKER_COUNT=$(terraform output -json swarm_worker_ips | jq '. | length')

echo " Configuration pour: $MANAGER_COUNT managers, $WORKER_COUNT workers"
echo " Bastion: $BASTION_IP"

# Créer le dossier
mkdir -p ../ansible

# Génération du fichier SSH (format simple)
cat > "$SSH_CONFIG_FILE" << SSH_START
# Configuration globale
Host *
    User deploy
    IdentityFile $SSH_KEY
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
    ServerAliveInterval 60

# BASTION / LEADER
Host swarm-bastion swarm-leader manager-1
    HostName $BASTION_IP
    Port 22
    LocalForward 8080 $LB_IP:80
    LocalForward 8443 $LB_IP:443
    LocalForward 9090 $LB_IP:9090
    LocalForward 3000 localhost:3000
    LocalForward 9000 localhost:9000

# MANAGERS
SSH_START

# Ajouter managers
MANAGER_COUNT=1
for ip in $MANAGER_IPS; do
    cat >> "$SSH_CONFIG_FILE" << SSH_MANAGER
Host manager-${MANAGER_COUNT} swarm-manager-${MANAGER_COUNT}
    HostName $ip
    Port 22

SSH_MANAGER
    ((MANAGER_COUNT++))
done

# Section workers
cat >> "$SSH_CONFIG_FILE" << SSH_WORKERS_SECTION

# WORKERS (via bastion)
SSH_WORKERS_SECTION

# Ajouter workers
WORKER_COUNT=1
for ip in $WORKER_IPS; do
    cat >> "$SSH_CONFIG_FILE" << SSH_WORKER
Host worker-${WORKER_COUNT} swarm-worker-${WORKER_COUNT}
    HostName $ip
    Port 22
    ProxyJump swarm-bastion

SSH_WORKER
    ((WORKER_COUNT++))
done

# Aliases finaux
cat >> "$SSH_CONFIG_FILE" << SSH_ALIASES

# ALIASES UTILES
Host swarm-deploy
    HostName $BASTION_IP
    Port 22
    LocalForward 3000 localhost:3000
    LocalForward 9090 localhost:9090
    LocalForward 8080 localhost:8080
    LocalForward 9000 localhost:9000

Host swarm-lb load-balancer
    HostName $LB_IP
    Port 22
    ProxyJump swarm-bastion
SSH_ALIASES

echo " Configuration SSH générée: $SSH_CONFIG_FILE"
echo ""
echo " Commandes utiles:"
echo "   ssh swarm-leader     # Manager principal"
echo "   ssh worker-1         # Premier worker"
echo "   ssh swarm-deploy     # Avec tunnels"
echo ""
echo "Tunnels disponibles (ssh swarm-deploy):"
echo "   http://localhost:8080  # Applications"
echo "   http://localhost:3000  # Grafana"
echo "   http://localhost:9090  # Prometheus"
echo "   http://localhost:9000  # Portainer"
