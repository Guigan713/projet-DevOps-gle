# Définit l'image de base Node.js version 23 (légère) et nomme ce stage "base"
FROM node:23-slim AS base

# Définit le répertoire de travail à /app dans le conteneur
WORKDIR /app

# Copier et installer les dépendances -> # Copie les fichiers package.json et package-lock.json dans le conteneur
COPY package*.json ./

# Installe toutes les dépendances Node.js définies dans package.json
RUN npm install

# Stage de développement -> Crée un nouveau stage "development" basé sur le stage "base"
FROM base AS development

# Copie tous les fichiers du projet dans le conteneur
COPY . .

# Copie spécifiquement le fichier d'environnement .env
COPY .env .env

# Expose le port 3000 pour l'accès externe
EXPOSE 3000

# Commande par défaut : lance le serveur de développement
CMD ["npm", "run", "dev"]

# Crée un nouveau stage "build" basé sur le stage "base"
FROM base AS build

# Copie tous les fichiers du projet dans ce stage
COPY . .

# Exécute la commande de build pour créer les fichiers de production
RUN npm run build

# Stage de production avec Nginx -> # Crée le stage final "production" avec une image Nginx légère (Alpine)
FROM nginx:alpine AS production

# Copie les fichiers buildés du stage "build" vers le répertoire web de Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copie la configuration Nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Définit les permissions de lecture/exécution sur les fichiers web
RUN chmod -R 755 /usr/share/nginx/html

# Expose le port 80 pour l'accès HTTP
EXPOSE 80

# Lance Nginx en mode foreground (non-daemon) pour Docker
CMD ["nginx", "-g", "daemon off;"]