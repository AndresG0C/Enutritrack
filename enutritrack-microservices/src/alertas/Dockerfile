# --- ETAPA 1: Compilación ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
# 💡 Usamos el nombre real del microservicio: alertas
RUN npm run build -- alertas
RUN npm prune --production

# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# 💡 Exponemos los dos puertos reales que canta tu consola
EXPOSE 3009

# 💡 Apuntamos a la ruta exacta de compilación de alertas
CMD ["node", "dist/src/alertas/main.js"]