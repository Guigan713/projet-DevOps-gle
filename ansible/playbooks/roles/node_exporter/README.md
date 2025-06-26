# Rôle Ansible : node_exporter

Déploiement automatique de Prometheus Node Exporter sur le serveur (mode systemd)

## Objectif

Ce rôle permet l’installation rapide et sécurisée de Prometheus Node Exporter (binaire officiel) pour la collecte de métriques système Linux sur vos machines, avec gestion automatique du service systemd.

## Fonctionnalités

> - Télécharge la version spécifiée de Node Exporter (directement des releases GitHub)
> - Décompresse et installe le binaire sur le système cible
> - Déploie un service systemd dédié pour gérer le process Node Exporter
> - Active et démarre le service pour un monitoring persistant au redémarrage

## Variables

> - **node_exporter_version** : version précise de Node Exporter à déployer (exemple : "1.7.0")

## Prérequis

> - Système compatible Linux (x86-64)
> - Privilèges root (pour installer binaire & service)

## Dans le playbook principal :

```yml
- hosts: all
  become: yes
  roles:
    - role: node_exporter
```