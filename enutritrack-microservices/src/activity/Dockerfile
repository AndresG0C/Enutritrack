# --- BUILD STAGE ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .

# Compilar todo (esto genera dist/ con todos los microservicios)
RUN npm run build

# --- RUN STAGE ---
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

EXPOSE 3005

# Ejecutar SOLO el microservicio de activity
CMD ["node", "dist/activity/main.js"]
