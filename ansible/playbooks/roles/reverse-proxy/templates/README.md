# Fichier nginx.conf

## Section events

```j2
events {
  worker_connections 1024;
}
```

> [!NOTE]
> - **events** : Contexte qui définit le comportement des connexions
> - **worker_connections 1024** : Chaque processus worker peut gérer simultanément 1024 connexions clients


## Section http

### Configuration des types MIME et transfert

```j2
include /etc/nginx/mime.types;
default_type application/octet-stream;
sendfile on;
keepalive_timeout 65;
```

> [!NOTE]
> - **include /etc/nginx/mime.types** : Inclut les types MIME pour identifier les fichiers (.html, .css, .js, etc.)
> - **default_type application/octet-stream** : Type par défaut pour les fichiers non reconnus
> - **sendfile on** : Optimise le transfert de fichiers en utilisant l'appel système sendfile()
> - **keepalive_timeout 65** : Maintient les connexions ouvertes 65 secondes pour réutiliser les connexions TCP

### Configuration des upstreams (serveurs backend)

```j2
upstream frontend {
  server {{ frontend_private_ip }}:3000;
}

upstream backend {
  server {{ backend_private_ip }}:5000;
}

upstream grafana {
  server {{ monitoring_private_ip }}:3000;
}
```

> [!NOTE]
> - **upstream** : Définit des groupes de serveurs pour la répartition de charge
> - **frontend** : Serveur d'interface utilisateur sur le port 3000
> - **backend** : Serveur API sur le port 5000
> - **grafana** : Serveur de monitoring sur le port 3000
> - Les {{ }} sont des variables de template (Ansible, Jinja2, etc.)

### Zones de limitation de débit

```j2
limit_req_zone $binary_remote_addr zone=main_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=monitoring_limit:10m rate=5r/s;
```

> [!NOTE]
> - **limit_req_zone**: Définit des zones de limitation des requêtes
> - **$binary_remote_addr** : Utilise l'IP client comme clé (format binaire, plus efficace)
> - **zone=nom:10m** : Crée une zone nommée de 10MB en mémoire
> - **rate=Xr/s** : Limite le taux de requêtes par seconde :
    - **main_limit** : 10 requêtes/seconde (usage général)
    - **api_limit** : 20 requêtes/seconde (API plus sollicitée)
    - **monitoring_limit** : 5 requêtes/seconde (monitoring moins critique)

### Configuration du serveur HTTP (port 80)

```j2
server {
    listen 80;
    server_name projet-devops-gle.fr;

    location /.well-known/acme-challenge/ {
      root /var/www/certbot;
    }

    location / {
      # return 301 https://$host$request_uri;
      return 301 https://projet-devops-gle.fr$request_uri;
    }
}
```

#### Directives principales

> [!NOTE]
> - **server** : Début du bloc de configuration pour un serveur virtuel
> - **listen 80** : Le serveur écoute sur le port 80 (HTTP standard)
> - **server_name projet-devops-gle.fr** : Définit le nom de domaine que ce serveur traite

#### Location pour la validation SSL

