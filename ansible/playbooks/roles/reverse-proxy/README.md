## Étape 1: Installation des paquets requis

```yml
- name: Install required packages
  package:
    name:
      - nginx
      - certbot
      - python3-certbot-nginx
    state: present
```

### Explication :

> [!NOTE]
> - **nginx** : Le serveur web qui servira de reverse proxy
> - **certbot** : Outil pour générer et gérer les certificats SSL Let's Encrypt gratuitement
> - **python3-certbot-nginx** : Plugin qui permet à certbot de configurer automatiquement nginx
> - **state: present** : S'assure que ces paquets sont installés

## Étape 2: Démarrage et activation du service nginx

```yml
- name: Start and enable nginx
  systemd:
    name: nginx
    state: started
    enabled: yes
```

### Explication :

> [!NOTE]
> - **state: started** : Démarre le service nginx immédiatement
> - **enabled: yes** : Configure nginx pour qu'il démarre automatiquement au boot du système
> - Utilise systemd (gestionnaire de services Linux moderne)

## Étape 3: Suppression de la configuration par défaut

```yml
- name: Remove default nginx configuration
  file:
    path: /etc/nginx/sites-enabled/default
    state: absent
```

### Explication :

> [!NOTE]
> - Supprime le site par défaut de nginx (page "Welcome to nginx!")
> - **/etc/nginx/sites-enabled/default** : Lien symbolique vers la configuration par défaut
> - **state: absent** : S'assure que ce fichier n'existe pas
> - Pourquoi ? Pour éviter les conflits avec notre nouvelle configuration

## Étape 4: Création de la configuration nginx personnalisée

```yml
- name: Create nginx configuration for domain
  template:
    src: nginx.conf.j2
    dest: "/etc/nginx/sites-available/{{ domain_name }}"
  notify: reload nginx
```

### Explication :

> [!NOTE]
> - **template** : Utilise un fichier template Jinja2 (.j2) pour générer la configuration
> - **src: nginx.conf.j2** : Template source (dans roles/reverse-proxy/templates/)
> - **dest: "/etc/nginx/sites-available/{{ domain_name }}"** : Destination finale (ex: /etc/nginx/sites-available/mondomaine.com)
> - **notify: reload nginx** : Déclenche le handler "reload nginx" si le fichier change
> - **Sites-available vs sites-enabled** : Convention Debian/Ubuntu pour séparer les configs disponibles des actives

## Étape 5: Activation du site

```yml
- name: Enable nginx site
  file:
    src: "/etc/nginx/sites-available/{{ domain_name }}"
    dest: "/etc/nginx/sites-enabled/{{ domain_name }}"
    state: link
  notify: reload nginx
```

### Explication :

> [!NOTE]
> - Crée un lien symbolique de sites-available vers sites-enabled
> - **state: link** : Crée un lien symbolique
> - **Concept** : nginx ne lit que les configs dans sites-enabled
C'est comme "activer" le site web

## Étape 6: Test de la configuration nginx

```yml
- name: Test nginx configuration
  command: nginx -t
  changed_when: false
```

### Explication :

> [!NOTE]
> - **nginx -t** : Teste la syntaxe de toutes les configurations nginx
> - **changed_when: false** : Dit à Ansible que cette commande ne change pas l'état du système
> - **Sécurité** : Vérifie qu'il n'y a pas d'erreurs avant de redémarrer nginx
> - Si erreur → le playbook s'arrête ici

## Étape 7: Rechargement de nginx

```yml
- name: Reload nginx
  systemd:
    name: nginx
    state: reloaded
```

### Explication :

> [!NOTE]
> - **state: reloaded** : Recharge la configuration sans interrompre les connexions existantes
> - Plus gracieux qu'un restart complet
> - Applique la nouvelle configuration

## Étape 8: Installation des certificats SSL

```yml
- name: Install SSL certificates with certbot
  command: >
    certbot --nginx --non-interactive --agree-tos 
    --email {{ ssl_email }} 
    -d {{ domain_name }}{% for service in services %} -d {{ service.subdomain }}.{{ domain_name }}{% endfor %}
  args:
    creates: "/etc/letsencrypt/live/{{ domain_name }}/fullchain.pem"
```

### Explication :

> [!NOTE]
> - **--nginx** : Utilise le plugin nginx (configure automatiquement nginx)
> - **--non-interactive** : Aucune interaction utilisateur requise
> - **--agree-tos** : Accepte automatiquement les termes de service Let's Encrypt
> - **--email {{ ssl_email }} **: Email pour les notifications d'expiration
> - **-d {{ domain_name }}** : Premier domaine (ex: -d mondomaine.com)
> - **{% for service in services %}** : Boucle Jinja2 qui ajoute chaque sous-domaine (ex: -d api.mondomaine.com -d app.mondomaine.com)
> - **creates**: "/etc/letsencrypt/live/{{ domain_name }}/fullchain.pem" : Idempotence - ne s'exécute que si ce fichier n'existe pas

## Étape 9: Configuration du renouvellement automatique

```yml
- name: Setup certbot auto-renewal
  cron:
    name: "Certbot auto-renewal"
    minute: "0"
    hour: "12"
    job: "/usr/bin/certbot renew --quiet"
```

### Explication :

> [!NOTE]
> - Ajoute une tâche cron pour renouveler automatiquement les certificats
> - **minute**: "0" et hour: "12" : S'exécute tous les jours à 12h00
> - **certbot renew --quiet** : Renouvelle uniquement les certificats qui expirent dans 30 jours
> - **--quiet** : Mode silencieux (pas de sortie sauf erreur)
> - **Important** : Les certificats Let's Encrypt expirent tous les 90 jours

### Flux global du processus :

> [!NOTE]
> - **Préparation** → Installation des outils
> - **Service** → Démarrage de nginx
> - **Nettoyage** → Suppression config par défaut
> - **Configuration** → Création de notre config personnalisée
> - **Activation** → Activation du site
> - **Vérification** → Test de la syntaxe
> - **Application** → Rechargement nginx
> - **Sécurisation** → Installation SSL
> - **Maintenance** → Auto-renouvellement des certificats
