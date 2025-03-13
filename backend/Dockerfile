# Utilisation d'une image Node.js pour le backend
FROM node:22

# Définition du répertoire de travail
WORKDIR /app

# Copier les fichiers du projet
COPY package.json package-lock.json ./
RUN npm install

# Copier le reste du projet
COPY . .

# Copier les variables d'environnement
COPY .env .env

# Exposer le port de l'API
EXPOSE 5000

# Démarrer l'application
CMD ["npm", "start"]
