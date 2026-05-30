# --- ETAPA 1: Compilación de TypeScript ---
# 💡 Cambiado a Node 20 para cumplir con los requerimientos de NestJS
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./

# 💡 Usamos npm install con legacy-peer-deps para evitar bloqueos por desincronización del lockfile
RUN npm install --legacy-peer-deps

COPY . .

# Compilar TypeScript a JavaScript nativo
RUN npm run build

# Eliminar las dependencias de desarrollo para ahorrar espacio
RUN npm prune --production


# --- ETAPA 2: Entorno de Ejecución Ligero ---
# 💡 Cambiado también a Node 20 aquí
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

EXPOSE 4000

CMD ["node", "dist/main.js"]