#!/bin/bash

# Script para iniciar todos los servicios de Enutritrack en GCP
# Uso: ./start-services.sh

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Obtener directorio del proyecto (asumiendo que el script está en la raíz)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Iniciando servicios de Enutritrack${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar Docker
echo -e "${YELLOW}1. Verificando Docker...${NC}"
if ! command_exists docker; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker no está corriendo. Inicia Docker primero.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker está corriendo${NC}"

# 2. Levantar Docker Compose
echo -e "${YELLOW}2. Levantando contenedores Docker (PostgreSQL, Couchbase, Redis)...${NC}"
cd "$PROJECT_ROOT/enutritrack-server"
docker-compose up -d
echo -e "${GREEN}✅ Contenedores iniciados${NC}"

# 3. Esperar a que PostgreSQL esté listo
echo -e "${YELLOW}3. Esperando a que PostgreSQL esté listo...${NC}"
for i in {1..30}; do
    if docker-compose exec -T postgres pg_isready -U postgres -d enutritrack >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ PostgreSQL no respondió después de 30 intentos${NC}"
        exit 1
    fi
    sleep 2
done

# 4. Verificar PM2
echo -e "${YELLOW}4. Verificando PM2...${NC}"
if ! command_exists pm2; then
    echo -e "${YELLOW}⚠️  PM2 no está instalado. Instalando...${NC}"
    sudo npm install -g pm2
fi
echo -e "${GREEN}✅ PM2 está disponible${NC}"

# 5. Detener servicios previos si existen
echo -e "${YELLOW}5. Deteniendo servicios previos (si existen)...${NC}"
pm2 delete all 2>/dev/null || true
echo -e "${GREEN}✅ Servicios previos detenidos${NC}"

# 6. Iniciar Backend (CMS)
echo -e "${YELLOW}6. Iniciando Backend (CMS)...${NC}"
cd "$PROJECT_ROOT/enutritrack-server"
pm2 start npm --name "enutritrack-backend" -- run start:dev
echo -e "${GREEN}✅ Backend iniciado${NC}"

# 7. Iniciar Microservicios
echo -e "${YELLOW}7. Iniciando Microservicios...${NC}"
cd "$PROJECT_ROOT/enutritrack-microservices"

# Gateway
pm2 start npm --name "enutritrack-gateway" -- run dev:gateway

# Auth
pm2 start npm --name "enutritrack-auth" -- run dev:auth

# User
pm2 start npm --name "enutritrack-user" -- run dev:user

# Doctor
pm2 start npm --name "enutritrack-doctor" -- run dev:doctor

# Nutrition
pm2 start npm --name "enutritrack-nutrition" -- run dev:nutrition

# Activity
pm2 start npm --name "enutritrack-activity" -- run dev:activity

# Recommendation
pm2 start npm --name "enutritrack-recommendation" -- run dev:recommendation

# Medical History
pm2 start npm --name "enutritrack-medical" -- run dev:medical

# Citas
pm2 start npm --name "enutritrack-citas" -- run dev:citas

# Alertas
pm2 start npm --name "enutritrack-alertas" -- run dev:alertas

echo -e "${GREEN}✅ Todos los microservicios iniciados${NC}"

# 8. Iniciar Frontend
echo -e "${YELLOW}8. Iniciando Frontend...${NC}"
cd "$PROJECT_ROOT/enutritrack-client"
pm2 start npm --name "enutritrack-frontend" -- run dev
echo -e "${GREEN}✅ Frontend iniciado${NC}"

# 9. Guardar configuración de PM2
echo -e "${YELLOW}9. Guardando configuración de PM2...${NC}"
pm2 save
echo -e "${GREEN}✅ Configuración guardada${NC}"

# 10. Mostrar estado
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ¡Todos los servicios iniciados correctamente!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📊 Estado de los servicios:${NC}"
pm2 status
echo ""
echo -e "${YELLOW}📝 Comandos útiles:${NC}"
echo "   Ver logs en tiempo real:  pm2 logs"
echo "   Ver logs de un servicio: pm2 logs enutritrack-backend"
echo "   Ver estado:              pm2 status"
echo "   Reiniciar todos:         pm2 restart all"
echo "   Detener todos:           pm2 stop all"
echo "   Eliminar todos:          pm2 delete all"
echo ""
echo -e "${YELLOW}🌐 URLs de acceso (reemplaza [IP_GCP] con tu IP):${NC}"
echo "   Frontend:  http://[IP_GCP]:5174"
echo "   CMS:       http://[IP_GCP]:4000/auth/login"
echo "   Swagger:   http://[IP_GCP]:4000/api/docs"
echo "   Couchbase: http://[IP_GCP]:8091"
echo ""

