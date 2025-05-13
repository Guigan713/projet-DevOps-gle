#!/bin/bash

# Vérifie que Terraform est bien initialisé
if ! terraform output > /dev/null 2>&1; then
  echo "Erreur : les outputs Terraform ne sont pas disponibles. As-tu bien exécuté 'terraform apply' ?"
  exit 1
fi

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

echo "✅ Fichier hosts.ini généré avec succès !"
