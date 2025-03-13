# Utilisation d'une image Node.js pour le build
FROM node:22 as build

WORKDIR /app

# Copier et installer les dépendances
COPY package.json package-lock.json ./
RUN npm install

# Copier le reste des fichiers et build
COPY . .
RUN npm run build

# Copier les variables d'environnement
COPY .env .env

# Utilisation d'un serveur Nginx pour servir le frontend
FROM nginx:latest
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
