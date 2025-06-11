# Application full-stack 'Sneakerportfolio' abec monitoring

Cette application est composée d'une architecture complète incluant:

> [!NOTE]
> - **Frontend** : Application React.js
> - **Backend** : Express.js (Node.js)
> - **Base de données** : MySQL 8.0
> - **Monitoring** : Prometheus + Grafana

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │────│   Backend   │────│  Database   │
│   (React)   │    │  (Node.js)  │    │   (MySQL)   │
│   Port 3000 │    │  Port 5000  │    │  Port 3307  │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                           │
                   ┌─────────────┐    ┌─────────────┐
                   │ Prometheus  │────│   Grafana   │
                   │  Port 9090  │    │  Port 3001  │
                   └─────────────┘    └─────────────┘
```

## Configuration

### Variables d'environnement requises

Créer un fichier .env à la racine:

```
ENVIRONMENT=production

DIR_FRONTEND="./frontend"
DIR_BACKEND="./backend"

DB_HOST=host
DB_PORT=port
DB_USER=user
DB_PASSWORD=password
DB_NAME=name
PORT=port

GRAFANA_PASSWORD=password
```

### Configuration par environnement

Le Docker Compose utilise des builds multi-stage :

> [!NOTE]
> - **Development** : Hot-reload activé, outils de debug
> - **Production** : Build optimisé, serveur nginx

## Démarrage rapide

### Prérequis

> [!NOTE]
> - Docker & Docker Compose
> - **Ports libres** : 3000, 3001, 3307, 5000, 9090

### Lancement complet

```
# Cloner le projet
git clone <repo-url>
cd <project-name>

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos valeurs

# Lancer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f
```

## Accès aux services

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Interface utilisateur |
| **Backend API** | http://localhost:5000 | API REST |
| **Base de données** | localhost:3307 | MySQL (externe) |
| **Prometheus** | http://localhost:9090 | Métriques système |
| **Grafana** | http://localhost:3001 | Dashboards (admin/admin123) |

## Commandes utiles

```
# Construire sans cache
docker-compose build --no-cache

# Redémarrer un service spécifique  
docker-compose restart backend

# Voir les logs d'un service
docker-compose logs -f frontend

# Accéder au shell d'un container
docker-compose exec backend /bin/bash

# Arrêter et supprimer tout
docker-compose down -v
```

## Monitoring

### Prometheus

> [!NOTE]
> - **Endpoint** : http://localhost:9090
> - **Configuration** : monitoring/prometheus.yml
> - **Métriques** : Collecte automatique depuis l'API backend

### Grafana

> [!NOTE]
> - **Endpoint** : http://localhost:3001
> - **Credentials** : admin / [GRAFANA_PASSWORD]
> - **Dashboards** : Pré-configurés dans monitoring/grafana/provisioning/

## Développement

### Hot-reload frontend

Les modifications dans frontend/src/ sont automatiquement synchronisées.

### Modification du backend

Redémarrage automatique sur changement de fichiers.

### Base de données

> [!NOTE]
> - **Host interne** : database:3306 (entre containers)
> - **Host externe** : localhost:3307 (depuis l'hôte)
> - **Initialisation** : Scripts SQL dans mysql/init/

## Health Checks

> [!NOTE]
> - **Backend** : GET /health (vérifié toutes les 30s)
> - **MySQL **: mysqladmin ping (vérifié toutes les 30s)
> - **Dépendances** : Le backend attend que MySQL soit healthy

## Notes importantes

> [!NOTE]
> - Les volumes mysql_data, prometheus_data et grafana_data persistent les données
> - Le réseau app_network isole l'application du monitoring
> - En production, modifier REACT_APP_API_URL pour pointer vers le vrai backend
> - Les healthchecks garantissent un démarrage ordonné des services
