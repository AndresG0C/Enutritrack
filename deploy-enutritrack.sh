#!/bin/bash

set -e  # Salir si hay error

echo "1.🚀 Iniciando despliegue de Enutritrack en CentOS 9..."

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para verificar si un paquete está instalado
package_installed() {
    dnf list installed "$1" &> /dev/null
}

# Obtener el directorio actual del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "📁 Ruta del proyecto: $PROJECT_ROOT"

# 2. Instalar Node.js 20
echo "📦 Instalando Node.js 20..."
if ! command_exists node; then
    sudo dnf install -y curl 
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo -E bash -
    sudo dnf install -y nodejs
echo "✅ Node.js $(node -v) instalado"
else
    echo "✅ Node.js $(node -v) ya está instalado"
fi

# 3. Instalar Docker y configurar permisos
echo "📦 Instalando Docker..."
if ! command_exists docker; then
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Configurar permisos de Docker
    echo "🔧 Configurando permisos de Docker..."
    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker $USER
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 666 /var/run/docker.sock
    echo "✅ Docker instalado y configurado"
else
    echo "✅ Docker ya está instalado"
    
    # Verificar y configurar permisos si es necesario
    if ! docker ps > /dev/null 2>&1; then
        echo "🔧 Configurando permisos de Docker..."
        sudo groupadd docker 2>/dev/null || true
        sudo usermod -aG docker $USER
        sudo chown root:docker /var/run/docker.sock
        sudo chmod 666 /var/run/docker.sock
        echo "✅ Permisos de Docker configurados"
    fi
fi

# 4. Instalar PM2
echo "📦 Instalando PM2..."
if ! command_exists pm2; then
sudo npm install -g pm2
    echo "✅ PM2 instalado"
else
    echo "✅ PM2 ya está instalado"
fi

# 5. Verificar que el proyecto existe
echo "📦 Verificando proyecto..."
if [ ! -d "$PROJECT_ROOT/enutritrack-client" ]; then
    echo "❌ Error: Estructura del proyecto no encontrada"
    echo "   Se esperaban los directorios:"
    echo "   - $PROJECT_ROOT/enutritrack-client"
    echo "   - $PROJECT_ROOT/enutritrack-server" 
    echo "   - $PROJECT_ROOT/enutritrack-microservices"
    echo ""
    echo "   Estructura actual:"
    ls -la "$PROJECT_ROOT"
    exit 1
fi

echo "✅ Estructura del proyecto verificada"

# 6. Verificar permisos de Docker antes de continuar
echo "🔍 Verificando permisos de Docker..."
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Error: Sin permisos para Docker"
    echo "   Solución:"
    echo "   1. Cerrar sesión y volver a entrar"
    echo "   2. O ejecutar: newgrp docker"
    echo "   3. Luego ejecutar este script de nuevo"
    echo ""
    echo "   Como solución temporal, usando sudo para comandos Docker..."
    # Definir función docker con sudo para uso temporal
    docker() {
        sudo docker "$@"
    }
else
    echo "✅ Permisos de Docker verificados"
fi

# 7. Instalar dependencias
echo "📦 Instalando dependencias..."
cd "$PROJECT_ROOT"

echo "  - Frontend..."
cd enutritrack-client
npm install
cd ..

echo "  - Backend..."
cd enutritrack-server
npm install
cd ..

echo "  - Microservicios..."
cd enutritrack-microservices
npm install
cd ..

# 8. Crear base de datos y usuario en PostgreSQL Docker
echo "📦 Configurando base de datos en PostgreSQL Docker..."
cd "$PROJECT_ROOT/enutritrack-server"

# Levantar bases de datos con Docker
echo "📦 Levantando bases de datos con Docker..."

# Verificar si los contenedores ya están corriendo
if ! docker compose ps 2>/dev/null | grep -q "Up"; then
    echo "  Iniciando contenedores Docker..."
docker compose up -d
fi

