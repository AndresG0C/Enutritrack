# --- ETAPA 1: Compilación del Frontend ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./

# Usamos npm install flexible para evitar conflictos de versiones en el lockfile
RUN npm install --legacy-peer-deps

COPY . .

# Compilar la aplicación (Vite generará los archivos estáticos en la carpeta /dist)
RUN npm run build


# --- ETAPA 2: Servidor Web Nginx ---
FROM nginx:1.25-alpine AS runner

# Copiar los archivos estáticos desde la etapa de compilación a Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar nuestra configuración personalizada para evitar errores 404 al recargar rutas
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]