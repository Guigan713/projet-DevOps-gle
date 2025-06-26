# Rôle Ansible : monitoring

Initialisation, génération et déploiement de la configuration monitoring Prometheus & Grafana

## Objectif

Ce rôle prépare automatiquement tout l’arborescence et les fichiers de configuration nécessaires pour la supervision de la stack, en environnement Docker Swarm ou équivalent.
Il génère tous les répertoires et templates pour Prometheus et Grafana, et provisionne les dashboards/outils prêts à l’emploi.

## Fonctionnalités

> - Création automatisée des dossiers système attendus par vos containers Prometheus et Grafana.
> - Génération des fichiers de configuration :
>    - prometheus.yml (scrape jobs, retention, règles…)
>    - Datasource Grafana (connexion préconfigurée à Prometheus)
>    - Provider de dashboards Grafana
>    - Dashboard de monitoring Docker Swarm (fichier JSON injecté)
> - Templates Jinja2 : tous les fichiers sont générés dynamiquement selon vos variables Ansible/project.
> - Sécurité : fichiers créés avec les droits adéquats, selon l’utilisateur système cible.

## Structure

> - Création de l’arborescence dans /opt/monitoring (hiérarchie Prometheus et Grafana complète)
> - Génération des templates sur le leader Swarm
> - Provisionnement automatique des dashboards et connexions datasource sur Grafana, prêt pour CI/CD ou infra-as-code

## Variables utilisées

> - **ssh_user** : utilisateur cible sur le serveur
> - **prometheus_port** : port d’expo Prometheus
> - **grafana_port** : port d’expo Grafana
> - **grafana_password** : mot de passe admin Grafana (par défaut: 'admin123', peut être surchargé via vault)
> - **prometheus_retention** : durée de rétention des métriques Prometheus
> - **grafana_retention** : durée de conservation côté Grafana

## Exigences

> - Les templates .j2 doivent être présents dans templates/ du rôle ou référencés correctement.
> - Exécuté sur le leader Swarm (groups['swarm_managers'][0]) : toutes les actions sont conditionnées pour ne tourner que sur ce nœud (permet plusieurs managers HA sans conflit).

## Exemple d’inventaire minimal

```ini
[swarm_managers]
manager1 ansible_host=1.2.3.4
```

## Dans le playbook principal :

```yml
- hosts: swarm_managers
  become: yes
  roles:
    - monitoring_config
```