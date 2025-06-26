# Rôle Ansible : app_build

Préparation des répertoires applicatifs, gestion de l’environnement GCP et SSL

## Objectif

Ce rôle garantit la mise en place automatique et sécurisée de l’arborescence applicative nécessaire au déploiement de l’application dans un cluster Docker Swarm, et gère l’injection des secrets GCP pour le DNS challenge Let’s Encrypt (SSL wildcard).

## Ce que fait le rôle

> - Création de tous les répertoires applicatifs clés (/opt/<app_name>, volumes, build, frontend/backend, letsencrypt…)
> - Attribution des droits à l’utilisateur cible (ssh_user) sur chaque dossier
> - Gestion conditionnelle du secret GCP (copie de la clé de service gcp-service-account.json si besoin pour la validation DNS/Let’s Encrypt)
> - Sécurisation des droits sur les dossiers sensibles (letsencrypt, secret GCP)
> - Génération d’un fichier d’environnement (.env) depuis un template Jinja2, injectant dynamiquement toutes les variables d’environnement de l’application (mot de passe DB, URL, mode, etc.)
> - Génération d’un message de debug rappelant la clé GCP et l’utilisateur cible (aide au debug et à la transparence du déploiement)

## Variables principales utilisées

> - **project_name** : nom du projet
> - **app_directory** : chemin racine de l’application (typiquement /opt/<app_name>)
> - **ssh_user** : utilisateur possédant les fichiers/dossiers applicatifs
> - **gcp_credentials_file** : chemin vers la clé JSON GCP pour DNS challenge (optionnel)
> - **app_environment, db_name, db_user, domain_name...** : toutes les variables d’environnement propres à l’app, injectées dans .env
> - **frontend_port, backend_port, …**: configuration fine du cluster/container

## Exemple d’utilisation

Dans le playbook principal :

```yml
- hosts: swarm_managers
  roles:
    - role: app_prepare
```

## Pré-requis

> - Disposer d’un template d’environnement (templates/app.env.j2) renseigné avec les bonnes variables (via group_vars ou directement dans le role/playbook)
> - Avoir, le fichier de credentials GCP valide et le chemin déclaré dans gcp_credentials_file
> - Variables d’environnement correctement renseignées
> - La collection community.docker (installable via ansible-galaxy collection install community.docker)
