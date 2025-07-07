# App Build Role

## Description
Ce rôle prépare l'environnement de build pour l'application en créant les répertoires nécessaires et en configurant les fichiers d'environnement.

## Tâches principales

### 1. Configuration de debug
- **Afficher la variable source de clé GCP** : Debug des variables de credentials GCP et utilisateur SSH

### 2. Création de l'arborescence de répertoires
- **Create application directory** : Crée le répertoire principal de l'application (`/opt/{{ app_name }}`)
- **Create docker volumes directory** : Crée le répertoire pour les volumes Docker (`/opt/{{ app_name }}/volumes`)
- **Create build directory** : Crée le répertoire de build (`/opt/{{ app_name }}/build`)
- **Create frontend directory** : Crée le répertoire pour le frontend (`/opt/{{ app_name }}/build/frontend`)
- **Create backend directory** : Crée le répertoire pour le backend (`/opt/{{ app_name }}/build/backend`)

### 3. Configuration de l'environnement
- **Copy environment file** : Copie le fichier d'environnement depuis le template (`app.env.j2`)

## Variables par défaut

### Services de l'application
```yaml
app_services:
  - traefik
  - frontend
  - backend
  - database
  - prometheus
  - grafana
```

### Configuration des répertoires
- `project_name`: "projet-devops-gle"
- `app_directory`: "/opt/{{ app_name }}"
- `gcp_credentials_file`: Chemin vers le fichier de credentials GCP
- `gcp_swarm_sa_json`: Chemin de destination des credentials dans le swarm

### Configuration des ports et répliques
- `frontend_port`: 7000
- `backend_port`: 5000
- `frontend_replicas`: 2
- `backend_replicas`: 2

### Configuration de la base de données
- `db_name`: "sneakerportfolio"
- `db_user`: "guillaume"

## Templates utilisés
- `app.env.j2` : Template pour le fichier d'environnement de l'application

## Permissions
Tous les répertoires et fichiers sont créés avec :
- **Propriétaire** : `{{ ssh_user }}`
- **Groupe** : `{{ ssh_user }}`
- **Permissions répertoires** : 755
- **Permissions fichier .env** : 600 (sécurisé)

## Prérequis
- Variable `app_name` définie
- Variable `ssh_user` définie
- Template `app.env.j2` présent dans le répertoire templates