> [!NOTE]
> - **location /.well-known/acme-challenge/** : Gère les requêtes vers ce chemin spécifique
> - **root /var/www/certbot** : Sert les fichiers depuis ce répertoire
> - **Utilité** : Permet à Let's Encrypt/Certbot de valider la propriété du domaine lors de la génération/renouvellement des certificats SSL

#### Redirection HTTPS

> [!NOTE]
> - **location /** : Capture toutes les autres requêtes (catch-all)
> - **return 301** : Code de redirection permanente HTTP
> - **Ligne active** : Redirige spécifiquement vers https://projet-devops-gle.fr
> - **$request_uri**: Préserve le chemin et les paramètres de la requête originale

### Configuration du serveur HTTPS

#### Directives d'écoute

```j2
server {
    listen 443 ssl http2 default_server;
    server_name {{ domain_name }} www.{{ domain_name }};
}
```

> [!NOTE]
> - **listen 443** : Écoute sur le port 443 (HTTPS standard)
> - **ssl** : Active le support SSL/TLS
> - **http2** : Active le protocole HTTP/2 (plus rapide que HTTP/1.1)
> - **default_server** : Serveur par défaut si aucun autre ne correspond
> - **server_name** : Accepte les requêtes pour le domaine principal et sa variante www

#### Configuration SSL

`ssl_certificate /etc/letsencrypt/live/projet-devops-gle.fr/fullchain.pem;`

> [!NOTE]
> - **ssl_certificate** : Directive qui spécifie le chemin vers le certificat SSL
> - **/etc/letsencrypt/live/** : Répertoire standard de Let's Encrypt pour les certificats actifs
> - **projet-devops-gle.fr/** : Sous-dossier spécifique au domaine
> - **fullchain.pem** : Fichier contenant :
>   - Le certificat du domaine
>   - La chaîne complète des certificats intermédiaires
>   - Permet aux navigateurs de valider tout le chemin de certification jusqu'à l'autorité racine

`ssl_certificate_key /etc/letsencrypt/live/projet-devops-gle.fr/privkey.pem;`

> [!NOTE]
> - **ssl_certificate_key** : Directive qui spécifie le chemin vers la clé privée
> - **privkey.pem** : Fichier contenant la clé privée correspondant au certificat
> - **Sécurité** : Ce fichier est sensible et doit être protégé (permissions 600)
> - **Fonction** : Utilisée pour déchiffrer les données chiffrées avec la clé publique

`include /etc/letsencrypt/options-ssl-nginx.conf;`

> [!NOTE]
> - **include** : Inclut un fichier de configuration externe
> - **options-ssl-nginx.conf** : Fichier généré par Certbot contenant :
>    - Les protocoles SSL/TLS recommandés (TLS 1.2, TLS 1.3)
>    - Les suites de chiffrement sécurisées
>    - Les paramètres SSL optimisés
>    - Configuration maintenue à jour par Certbot selon les meilleures pratiques

`ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;`

> [!NOTE]
> - **ssl_dhparam** : Spécifie les paramètres Diffie-Hellman pour l'échange de clés
> - **ssl-dhparams.pem** : Fichier contenant les paramètres DH précalculés
> - **Fonction** : Améliore la sécurité de l'échange de clés en utilisant Perfect Forward Secrecy (PFS)
> - **Avantage** : Même si la clé privée est compromise, les sessions passées restent sécurisées

#### En-têtes de sécurité

```j2
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "..." always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

> [!NOTE]
> - **X-Frame-Options "SAMEORIGIN"** : Empêche l'intégration dans des iframes externes (protection contre clickjacking)
> - **X-XSS-Protection** : Active la protection XSS du navigateur
> - **X-Content-Type-Options "nosniff"** : Empêche la détection automatique du type MIME
> - **Referrer-Policy** : Contrôle les informations envoyées dans l'en-tête Referer
> - **Content-Security-Policy** : Définit les sources autorisées pour le contenu :
>    - **default-src 'self'** : Par défaut, seules les ressources du même domaine
>    - **script-src 'self' 'unsafe-inline' 'unsafe-eval'** : Scripts du domaine + inline + eval
>    - **style-src 'self' 'unsafe-inline'** : CSS du domaine + styles inline
>    - **img-src 'self' data: https:** : Images du domaine + data URLs + HTTPS
>    - **connect-src 'self' wss: ws:** : Connexions vers le domaine + WebSockets
> - **Strict-Transport-Security** : Force HTTPS pendant 1 an, inclut les sous-domaines, preload pour les navigateurs

#### Configuration des logs

```j2
access_log /var/log/nginx/{{ domain_name }}_access.log combined;
error_log /var/log/nginx/{{ domain_name }}_error.log warn;
```

> [!NOTE]
> - **access_log** : Enregistre toutes les requêtes avec le format "combined"
> - **error_log** : Enregistre les erreurs de niveau "warn" et plus graves
> - Les noms de fichiers utilisent le nom de domaine pour faciliter l'identification

#### Configuration des timeouts et limites

```j2
client_max_body_size {{ max_upload_size | default('50M') }};
client_body_timeout 60s;
client_header_timeout 60s;
send_timeout 60s;
```

> [!NOTE]
> - **client_max_body_size** : Taille maximale des uploads (50M par défaut, configurable)
> - **client_body_timeout** : Timeout pour la réception du corps de requête (60s)
> - **client_header_timeout** : Timeout pour la réception des en-têtes (60s)
> - **send_timeout** : Timeout pour l'envoi de la réponse au client (60s)

#### Configuration de compression GZIP

```j2
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types [...];
```

> [!NOTE]
> - **gzip on** : Active la compression
> - **gzip_vary on** : Ajoute l'en-tête "Vary: Accept-Encoding"
> - **gzip_min_length 1024** : Compresse seulement les fichiers > 1KB
> - **gzip_comp_level 6** : Niveau de compression (1-9, 6 = équilibre performance/taille)
> - **gzip_types** : Liste des types MIME à compresser (CSS, JS, JSON, XML, fonts, etc.)

#### Configuraton de la location racine "/"

```j2
location / {
    limit_req zone=main_limit burst=20 nodelay;

    proxy_pass http://frontend;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
}
```

| Header | Variable | Purpose |
|--------|----------|---------|
| Host | `$host` | Nom d'hôte original |
| X-Real-IP | `$remote_addr` | IP réelle du client |
| X-Forwarded-For | `$proxy_add_x_forwarded_for` | Chain des IPs (proxies) |
| X-Forwarded-Proto | `$scheme` | Protocole (http/https) |
| X-Forwarded-Host | `$host` | Hôte original |
| X-Forwarded-Port | `$server_port` | Port original |


1. Limitation du taux de requêtes

> [!NOTE]
> - **zone=main_limit** : Utilise la zone de limitation définie précédemment (probablement 10r/s)
> - **burst=20** : Autorise un pic de 20 requêtes supplémentaires au-delà de la limite
> - **nodelay** : Traite immédiatement les requêtes dans la limite de burst (pas de mise en file d'attente)

Exemple : Si la limite est 10r/s

> - **Requêtes 1-10** : Traitées normalement
> - **Requêtes 11-30** : Traitées immédiatement (burst)
> - **Requête 31+** : Rejetées avec erreur 503

2. Proxy vers le frontend

> [!NOTE]
> - **proxy_pass** : Redirige toutes les requêtes vers l'upstream nommé "frontend"
> - **http://frontend** : Référence un groupe upstream défini ailleurs dans la configuration
> - Toutes les requêtes sur "/" sont transférées au serveur frontend

3. version du protocole HTTP

> [!NOTE]
> - **1.1** : Force l'utilisation de HTTP/1.1 pour communiquer avec le backend
> - **Nécessaire pour** : Connexions persistantes et support WebSocket
> - **Par défaut** : Nginx utilise HTTP/1.0 sans cette directive

4. Support WebSocket - En-tête Upgrade

> [!NOTE]
> - **Upgrade** : Transmet l'en-tête Upgrade du client vers le backend
> - **$http_upgrade** : Variable Nginx contenant la valeur de l'en-tête "Upgrade" du client
> - **Fonction** : Permet au client de demander une mise à niveau vers WebSocket
> - **Valeur typique** : "websocket" pour les connexions WebSocket

5. Support WebSocket - En-tête Connection

> [!NOTE]
> - **Connection 'upgrade'** : Force l'en-tête Connection à "upgrade"
> - **Différence importante** : Utilise une valeur fixe au lieu de la variable
> - **Fonction** : Indique au backend que la connexion doit être mise à niveau
> - **Requis pour** : Établir correctement les connexions WebSocket

6. Transmission du nom d'hôte

> [!NOTE]
> - **Host** : Transmet le nom d'hôte original au backend
> - **$host** : Variable contenant le nom d'hôte de la requête originale
> - **Importance** : Permet au backend de connaître le domaine demandé
> - **Exemple** : Si le client demande "exemple.com", le backend recevra Host: exemple.com

7. Contournement du cache

> [!NOTE]
> - **proxy_cache_bypass** : Ignore le cache proxy dans certaines conditions
> - **$http_upgrade** : Si l'en-tête Upgrade est présent, bypass le cache
> - **Raison** : Les connexions WebSocket ne doivent jamais être mises en cache
> - **Effet** : Les requêtes WebSocket vont directement au 

8. Flux complet d'une requête WebSocket

> [!NOTE]
> - **Client → GET /chat HTTP/1.1 + Upgrade**: websocket
> - **Nginx** :
>    - Vérifie le rate limiting (main_limit + burst)
>    - Détecte l'en-tête Upgrade
>    - Bypass le cache
>    - Forward vers le backend avec HTTP/1.1
> - **Backend** → Répond avec 101 Switching Protocols
> - **Nginx** → Transmet la réponse au client
> - Connexion WebSocket établie entre client et backend via Nginx


#### Configuration de la route API "/api/"

```j2
location /api/ {
    limit_req zone=api_limit burst=15 nodelay;

    proxy_pass http://backend/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass $http_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_connect_timeout 30s;
    proxy_read_timeout 90s;  # Plus long pour les APIs
    proxy_send_timeout 90s;
    
    # Headers spécifiques pour les APIs
    proxy_set_header Accept-Encoding "";
    proxy_set_header X-Forwarded-Method  $ request_method;
}
```

1. Limitation du taux pour les APIs

> [!NOTE]
> - **zone=api_limit** : Zone de limitation spécifique aux APIs (probablement plus restrictive)
> - **burst=15** : Pic autorisé de 15 requêtes (moins que frontend car APIs plus sensibles)
> - **nodelay** : Traitement immédiat sans file d'attente
> - **Logique** : Les APIs nécessitent une protection renforcée contre les abus

2. Proxy vers le backend API

> [!NOTE]
> - **http://backend/** : Upstream vers le serveur d'API
> - **Slash final (/)** : Important ! Supprime "/api" de l'URL transmise
> - **Exemple** : GET /api/users → GET /users sur le backend
> - **Sans le slash** : GET /api/users → GET /api/users sur le backend

3. Support WebSocket et cache (identique au frontend) (lignes 333 a 337)
4. En-têtes de proxy étendus (lignes 338 a 341)

> [!NOTE]
> - **Host** : Nom d'hôte original (déjà vu)
> - **X-Real-IP** : Adresse IP réelle du client
>    - **$remote_addr** : IP directe du client
>    - **Exemple** : X-Real-IP: 192.168.1.100
> - **X-Forwarded-For** : Chaîne complète des IPs
>    - **$proxy_add_x_forwarded_for** : Ajoute l'IP client à la chaîne existante
>    - **Exemple** : X-Forwarded-For: 10.0.0.1, 192.168.1.100
> - **X-Forwarded-Proto** : Protocole original
>    - **$scheme** : "http" ou "https"
>    - **Exemple** : X-Forwarded-Proto: https

5. Timeouts spécifiques aux APIs (lignes 343 a 345)

> [!NOTE]
> - **proxy_connect_timeout 30s** : 30 secondes pour établir la connexion
> - **proxy_read_timeout 90s** : 90 secondes pour recevoir la réponse du backend
>    - Plus long car les APIs peuvent faire des calculs complexes
>    - Traitement de données, requêtes BDD, appels externes
> - **proxy_send_timeout 90s** : 90 secondes pour envoyer la requête au backend

6. En-têtes spécifiques aux APIs (lignes 347 a 349)

> [!NOTE]
> - **Accept-Encoding ""** : Désactive la compression entre Nginx et le backend
>    - **Raison** : Évite les problèmes avec les réponses JSON/API
>    - **Note** : La compression client reste active via gzip
>    - **Avantage** : Nginx peut analyser/modifier les réponses si nécessaire
> - **X-Forwarded-Method $request_method** : Transmet la méthode HTTP originale
>    - **$request_method **: GET, POST, PUT, DELETE, etc.
>    - **Utilité** : Le backend connaît la méthode exacte utilisée
>    - **Exemple** : X-Forwarded-Method: POST

7. Avantages de cette configuration

> [!NOTE]
> - **Sécurité renforcée** : Rate limiting plus strict
> - **Réécriture d'URL** : URLs propres pour le backend
> - **Timeouts adaptés** : Plus de temps pour les opérations complexes
> - **Traçabilité** : Le backend connaît l'IP réelle et le protocole
> - **Compatibilité** : Évite les problèmes de compression avec les APIs JSON
> - **Support temps réel** : WebSocket pour les APIs live

#### Assets statiques

```j2
location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff2|woff|ttf|eot|webp|avif) $  {
    proxy_pass http://frontend_backend;
    
    # Cache control
    expires 30d;
    add_header Cache-Control "public, immutable, no-transform";
    add_header Vary "Accept-Encoding";
    
    # Compression spécifique
    gzip_static on;
    
    # Headers proxy basiques
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Optimisation
    proxy_cache_valid 200 7d;
    proxy_ignore_headers Cache-Control;
}
```

>[!NOTE]
> - ~* : Expression régulière insensible à la casse
> - **expires 30d** : Cache navigateur de 30 jours
> - **Cache-Control** : Directives de cache public et immuable
> - **gzip_static on** : Utilise les versions pré-compressées si disponibles
> - **proxy_cache_valid** : Cache proxy de 7 jours pour les réponses 200

#### Configuration de la location "/grafana/"

```j2
location /grafana/ {
    proxy_pass http://grafana/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;

    # Important: for proper /grafana/ prefix handling
    rewrite ^/grafana/(.*) /$1 break;
}
```

1. Proxy vers Grafana

> [!NOTE]
> - **http://grafana/** : Upstream vers le serveur Grafana
> - **Slash final (/)** : Supprime "/grafana" de l'URL transmise au backend
> - **Exemple** : GET /grafana/dashboard → GET /dashboard sur Grafana

2. En-têtes de proxy standards

Configuration identique a ce que l'on retrouve pour frontend

#### Configuration de la location "/prometheus/"

```j2
location /prometheus/ {
    # Restriction d'accès par IP (votre IP d'admin)
    allow {{ admin_ip }}/32;
    deny all;
    
    proxy_pass http://prometheus/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    proxy_connect_timeout 30s;
    proxy_read_timeout 60s;
}
```

1. Restriction d'accès par IP

> [!NOTE]
> - **allow {{ admin_ip }}/32** : 
>    - **{{ admin_ip }}** : Variable template (ex: Ansible) contenant l'IP de l'administrateur
>    - **/32** : Masque de sous-réseau pour une IP unique (CIDR)
>    - **Exemple** : allow 203.0.113.45/32; (seule cette IP exacte)
> - **deny all** : 
>    - Refuse toutes les autres connexions
>    - **Ordre important** : allow puis deny
>    - **Logique** : Si IP autorisée → accès, sinon → erreur 403