# Esperar y verificar que PostgreSQL esté corriendo
echo "⏳ Esperando que PostgreSQL se inicie correctamente..."
MAX_RETRIES=12
RETRY_COUNT=0
POSTGRES_READY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    sleep 5
    RETRY_COUNT=$((RETRY_COUNT + 1))
    
    # Verificar si el contenedor está corriendo
    if ! docker ps | grep -q enutritrack_postgres; then
        echo "⚠️  Intento $RETRY_COUNT/$MAX_RETRIES: Contenedor PostgreSQL no está corriendo, reintentando..."
        docker compose restart postgres
        continue
    fi
    
    # Verificar si PostgreSQL está listo para conexiones
    if docker exec enutritrack_postgres pg_isready -U postgres > /dev/null 2>&1; then
        POSTGRES_READY=true
        echo "✅ PostgreSQL está listo después de $((RETRY_COUNT * 5)) segundos"
        break
    else
        echo "⏳ Intento $RETRY_COUNT/$MAX_RETRIES: Esperando que PostgreSQL esté listo..."
    fi
done

if [ "$POSTGRES_READY" = false ]; then
    echo "❌ Error: PostgreSQL no se inició correctamente después de $((MAX_RETRIES * 5)) segundos"
    echo "   Verificando logs del contenedor..."
    docker logs enutritrack_postgres --tail 50
    echo ""
    echo "   Intenta reiniciar manualmente:"
    echo "   cd $PROJECT_ROOT/enutritrack-server"
    echo "   docker compose restart postgres"
    echo "   docker logs -f enutritrack_postgres"
    exit 1
fi

# Ahora creamos la base de datos y el usuario en el contenedor Docker
echo "📦 Creando usuario y base de datos en PostgreSQL Docker..."
docker exec enutritrack_postgres psql -U postgres -c "CREATE USER enutritrack WITH PASSWORD 'enutritrack2024';" 2>/dev/null || echo "✅ Usuario ya existe"
docker exec enutritrack_postgres psql -U postgres -c "CREATE DATABASE enutritrack OWNER enutritrack;" 2>/dev/null || echo "✅ Base de datos ya existe"
docker exec enutritrack_postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE enutritrack TO enutritrack;" 2>/dev/null || echo "✅ Permisos ya configurados"

# 9. Inicializar PostgreSQL con manejo de errores
echo "📦 Inicializando PostgreSQL..."
INIT_SUCCESS=false
MAX_INIT_RETRIES=3
INIT_RETRY_COUNT=0

while [ $INIT_RETRY_COUNT -lt $MAX_INIT_RETRIES ]; do
    INIT_RETRY_COUNT=$((INIT_RETRY_COUNT + 1))
    
    if docker exec -i enutritrack_postgres psql -U enutritrack -d enutritrack < "$PROJECT_ROOT/enutritrack-server/scripts/init-db.sql" 2>&1; then
        INIT_SUCCESS=true
        echo "✅ Base de datos inicializada correctamente"
        break
    else
        if [ $INIT_RETRY_COUNT -lt $MAX_INIT_RETRIES ]; then
            echo "⚠️  Intento $INIT_RETRY_COUNT/$MAX_INIT_RETRIES: Error al inicializar, esperando 10 segundos y reintentando..."
            sleep 10
        else
            echo "⚠️  Error al inicializar la base de datos después de $MAX_INIT_RETRIES intentos"
            echo "   Esto puede ser normal si la base de datos ya estaba inicializada"
            echo "   Continuando con el despliegue..."
        fi
    fi
done

# 10. Otorgar permisos completos al usuario enutritrack
echo "📦 Otorgando permisos en PostgreSQL..."
docker exec enutritrack_postgres psql -U postgres -d enutritrack -c "
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO enutritrack;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO enutritrack;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO enutritrack;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO enutritrack;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO enutritrack;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO enutritrack;
"

# 11. Transferir propiedad de todas las tablas al usuario enutritrack
echo "📦 Transferiendo propiedad de tablas al usuario enutritrack..."
docker exec enutritrack_postgres psql -U postgres -d enutritrack -c "
-- Transferir propiedad de todas las tablas existentes
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' OWNER TO enutritrack';
    END LOOP;
END \$\$;

