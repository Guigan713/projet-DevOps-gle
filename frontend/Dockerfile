# Définit l'image de base Node.js version 23 (légère) et nomme ce stage "build"
FROM node:23-slim AS build

# Définit le répertoire de travail à /app dans le conteneur
WORKDIR /app

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

# Copier et installer les dépendances -> # Copie les fichiers package.json et package-lock.json dans le conteneur
COPY package*.json ./

# Installe toutes les dépendances Node.js définies dans package.json
RUN npm install

# Copie tous les fichiers du projet dans le conteneur
COPY . .

RUN npm run build

RUN echo "window._env_ = { API_URL: 'https://projet-devops-gle.fr/api' };" > build/env.js

# Crée un nouveau stage "production" basé sur le stage "build"
FROM nginx:alpine AS production

COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Installer 'serve' globalement pour servir la build statique
# RUN npm install -g serve && apt update && apt install -y curl && rm -rf /var/lib/apt/lists/

# Copier uniquement le build final, package.json et le lock
COPY --from=build /app/build /usr/share/nginx/html


EXPOSE 7000

# CMD ["serve", "-s", "build", "-l", "3000"]
CMD ["nginx", "-g", "daemon off;"]