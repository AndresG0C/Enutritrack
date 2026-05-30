# --- ETAPA 1: Compilación ---
FROM node:20-alpine AS builder
WORKDIR /app

# Copiamos el package.json desde la raíz del monorrepo
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copiamos todo el monorrepo para que NestJS pueda resolver dependencias internas si las hay
COPY . .

# Compilamos específicamente el microservicio de Auth
# (NestJS por defecto compila a dist/src/auth/main.js o dist/auth/main.js)
RUN npm run build -- auth

# Limpiamos dependencias de desarrollo
RUN npm prune --production

# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Puerto interno del microservicio de Auth
EXPOSE 3001

CMD ["node", "dist/src/auth/main.js"]