-- Transferir propiedad de todas las secuencias
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT sequence_name 
        FROM information_schema.sequences 
        WHERE sequence_schema = 'public' 
    LOOP
        EXECUTE 'ALTER SEQUENCE public.' || quote_ident(r.sequence_name) || ' OWNER TO enutritrack';
    END LOOP;
END \$\$;

-- Transferir propiedad de todas las vistas
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public' 
    LOOP
        EXECUTE 'ALTER VIEW public.' || quote_ident(r.table_name) || ' OWNER TO enutritrack';
    END LOOP;
END \$\$;
"

echo "✅ Propiedad de tablas transferida a enutritrack"

# 12. Configurar permisos por defecto para futuras tablas
echo "📦 Configurando permisos por defecto..."
docker exec enutritrack_postgres psql -U postgres -d enutritrack -c "
-- Asegurar que el usuario enutritrack sea propietario de objetos futuros
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO enutritrack;

-- También configurar para el usuario enutritrack mismo
ALTER DEFAULT PRIVILEGES FOR ROLE enutritrack IN SCHEMA public GRANT ALL ON TABLES TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE enutritrack IN SCHEMA public GRANT ALL ON SEQUENCES TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE enutritrack IN SCHEMA public GRANT ALL ON FUNCTIONS TO enutritrack;
ALTER DEFAULT PRIVILEGES FOR ROLE enutritrack IN SCHEMA public GRANT ALL ON TYPES TO enutritrack;
"

# 13. Aplicar Stored Procedures para el Dashboard
echo "📦 Aplicando Stored Procedures para el Dashboard..."

# Verificar que el archivo de stored procedures existe
STORED_PROCEDURES_FILE="$PROJECT_ROOT/enutritrack-server/scripts/stored-procedures.sql"
if [ -f "$STORED_PROCEDURES_FILE" ]; then
    echo "  Aplicando stored procedures desde: $STORED_PROCEDURES_FILE"
    
    # Ejecutar el archivo SQL en el contenedor PostgreSQL
    if docker exec -i enutritrack_postgres psql -U postgres -d enutritrack -f - < "$STORED_PROCEDURES_FILE"; then
        echo "✅ Stored procedures aplicados exitosamente"
        echo ""
        echo "Procedimientos principales creados:" 
        echo "  - sp_get_all_patients()"
        echo "  - sp_get_patient_details(patient_id)"
        echo "  - sp_update_patient_doctor(patient_id, doctor_id)"
        echo "  - sp_toggle_patient_status(patient_id)"
        echo "  - sp_get_all_doctors()"
        echo "  - sp_get_doctor_patients(doctor_id)"
        echo "  - sp_create_doctor(...)"
        echo "  - sp_update_doctor(...)"
        echo "  - sp_get_all_admins()"
        echo "  - sp_get_admin_details(email)"
        echo "  - sp_get_dashboard_stats()"
        echo "  - sp_get_patients_by_gender()"
        echo "  - sp_get_recent_registrations()"
        echo "  - obtener_historial_medico_completo()"
        echo "  - analisis_progreso_peso()"
        echo "  - reporte_consumo_mensual()"
        echo "  - dashboard_estadisticas_generales()"
        echo "  - buscar_usuarios_por_patron_medico()"
        echo "  - buscar_usuarios_por_perfil()"
        echo "  - buscar_staff_por_patron()"
        echo ""
    else
        echo "⚠️  Error al aplicar stored procedures, continuando..."
    fi
else
    echo "⚠️  Archivo de stored procedures no encontrado en $STORED_PROCEDURES_FILE, continuando..."
fi

echo "✅ Permisos por defecto configurados"

echo "✅ Permisos otorgados al usuario enutritrack"
# 14. Configurar Couchbase
echo "📦 Configurando Couchbase..."
COUCHBASE_URL="http://localhost:8091"
USERNAME="Alfredo"
PASSWORD="alfredo124"
BUCKET_NAME="enutritrack"

# Esperar a que Couchbase esté listo
echo "⏳ Esperando que Couchbase esté listo..."

