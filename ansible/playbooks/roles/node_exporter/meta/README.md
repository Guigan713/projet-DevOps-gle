# Prometheus Node Exporter - Template Systemd Unit

Ce dépôt contient un template pour créer un fichier d’unité `systemd` pour déployer Prometheus Node Exporter sur un système Linux.

## Description

Prometheus Node Exporter est un outil qui permet d’exposer des métriques système (CPU, mémoire, disques, etc.) sous forme d’endpoint HTTP, pour être collectées et monitorées par Prometheus.

Ce template est conçu pour être utilisé avec un outil de gestion de configuration (Ansible, Jinja2…), permettant de personnaliser les paramètres selon l'environnement.

## Documentation officielle

- [Prometheus Node Exporter Documentation](https://github.com/prometheus/node_exporter)

## Variables attendues

Variables a fournir lors de l’utilisation du template /defaults/main.yml :

> [!NOTE]
> - `node_exporter_user` : Utilisateur système qui exécute le service.
> - `node_exporter_group` : Groupe associé à l’utilisateur.
> - `node_exporter_binary_path` : Chemin absolu du binaire `node_exporter`.
> - `node_exporter_port` : Port d’écoute pour les métriques HTTP.
> - `node_exporter_log_level` : Niveau de log (ex. : `info`, `debug`).
> - `node_exporter_enabled_collectors` : Liste des collecteurs **activés** (ex : `["cpu", "meminfo"]`).
> - `node_exporter_disabled_collectors` : Liste des collecteurs **désactivés** (ex : `["diskstats"]`).
> - `node_exporter_textfile_dir` : Dossier où seront lus les fichiers de métriques personnalisés (`textfile`).

## Contenu du template

```jinja2
[Unit]
Description=Prometheus Node Exporter
Documentation=https://github.com/prometheus/node_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User={{ node_exporter_user }}
Group={{ node_exporter_group }}
ExecReload=/bin/kill -HUP $MAINPID
ExecStart={{ node_exporter_binary_path }} \
  --web.listen-address=0.0.0.0:{{ node_exporter_port }} \
  --path.rootfs=/ \
  --log.level={{ node_exporter_log_level }} \
{% for collector in node_exporter_enabled_collectors %}
  --collector.{{ collector }} \
{% endfor %}
{% for collector in node_exporter_disabled_collectors %}
  --no-collector.{{ collector }} \
{% endfor %}
  --collector.textfile.directory={{ node_exporter_textfile_dir }}

SyslogIdentifier=node_exporter
Restart=always
RestartSec=1
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
```

### `[Unit]`

| Option            | Détail |
|-------------------|--------|
| `Description=Prometheus Node Exporter` | Donne une courte description du service. Cela s’affiche quand on liste les services dans `systemctl`. (Ici : "Prometheus Node Exporter"). |
| `Documentation=https://github.com/prometheus/node_exporter` | Lien vers la documentation officielle. Utile pour référence rapide via des commandes ou outils qui consultent cette variable. |
| `Wants=network-online.target` | Indique que ce service "veut" que le réseau soit disponible au moment du lancement, mais sans l’exiger strictement (dépendance faible). |
| `After=network-online.target` | Fait en sorte que ce service ne démarre qu’après que la cible `network-online.target` ait été atteinte (après montée du réseau). C’est important car le Node Exporter écoute sur un port réseau. |

---

### `[Service]`

| Option            | Détail |
|-------------------|--------|
| `Type=simple` | Indique à `systemd` que le service lancé tourne en premier plan et ne fork pas, le binaire reste donc directement contrôlé par systemd. |
| `User={{ node_exporter_user }}` | Le service s’exécute sous cet utilisateur système. (Sécurité : on évite d’utiliser `root` sans raison) |
| `Group={{ node_exporter_group }}` | Groupe système attaché au lancement du binaire. |
| `ExecReload=/bin/kill -HUP $MAINPID` | Indique comment relancer le service proprement (parfois pour relire la config, selon le support du binaire). Envoie le signal SIGHUP au processus principal. |
| `ExecStart={{ node_exporter_binary_path }} \ ...` | Commande pour démarrer Node Exporter (voir détails des sous-options ci-dessous). |
| &nbsp;&nbsp;- `--web.listen-address=0.0.0.0:{{ node_exporter_port }}` | Écoute sur *toutes* les interfaces, port défini par variable. |
| &nbsp;&nbsp;- `--path.rootfs=/` | Export de la racine du système de fichiers (`/`). |
| &nbsp;&nbsp;- `--log.level={{ node_exporter_log_level }}` | Niveau de log (info, debug, etc.) |
| &nbsp;&nbsp;- `{% for collector in node_exporter_enabled_collectors %} --collector.{{ collector }} \ {% endfor %}` | Active dynamiquement chaque collecteur listé. |
| &nbsp;&nbsp;- `{% for collector in node_exporter_disabled_collectors %} --no-collector.{{ collector }} \ {% endfor %}` | Désactive les collecteurs spécifiés. |
| &nbsp;&nbsp;- `--collector.textfile.directory={{ node_exporter_textfile_dir }}` | Dossier surveillé pour les fichiers de métriques personnalisés. |
| `SyslogIdentifier=node_exporter` | Nom d’identification dans les logs syslog/journald. Pratique pour filtrer les messages. |
| `Restart=always` | Demande à systemd de toujours redémarrer le service en cas d’arrêt inopiné. |
| `RestartSec=1` | Délai en secondes avant de réessayer un redémarrage. |
| `StartLimitInterval=0` | Désactive la limitation du nombre de redémarrages (optionnelle, parfois par défaut pour éviter la saturation de restart). |

---

### `[Install]`

| Option             | Détail |
|--------------------|--------|
| `WantedBy=multi-user.target` | Permet d’activer le service pour qu’il démarre automatiquement à chaque démarrage de la machine, une fois le niveau d’init "multi-user" atteint (mode classique serveur Linux multi-utilisateurs). |