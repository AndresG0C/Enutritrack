# --- ETAPA 1: Compilación ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build -- doctors
RUN npm prune --production

# --- ETAPA 2: Ejecución ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Puerto interno (Por estándar suele ser el 3003)
EXPOSE 3003

CMD ["node", "dist/src/doctors/main.js"]