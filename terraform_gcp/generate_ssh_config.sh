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
LEADER_IP=$(terraform output -raw swarm_leader_ip) || error_exit "Pas d'IP leader"
BASTION_IP=$(terraform output -raw bastion_public_ip) || error_exit "Pas d'IP bastion"
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

# BASTION
Host swarm-bastion
    HostName $BASTION_IP
    Port 22

SSH_START

MANAGER_IDX=1
for ip in $MANAGER_IPS; do
    # Bloc leader, sinon manager simple
    if [[ "$ip" == "$LEADER_IP" ]]; then
        cat >> "$SSH_CONFIG_FILE" << EOF
# LEADER SWARM (manager-$MANAGER_IDX)
Host swarm-leader manager-$MANAGER_IDX swarm-manager-$MANAGER_IDX
    HostName $ip
    Port 22
    ProxyJump swarm-bastion
    LocalForward 8080 $LB_IP:80
    LocalForward 8443 $LB_IP:443
    LocalForward 9090 $LB_IP:9090
    LocalForward 3000 127.0.0.1:3000
    LocalForward 9000 127.0.0.1:9000

EOF
    else
        cat >> "$SSH_CONFIG_FILE" << EOF
# AUTRE MANAGER (manager-$MANAGER_IDX)
Host manager-$MANAGER_IDX swarm-manager-$MANAGER_IDX
    HostName $ip
    Port 22
    ProxyJump swarm-bastion

EOF
    fi
    ((MANAGER_IDX++))
done

# WORKERS (tous proxyjump via bastion)
cat >> "$SSH_CONFIG_FILE" << SSH_WORKERS_HEADER
# WORKERS
SSH_WORKERS_HEADER

WORKER_IDX=1
for ip in $WORKER_IPS; do
    cat >> "$SSH_CONFIG_FILE" << SSH_WORKER
Host worker-${WORKER_IDX} swarm-worker-${WORKER_IDX}
    HostName $ip
    Port 22
    ProxyJump swarm-bastion

SSH_WORKER
    ((WORKER_IDX++))
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
echo "  ssh swarm-leader         # Vers le leader (via bastion)"
echo "  ssh manager-2            # Vers un autre manager"
echo "  ssh worker-1             # Premier worker"
echo "  ssh swarm-bastion        # Accès direct sur le bastion"
echo "  ssh swarm-deploy         # Avec tunnels pour applicatifs"
echo ""
echo "Tunnels disponibles (ssh swarm-deploy):"
echo "   http://localhost:8080  # Applications"
echo "   http://localhost:3000  # Grafana"
echo "   http://localhost:9090  # Prometheus"
echo "   http://localhost:9000  # Portainer"
