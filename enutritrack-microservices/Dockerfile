# --- ETAPA 1: Compilación del Gateway ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .

# Compilar el Gateway (NestJS compilará el main.ts de la raíz)
RUN npm run build

# Limpiar dependencias de desarrollo
RUN npm prune --production


# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# El Gateway suele exponer el puerto 3000 para recibir todo el tráfico externo
EXPOSE 3000

CMD ["node", "dist/main.js"]