# Security groups & Security rules

Ce module nous permet de gérer les security groups et les règles de sécurité facilitant la connection aux instances de l'infrastructure

## main.tf

### Security groups

> [!NOTE]
> - **reverse-proxy** : sur le sous réseau public, accessible par les ports 22 (SSH), 80 (HTTP), 443 (HTTPS)
> - **frontend** : sur le sous-réseau privé, accessible seulement via le port 22 par une seule adresse IP
> - **backend** : sur le sous-réseau privé, accessible seulement via le port 22 par une seule adresse IP
> - **database** : sur le sous-réseau privé, accessible seulement via le port 22 par une seule adresse IP, et seulement via le vpc
> - **monitoring** : sur le sous réseau-privé, accessible par les ports 22, 3000 (grafana), 9090 (prometheus) par une seule adresse IP

### Règles de communication entre les services

> [!NOTE]
> - du **reverse-proxy** au **frontend** via le port 3000
> - du **reverse-proxy** a **grafana** via le port 3000
> - du **reverse-proxy** a **prometheus** via le port 9090
> - du **frontend** au **backend** via le port 5000
> - du **backend** a la **database** via le port 3306
> - de **l'admin** a la **database** via le port 3306 et seulement via une seule adresse IP

### Règles liées au monitoring

> [!NOTE]
> - du **monitoring** au **reverse-proxy** via le port 9100
> - du **monitoring** au **frontend** via le port 9100
> - du **monitoring** au **backend** via le port 9100
> - du **monitoring** au **backend** via le port 9102 pour les métriques API
> - du **monitoring** a la **database** via le port 9100

## variables.tf

> [!NOTE]
> - **vpc_id** : ID du VPC auquel les security groups sont rattachés
> - **mon_ip** : IP publique autorisée a accéder à SSH et aux outils de monitoring

## outputs.tf

> [!NOTE]
> - **frontend_sg_id** : Identifiant du security group frontend
> - **backend_sg_id** : Identifiant du security group backend
> - **reverse_proxy_sg_id** : Identifiant du security group reverse-proxy
> - **database_sg_id** : Identifiant du security group database
> - **monitoring_sg_id** : Identifiant du security group monitoring