2. Proxy vers Prometheus

> [!NOTE]
> - **http://prometheus/** : Upstream vers le serveur Prometheus
> - **Slash final (/)** : Supprime "/prometheus" de l'URL
> - **Exemple** : GET /prometheus/metrics → GET /metrics sur Prometheus

3. En-têtes de proxy

> [!NOTE]
> - **Host** : Nom d'hôte original
> - **X-Real-IP** : IP réelle du client (l'IP autorisée)
> - **X-Forwarded-For** : Chaîne des IPs de proxy
> - **X-Forwarded-Proto** : Protocole original (https)

4. Timeouts pour Prometheus

> [!NOTE]
> - **proxy_connect_timeout 30s** : 30 secondes pour se connecter à Prometheus
> - **proxy_read_timeout 60s** : 60 secondes pour recevoir la réponse
>    - Plus court que les APIs car Prometheus répond généralement rapidement
>    - Assez long pour les requêtes de métriques complexes

#### Endpoint métriques "/metrics"

```j2
location /metrics {
    # Seul le serveur monitoring peut accéder
    allow {{ monitoring_private_ip }};
    allow 127.0.0.1;
    deny all;
    
    # Retourne les métriques nginx
    stub_status on;
    access_log off;
}
```

1. Restrictions d'accès

> [!NOTE]
> - **{{ monitoring_private_ip }}** : Variable template (IP du serveur Prometheus)
>    - **Exemple** : allow 10.0.1.50; (IP privée du serveur de monitoring)
> - **127.0.0.1** : Localhost (accès local pour tests/debug)
> - **deny all** : Bloque tous les autres accès

2. Module stub_status

> [!NOTE]
> - **stub_status on** : Active les métriques Nginx natives
> - **access_log off** : Désactive les logs pour cet endpoint (évite le spam)

3. Métriques exposées

> [!NOTE]
> - **Active connections** : Connexions actives actuelles
> - **accepts** : Connexions acceptées au total
> - **handled** : Connexions traitées (normalement = accepts)
> - **requests** : Requêtes totales traitées
> - **Reading** : Nginx lit les en-têtes de requête
> - **Writing** : Nginx écrit la réponse au client
> - **Waiting** : Connexions keep-alive en attente

#### Sécurité - fichiers sensibles

```j2
location ~ /(\.|wp-config|readme|license|changelog|nginx\.conf) {
    deny all;
    access_log off;
    log_not_found off;
    return 404;
}
```

1. expressions régulières

> [!NOTE]
> - ~ : Correspondance par expression régulière (sensible à la casse)
> - **Patterns bloqués** :
>    - **\.** : Fichiers cachés (.env, .git, .htaccess)
>    - **wp-config** : Fichiers de configuration WordPress
>    - **readme** : Fichiers de documentation
>    - **license** : Fichiers de licence
>    - **changelog** : Fichiers de changelog
>    - **nginx\.conf** : Fichiers de configuration Nginx

2. Actions de sécurité

> [!NOTE]
> - **deny all** : Bloque l'accès pour tous
> - **access_log off** : Pas de log des tentatives d'accès
> - **log_not_found off** : Pas de log des erreurs 404
> - **return 404** : Retourne "Not Found" (masque l'existence)



