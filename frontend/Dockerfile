# Utilisation d'une image Node.js pour le build
FROM node:23-slim AS base

WORKDIR /app

# Copier et installer les dépendances
COPY package*.json ./

RUN npm install

# Copier le reste des fichiers et build
COPY . .

FROM base AS build

RUN npm run build

# Copier les variables d'environnement
COPY .env .env

# Utilisation d'un serveur Nginx pour servir le frontend
FROM nginx:alpine AS production

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
