# --- ETAPA 1: Compilación ---
FROM node:20-alpine AS builder
WORKDIR /app

# Copiamos el package.json global desde la raíz
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copiamos todo el monorrepo para compilar con contexto completo
COPY . .

# Compilamos específicamente el microservicio de Users
RUN npm run build -- users

# Limpiamos dependencias de desarrollo
RUN npm prune --production

# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Puerto interno del microservicio de Users (Por estándar suele ser el 3002)
EXPOSE 3002

CMD ["node", "dist/src/users/main.js"]