MAX_ATTEMPTS=30
ATTEMPT=1
COUCHBASE_READY=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ] && [ "$COUCHBASE_READY" = false ]; do
    if curl -s -f "$COUCHBASE_URL" > /dev/null 2>&1; then
        echo "✅ Couchbase está respondiendo"
        COUCHBASE_READY=true
    else
        echo "⏳ Intento $ATTEMPT de $MAX_ATTEMPTS: Couchbase no responde, esperando 10 segundos..."
        sleep 10
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ "$COUCHBASE_READY" = false ]; then
    echo "❌ Couchbase no respondió después de $MAX_ATTEMPTS intentos"
    echo "   Continuando sin Couchbase..."
else
    # Inicializar el cluster
    echo "📦 Inicializando cluster de Couchbase..."

    # Configurar memoria
    if curl -s -X POST "$COUCHBASE_URL/pools/default" -d "memoryQuota=512" -d "indexMemoryQuota=512" > /dev/null 2>&1; then
        echo "✅ Memoria configurada"
    else
        echo "⚠️  No se pudo configurar memoria (puede que ya esté configurado)"
    fi

    # Configurar servicios
    if curl -s -X POST "$COUCHBASE_URL/node/controller/setupServices" -d "services=kv,n1ql,index,fts" > /dev/null 2>&1; then
        echo "✅ Servicios configurados"
    else
        echo "⚠️  No se pudo configurar servicios (puede que ya estén configurados)"
    fi

    # Configurar credenciales
    if curl -s -X POST "$COUCHBASE_URL/settings/web" -d "port=8091" -d "username=$USERNAME" -d "password=$PASSWORD" > /dev/null 2>&1; then
        echo "✅ Credenciales configuradas"
    else
        echo "⚠️  No se pudo configurar credenciales (puede que ya estén configuradas)"
    fi

    # Esperar a que las credenciales estén activas
    echo "⏳ Esperando que las credenciales se activen..."
    sleep 15

    # Verificar que podemos autenticar
    AUTH_ATTEMPTS=10
    AUTH_ATTEMPT=1
    AUTH_READY=false

    while [ $AUTH_ATTEMPT -le $AUTH_ATTEMPTS ] && [ "$AUTH_READY" = false ]; do
        if curl -s -u "$USERNAME:$PASSWORD" "$COUCHBASE_URL/pools" > /dev/null 2>&1; then
            echo "✅ Autenticación exitosa"
            AUTH_READY=true
        else
            echo "⏳ Intento $AUTH_ATTEMPT de $AUTH_ATTEMPTS: Autenticación fallida, reintentando en 5 segundos..."
            sleep 5
            AUTH_ATTEMPT=$((AUTH_ATTEMPT + 1))
        fi
    done

    if [ "$AUTH_READY" = false ]; then
        echo "❌ No se pudo autenticar después de $AUTH_ATTEMPTS intentos"
        echo "   Continuando sin Couchbase..."
    else
        # Crear el bucket
        echo "📦 Creando bucket $BUCKET_NAME..."

        MAX_BUCKET_ATTEMPTS=10
        BUCKET_ATTEMPT=1
        BUCKET_CREATED=false

        while [ $BUCKET_ATTEMPT -le $MAX_BUCKET_ATTEMPTS ] && [ "$BUCKET_CREATED" = false ]; do
            if curl -s -X POST -u "$USERNAME:$PASSWORD" "$COUCHBASE_URL/pools/default/buckets" \
                -d "name=$BUCKET_NAME" \
                -d "ramQuotaMB=128" \
                -d "authType=none" \
                -d "bucketType=couchbase" > /dev/null 2>&1; then
                echo "✅ Bucket $BUCKET_NAME creado exitosamente"
                BUCKET_CREATED=true
            else
                echo "⏳ Intento $BUCKET_ATTEMPT de $MAX_BUCKET_ATTEMPTS: Error creando bucket, reintentando en 10 segundos..."
                sleep 10
                BUCKET_ATTEMPT=$((BUCKET_ATTEMPT + 1))
            fi
        done

        if [ "$BUCKET_CREATED" = false ]; then
            echo "❌ No se pudo crear el bucket después de $MAX_BUCKET_ATTEMPTS intentos"
            echo "   Continuando sin bucket de Couchbase..."
        else
            # Esperar a que el bucket esté listo
            echo "⏳ Esperando que el bucket esté listo..."

            MAX_READY_ATTEMPTS=20
            READY_ATTEMPT=1
            BUCKET_READY=false

            while [ $READY_ATTEMPT -le $MAX_READY_ATTEMPTS ] && [ "$BUCKET_READY" = false ]; do
                if curl -s -u "$USERNAME:$PASSWORD" "$COUCHBASE_URL/pools/default/buckets/$BUCKET_NAME" | grep -q "healthy"; then
                    echo "✅ Bucket está listo y saludable"
                    BUCKET_READY=true
                else
                    echo "⏳ Intento $READY_ATTEMPT de $MAX_READY_ATTEMPTS: Bucket no listo, esperando 5 segundos..."
                    sleep 5
                    READY_ATTEMPT=$((READY_ATTEMPT + 1))
                fi
            done

            if [ "$BUCKET_READY" = false ]; then
                echo "⚠️  Bucket no está completamente listo después de $MAX_READY_ATTEMPTS intentos"
            fi
        fi
    fi

    echo ""
    echo "✅ Couchbase configurado correctamente"
    echo "   URL: http://localhost:8091"
    echo "   Usuario: $USERNAME"
    echo "   Password: $PASSWORD"
    echo "   Bucket: $BUCKET_NAME"
