# --- ETAPA 1: Compilación ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
# 💡 Usamos el nombre real del microservicio: citas
RUN npm run build -- citas
RUN npm prune --production

# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Exponemos únicamente el puerto HTTP oficial de citas
EXPOSE 3008

CMD ["node", "dist/src/citas/main.js"]