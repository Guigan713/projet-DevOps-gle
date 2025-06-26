# Définit l'image de base Node.js version 23 (légère) et nomme ce stage "development"
FROM node:23-slim AS development

# Définit le répertoire de travail à /app dans le conteneur
WORKDIR /app

# Copie les fichiers package.json et package-lock.json dans le conteneur
COPY package*.json ./

# Installe toutes les dépendances (développement + production)
RUN npm install

# Copie tous les fichiers du projet dans le conteneur
COPY . .

# Expose le port 5000 pour l'accès au serveur backend
EXPOSE 5000

# Commande par défaut : lance le serveur en mode développement
CMD ["npm", "run", "dev"]

# Crée un nouveau stage "production" avec une image Node.js légère
FROM node:23-slim AS production

# Définit le répertoire de travail à /app pour ce stage
WORKDIR /app

# Copie les fichiers package.json et package-lock.json
COPY package*.json ./

RUN apt update && apt install -y curl

# Installation optimisée des dépendances de production uniquement
RUN npm ci --omit=dev

# Copie tous les fichiers du projet dans le stage production
COPY . .

# Expose le port 5000 pour l'accès à l'API en production
EXPOSE 5000

# Commande par défaut : lance l'application en mode production
CMD ["npm", "start"]

# Alternative commentée : lancement direct du fichier App.js avec Node
# CMD ["node", "App.js"]