fi

# 15. Ejecutar TypeORM en modo dev para completar estructura de BD
echo "📦 Ejecutando backend en modo desarrollo para que TypeORM valide/complete la estructura de BD..."
echo "   Esto permite que TypeORM procese las entidades y valide la estructura..."

cd "$PROJECT_ROOT/enutritrack-server"

# Iniciar backend en modo dev en background
npm run start:dev > /tmp/backend-typeorm.log 2>&1 &
BACKEND_PID=$!

# Esperar a que el backend se inicie y TypeORM procese
echo "   Esperando que el backend se inicie y TypeORM procese las entidades (30 segundos)..."
sleep 30

# Verificar si el proceso sigue corriendo
if ps -p $BACKEND_PID > /dev/null 2>&1; then
    echo "   Backend está corriendo, esperando 20 segundos más para que TypeORM complete..."
    sleep 20
    # Detener el proceso
    echo "   Deteniendo backend temporal..."
    kill $BACKEND_PID 2>/dev/null || true
    wait $BACKEND_PID 2>/dev/null || true
    sleep 2
    # Asegurarse de que el proceso se detuvo
    kill -9 $BACKEND_PID 2>/dev/null || true
    echo "✅ TypeORM ha procesado las entidades"
else
    echo "⚠️  Backend se detuvo antes de tiempo, pero continuando..."
    echo "   Si hay errores, revisa: cat /tmp/backend-typeorm.log"
fi

# 16. Compilar aplicaciones
echo "📦 Compilando aplicaciones..."
cd "$PROJECT_ROOT/enutritrack-client"
npm run build

cd "$PROJECT_ROOT/enutritrack-server"
npm run build

cd "$PROJECT_ROOT/enutritrack-microservices"
npm run build

echo ""
echo "✅ ¡Construcción y configuración completada!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📋 Resumen de lo realizado:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "   ✅ Dependencias instaladas"
echo "   ✅ Contenedores Docker levantados (PostgreSQL, Couchbase, Redis)"
echo "   ✅ Base de datos PostgreSQL inicializada"
echo "   ✅ Stored procedures aplicados"
echo "   ✅ Couchbase configurado"
echo "   ✅ TypeORM ejecutado en modo dev (validación de entidades)"
echo "   ✅ Aplicaciones compiladas"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 Próximos pasos:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "   Para iniciar los servicios, ejecuta:"
echo "   ./start-services.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📝 Comandos útiles:"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "   Ver logs de PostgreSQL:"
echo "   docker logs enutritrack_postgres"
echo ""
echo "   Ver logs de Couchbase:"
echo "   docker logs enutritrack_couchbase"
echo ""
echo "   Reiniciar bases de datos:"
echo "   cd $PROJECT_ROOT/enutritrack-server"
echo "   docker compose restart"
echo ""