# Workflows GitHub Actions - CI/CD

## workflow de test -> test.yml

Ce workflow GitHub Actions nommé Test Workflow dédié à l’exécution des tests automatisés et à l’analyse de la qualité du code avec SonarQube sur les branches de développement.

### Déclenchement

Le workflow est déclenché dans 2 cas:

> - manuellement via **workflow_dispatch**
> - automatiquement lors de chaque push sur la branche **main**

### Description des étapes

1. Checkout repository
> - Récupère le code source pour permettre l'exécution des tâches suivantes

2. Setup Node.js
> - Installe Node.js, nécéssaire a l'exécution du frontend et du backend

3. Installation des dépendences
> - Installation des dépendences **npm** pour le backend et le frontend séparément

4. Analyse SonarQube
> - Lance une analyse de la qualité du code sur les dossiers backend et frontend via SonarQube avec les paramètres nécessaires pour la connexion et la sécurité.
> - Les données de couverture sont aussi récupérées pour alimenter l’analyse.

### Configuration MySQL

Un conteneur MySQL (mysql:9) est démarré en service Docker avec des variables d’environnement définissant :

1. Les variables d'environnement : 
> [!NOTE]
> - MYSQL_ROOT_PASSWORD
> - MYSQL_DATABASE
> - MYSQL_USER
> - MYSQL_PASSWORD

2. les ports exposés :
> [!NOTE]
> - Redirige le port MySQL standard (3306) du conteneur vers l'hôte

3. Options health-check :  
> [!NOTE]
> - Vérifie que la base MySQL est bien lancée avant de commencer les jobs.
> - Utilise la commande mysqladmin ping toutes les 10 secondes, timeout à 5 secondes, et essaie 5 fois.

### Sécurité et secrets

Les informations sensibles sont injectées via les GitHub Secrets :

> [!NOTE]
> - **SONAR_TOKEN** : Clé d’accès à SonarQube.
> - **SONAR_HOST_URL** : URL du serveur SonarQube.
> - **SONAR_ORG** : Organisation SonarQube.


## Workflow de déploiement -> build-deploy.yml

Ce workflow GitHub Actions permet de build et déployer automatiquement l'application dès lors que le workflow de tests (Test Workflow) a été exécuté avec succès.

### Déclenchement

Le workflow se déclenche automatiquement à la fin de l’exécution complète et réussie du workflow nommé **Test Workflow** (workflow_run).

### Description des étapes

1. Checkout repository
> - Récupère le code source pour permettre l'exécution des tâches suivantes

2. Setup Node.js
> - Installe Node.js pour la gestion des dépendances et le build des applications Node.

3. Installation des dépendences et build du frontend
> - Installation (npm install) et compilation (npm run build) de la partie frontend située dans le dossier frontend.

4. Installation des dépendences et build du backend
> - Installation (npm install) et compilation (npm run build) de la partie backendend située dans le dossier backend.

5. Setup Python
> - Installe Python 3.13, nécessaire pour exécuter Ansible

6. Installation d’Ansible et des dépendances nécessaires
> - Met à jour pip, puis installe Ansible et la bibliothèque boto3 (utilisée pour l’intégration AWS)

7. Configuration de la clé SSH
> - Déploie la clé privée SSH fournie dans le secret GitHub *AWS_PRIVATE_KEY*, avec les droits d’accès appropriés, pour permettre la connexion SSH aux serveurs de destination.

8. Exécution du playbook Ansible
> - Lance le playbook deploy.yml via Ansible pour déployer l’application sur les serveurs listés dans le fichier d’inventaire inventories/hosts.ini.

## Workflow de versionning -> release.yml

Ce workflow automatise le versioning, la création de tags, et la génération des changelogs grâce à l’outil release-please de Google.

### Déclenchement

le workflow est lancé dans 2 cas : 

> [!NOTE]
> - manuellement via **workflow_dispatch**
> - automatiquement à chaque push sur la branche **main**

### Description des étapes

1. Checkout repository
> - Récupère le code source pour permettre l'analyse et la génération de version

2. Release please action

> [!NOTE]
> - Utilise l'action officielle release-please-action pour : 
    - Analyser les commits et le code du dépot
    - Déterminer automatiquement le nouveau numéro de version selon la convention de commit (release-type: simple)
    - Mettre à jour les releases GitHub, créer un changelog, et générer un tag pour la version
    - Créer/Mettre à jour une Pull Request contenant la release si besoin

### Permissions

Le workflow a besoin des permissions d’écriture sur :

> [!NOTE]
> - contents (pour pousser tags/releases/changelogs)
> - pull-requests (pour ouvrir ou mettre à jour les PRs automatiques de release)

Ces permissions sont configurées dans la clé permissions du workflow.

### Sécurité

Secrets attendus

> [!NOTE]
> - PAT_TOKEN : Un Personal Access Token GitHub avec les droits requis pour créer des tags/releases et manipuler les branches principales du repo.

Celui-ci doit être stocké dans les GitHub Secrets pour être exploité en toute sécurité par le workflow.

### Pré-requis

> [!NOTE]
> - Les messages de commits doivent suivre une convention de commit claire (si possible [Conventional Commits](https://www.conventionalcommits.org/fr/v1.0.0/)), pour que release-please détecte les changements de version.
> - Le dépôt doit être configuré sur GitHub et disposer du PAT_TOKEN dans les secrets.
