#!/bin/bash

set -e

# Fonction pour afficher les erreurs
error_exit() {
    echo "Erreur: $1" >&2
    exit 1
}

# Variables
INVENTORY_FILE="../ansible/inventories/hosts.ini"
BACKUP_FILE="../ansible/inventories/hosts.ini.backup"
FORCE_UPDATE=false

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_UPDATE=true
            echo "Mode force activé - les IPs existantes seront remplacées"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-f|--force] [-h|--help]"
            echo "  -f, --force  Remplace les IPs existantes"
            echo "  -h, --help   Affiche cette aide"
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            echo "Utilisez -h pour voir l'aide"
            exit 1
            ;;
    esac
done

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "main.tf" ] && [ ! -f "*.tf" ]; then
    error_exit "Aucun fichier Terraform trouvé. Es-tu dans le bon répertoire ?"
fi

echo "Vérification de l'état Terraform..."

# Vérifier que Terraform est initialisé
if [ ! -d ".terraform" ]; then
    error_exit "Terraform n'est pas initialisé. Exécute 'terraform init' d'abord."
fi

# Vérifier qu'il y a un état Terraform
if ! terraform state list > /dev/null 2>&1; then
    error_exit "Aucun état Terraform trouvé. Exécute 'terraform apply' d'abord."
fi

# Vérifie que les outputs sont bien disponibles
if ! terraform output > /dev/null 2>&1; then
  echo "Erreur : les outputs Terraform ne sont pas disponibles. As-tu bien exécuté 'terraform apply' ?"
  exit 1
fi

echo "Vérification des outputs requis..."

# Vérifier que tous les outputs existent
declare -A outputs
required_outputs=("frontend_ip" "reverse_proxy_ip" "backend_ip" "database_ip" "monitoring_ip")
for output in "${required_outputs[@]}"; do
    if ! outputs["$output"]=$(terraform output -raw "$output" 2>/dev/null); then
        error_exit "Output '$output' non trouvé. Vérifie ton fichier outputs.tf"
    fi
done

echo "Tous les outputs sont disponibles !"

# Fonction pour extraire l'IP d'une ligne d'inventaire existante
extract_existing_ip() {
    local section=$1
    if [ -f "$INVENTORY_FILE" ]; then
        # Trouver la section et récupérer l'IP
        awk -v section="[$section]" '
            $0 == section { in_section=1; next }
            /^

$$
.*
$$

/ && in_section { exit }
            in_section && NF > 0 && !/^#/ { 
                match($0, /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
                if (RSTART > 0) {
                    print substr($0, RSTART, RLENGTH)
                    exit
                }
            }
        ' "$INVENTORY_FILE"
    fi
}

# Fonction pour vérifier si une IP a changé
check_ip_change() {
    local section=$1
    local new_ip=$2
    local existing_ip
    
    existing_ip=$(extract_existing_ip "$section")
    
    if [ -n "$existing_ip" ] && [ "$existing_ip" != "$new_ip" ]; then
        echo "⚠️  IP différente détectée pour [$section]:"
        echo "   Existante: $existing_ip"
        echo "   Nouvelle:  $new_ip"
        return 1
    fi
    return 0
}

# Créer une sauvegarde si le fichier existe
if [ -f "$INVENTORY_FILE" ]; then
    cp "$INVENTORY_FILE" "$BACKUP_FILE"
    echo "Sauvegarde créée: $BACKUP_FILE"
fi

# Vérifier les changements si le mode force n'est pas activé
if [ "$FORCE_UPDATE" = false ] && [ -f "$INVENTORY_FILE" ]; then
    echo "Vérification des IPs existantes..."
    
    conflicts=0
    declare -A sections=([frontend_ip]="frontend" [reverse_proxy_ip]="reverse_proxy" [backend_ip]="backend" [database_ip]="database" [monitoring_ip]="monitoring")
    
    for output in "${!sections[@]}"; do
        if ! check_ip_change "${sections[$output]}" "${outputs[$output]}"; then
            ((conflicts++))
        fi
    done
    
    if [ $conflicts -gt 0 ]; then
        echo ""
        echo "❌ $conflicts conflit(s) d'IP détecté(s)."
        echo "Options:"
        echo "  1. Réexécuter avec -f pour forcer la mise à jour"
        echo "  2. Vérifier manuellement les changements"
        echo "  3. Restaurer depuis: $BACKUP_FILE"
        exit 1
    fi
fi

echo "Génération du fichier hosts.ini..."

# Génération du fichier hosts.ini
cat > ../ansible/inventories/hosts.ini <<EOF
[frontend]
$(terraform output -raw frontend_ip) ansible_user=ubuntu

[reverse_proxy]
$(terraform output -raw reverse_proxy_ip) ansible_user=ubuntu

[backend]
$(terraform output -raw backend_ip) ansible_user=ubuntu

[database]
$(terraform output -raw database_ip) ansible_user=ubuntu

[monitoring]
$(terraform output -raw monitoring_ip) ansible_user=ubuntu
EOF

echo "Fichier hosts.ini généré avec succès !"
