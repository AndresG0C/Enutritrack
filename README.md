# Enutritrack 🍏💪

![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Couchbase](https://img.shields.io/badge/Couchbase-EA2328?style=for-the-badge&logo=couchbase&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

**Enutritrack** es una plataforma integral de salud preventiva que utiliza inteligencia artificial para proporcionar planes de nutrición personalizados y seguimiento de actividad física.

## ✨ Características Principales

### 🍎 Gestión Nutricional Avanzada

- **Registro de alimentos** con base de datos completa
- **Seguimiento calórico** y de macronutrientes
- **Planes alimenticios** personalizados por IA
- **Recomendaciones inteligentes** basadas en objetivos

### 🏃‍♂️ Monitoreo de Actividad Física

- **Registro de ejercicios** y actividades
- **Cálculo de calorías** quemadas

### 👤 Perfiles Personalizados

- **Historial médico completo**
- **Objetivos personalizados** de salud
- **Preferencias alimenticias** y restricciones
- **Seguimiento de evolución** de peso y medidas

### 📊 Analytics y Reportes

- **Dashboards interactivos** con métricas de salud
- **Reportes personalizados** exportables
- **Análisis predictivo** de progreso
- **Segmentación** de usuarios por perfiles

## 🏗️ Arquitectura del Sistema

### Bases de Datos

- **PostgreSQL**: Datos transaccionales y relaciones complejas https://www.postgresql.org/download/
- **Couchbase**: Documentos JSON y perfiles de usuarios
- **Redis**: Caché, sesiones y colas de mensajes

## 🚀 Guía de Inicio Rápido

### Prerrequisitos

- **Node.js** 18+ ([Descargar](https://nodejs.org/))
- **Docker Desktop** ([Descargar](https://www.docker.com/products/docker-desktop))
- **Git**

Descarga la última versión LTS desde la página oficial:
👉 https://nodejs.org/

Verifica la instalación:
Verifica las instalaciones:

```bash
node -v
npm -v
docker --version
docker-compose --version
```

Verifica:
nest --version

### Paso a Paso - Primera Configuración

- **Docker** y **Docker Compose** - deberia dejar abierto DOCKER
- **npm (para la instalacion de dependencias)**
- **VSCODE**

#### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/AlfredoPerez73/enutritrack.git
cd enutritrack
```

#### 2️⃣ Instalar Dependencias

```powershell
# Frontend
cd enutritrack-client
npm install

# Backend
cd ../enutritrack-server
npm install

# Microservicios
cd ../enutritrack-microservices
npm install

# Volver a la raíz
cd ..
```

#### 3️⃣ Levantar Bases de Datos con Docker

```powershell
cd enutritrack-server
docker-compose up -d
```

Espera 30-60 segundos para que los servicios se inicialicen completamente.

#### 4️⃣ Configurar Couchbase

1. Abre `http://localhost:8091`
2. Configura el cluster:
   - Username: `Alfredo`
   - Password: `alfredo124` (sin caracteres especiales)
3. Crea el bucket:
   - Name: `enutritrack`
   - Bucket Type: Couchbase
4. En Query Workbench, ejecuta:
   ```sql
   CREATE PRIMARY INDEX ON `enutritrack`;
   ```

#### 5️⃣ Inicializar Base de Datos PostgreSQL

**Opción A: Con pgAdmin**

1. Conecta a PostgreSQL (`localhost:5433`, user: `enutritrack`, password: `enutritrack2024`)
2. Abre y ejecuta `enutritrack-server/scripts/init-db.sql`

**Opción B: Con psql (si está en PATH)**

```bash
psql -U enutritrack -d enutritrack -p 5433 -f scripts/init-db.sql
```

Esto crea:

- Todas las tablas del sistema
- El primer superusuario con credenciales:
  - Email: `admin@enutritrack.com`
  - Password: `admin123`

#### 6️⃣ Aplicar Stored Procedures para Dashboard

```powershell
cd scripts
.\apply-stored-procedures.ps1
```

O manualmente con pgAdmin ejecutando `scripts/stored-procedures.sql`

#### 7️⃣ Iniciar Servicios

> **⚠️ IMPORTANTE - App Móvil:** Antes de iniciar los servicios, verifica que en el archivo `enutritrack-app/Enutritrackapp/app/src/main/java/com/example/enutritrack_app/config/ApiConfig.kt` la configuración esté en modo desarrollo local:
>
> - `USE_PRODUCTION = false` (para usar localhost)
> - `PROD_IP = "[TU_IP_GCP]"` (no importa el valor si USE_PRODUCTION es false)

**Opción A: Script automatizado para Windows (Recomendado)**

```powershell
# Desde la raíz del proyecto
.\start-services.ps1
```

El script automáticamente abre 10 ventanas de PowerShell, una para cada servicio.

**Opción B: Manualmente (10 terminales)**

Abre **10 terminales** y ejecuta en cada una:

```powershell
# Terminal 1 - Backend
cd enutritrack-server
npm run start:dev

# Terminal 2 - Gateway de Microservicios
cd enutritrack-microservices
npm run dev:gateway

# Terminal 3 - Microservicio de Auth
cd enutritrack-microservices
npm run dev:auth

# Terminal 4 - Microservicio de Usuarios
cd enutritrack-microservices
npm run dev:user

# Terminal 5 - Microservicio de Doctores
cd enutritrack-microservices
npm run dev:doctor

# Terminal 6 - Microservicio de Nutrición
cd enutritrack-microservices
npm run dev:nutrition

# Terminal 7 - Microservicio de Actividad
cd enutritrack-microservices
npm run dev:activity

# Terminal 8 - Microservicio de Recomendaciones
cd enutritrack-microservices
npm run dev:recommendation

# Terminal 9 - Microservicio de Historial Médico
cd enutritrack-microservices
npm run dev:medical

# Terminal 10 - Frontend
cd enutritrack-client
npm run dev
```

#### 8️⃣ Acceder a las Aplicaciones

**Dashboard de Superusuario (Backend)**

- URL: `http://localhost:4000/auth/login`
- Email: `admin@enutritrack.com`
- Password: `admin123`
- Funcionalidades:
  - 📊 Gestión de pacientes (ver detalles completos, asignar doctor, activar/desactivar)
  - 👨‍⚕️ Gestión de doctores (crear nuevos, ver pacientes asignados)
  - 🔐 Gestión de administradores
  - 📈 Estadísticas del sistema en tiempo real
  - ⚡ Acceso directo a BD mediante stored procedures

**Aplicación de Doctores (Frontend)**

- URL: `http://localhost:5174`
- Credenciales: Crear doctor desde el dashboard de superusuario primero

**Documentación API**

- Swagger: `http://localhost:4000/api/docs`

## ☁️ Despliegue en Google Cloud Platform (GCP)

### Prerrequisitos

- **Cuenta de Google Cloud Platform** con facturación habilitada
- **Proyecto comprimido (ZIP)** del repositorio
- **Acceso SSH** a la VM de GCP

### Paso a Paso - Despliegue en GCP

#### 1️⃣ Crear Instancia VM en GCP

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Navega a **Compute Engine** > **VM instances**
3. Crea una nueva instancia con:
   - **Nombre**: `enutritrack-vm`
   - **Región**: La más cercana a tu ubicación
   - **Tipo de máquina**: `e2-standard-4` (4 vCPU, 16 GB RAM)
   - **Boot disk**: Ubuntu 22.04 LTS, 50 GB SSD
   - **Firewall**: Marca "Allow HTTP traffic" y "Allow HTTPS traffic"
4. Haz clic en **Create**

#### 2️⃣ Configurar Firewall en GCP

En la consola de GCP, crea una regla de firewall:

1. Ve a **VPC network** > **Firewall**
2. Crea regla de firewall:
   - **Nombre**: `allow-enutritrack`
   - **Dirección**: Entrada
   - **Acción**: Permitir
   - **Destinos**: Todas las instancias en la red
   - **Filtros**: `0.0.0.0/0`
   - **Protocolos y puertos**: `TCP: 3001-3009, 4000, 5174, 8091`
3. Guarda la regla

O desde la línea de comandos:

```bash
gcloud compute firewall-rules create allow-enutritrack \
    --allow tcp:3001-3009,tcp:4000,tcp:5174,tcp:8091 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow traffic for Enutritrack services"
```

#### 3️⃣ Subir Proyecto a la VM

1. **Comprime el proyecto** en un archivo ZIP (incluye todas las carpetas: `enutritrack-client`, `enutritrack-server`, `enutritrack-microservices`, `enutritrack-app`)

2. **Sube el ZIP a la VM** usando uno de estos métodos o alternativamente conectar por github y traer el proyecto directo a la VM:

   **Opción A: Desde la consola de GCP (recomendado)**

   - En la VM, haz clic en **SSH** para abrir la terminal
   - En tu máquina local, usa `gcloud compute scp`:
     ```bash
     gcloud compute scp proyecto.zip enutritrack-vm:/tmp/ --zone=tu-zona
     ```

   **Opción B: Usando SCP**

   ```bash
   scp proyecto.zip usuario@IP_VM:/tmp/
   ```

3. **Extrae el proyecto en la VM**:
   ```bash
   sudo mkdir -p /opt/enutritrack
   sudo unzip /tmp/proyecto.zip -d /opt/
   sudo chown -R $USER:$USER /opt/enutritrack
   ```

#### 4️⃣ Ejecutar Scripts de Despliegue

1. **Sube los scripts de despliegue** a la VM:

   ```bash
   gcloud compute scp deploy-enutritrack.sh start-services.sh enutritrack-vm:/tmp/ --zone=tu-zona
   ```

2. **Conecta a la VM por SSH**:

   ```bash
   gcloud compute ssh enutritrack-vm --zone=tu-zona
   ```

3. **Mueve los scripts al directorio del proyecto**:

   ```bash
   cd /opt/enutritrack
   sudo mv /tmp/deploy-enutritrack.sh /tmp/start-services.sh .
   sudo chmod +x deploy-enutritrack.sh start-services.sh
   ```

4. **Ejecuta el script de construcción**:

   ```bash
   ./deploy-enutritrack.sh
   ```

   Este script:
   - Instala todas las dependencias (Node.js, Docker, PM2)
   - Levanta las bases de datos (PostgreSQL, Couchbase, Redis)
   - Inicializa la base de datos PostgreSQL
   - Aplica stored procedures
   - Configura Couchbase
   - Ejecuta TypeORM en modo dev para validar entidades
   - Compila todas las aplicaciones

5. **Inicia los servicios**:

   ```bash
   ./start-services.sh
   ```

   Este script:
   - Verifica que Docker esté corriendo
   - Levanta los contenedores si no están corriendo
   - Inicia todos los servicios con PM2 (backend, microservicios, frontend)

   Alternativamente se puede abrir distitnas terminales de SSH y abrir cada una individual como mencionado en deploy local

#### 5️⃣ Obtener IP Externa de la VM

En la consola de GCP, ve a **Compute Engine** > **VM instances** y copia la **IP externa** de tu VM.

O desde la terminal:

```bash
gcloud compute instances describe enutritrack-vm --zone=tu-zona --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

#### 6️⃣ Acceder a las Aplicaciones

Una vez completado el despliegue, accede a:

**Portal de Doctores (Frontend)**

- URL: `http://[IP_EXTERNA_DE_LA_VM]:5174/`
- Ejemplo: `http://34.123.45.67:5174/`

**CMS/Dashboard de Administrador**

- URL: `http://[IP_EXTERNA_DE_LA_VM]:4000/auth/login`
- Credenciales: `admin@enutritrack.com` / `admin123`

**Documentación API (Swagger)**

- URL: `http://[IP_EXTERNA_DE_LA_VM]:4000/api/docs`

**Microservicios (acceso directo)**

- Auth: `http://[IP_EXTERNA_DE_LA_VM]:3004`
- Users: `http://[IP_EXTERNA_DE_LA_VM]:3001`
- Medical: `http://[IP_EXTERNA_DE_LA_VM]:3002`
- Nutrition: `http://[IP_EXTERNA_DE_LA_VM]:3003`
- Activity: `http://[IP_EXTERNA_DE_LA_VM]:3005`
- Recommendation: `http://[IP_EXTERNA_DE_LA_VM]:3006`
- Doctors: `http://[IP_EXTERNA_DE_LA_VM]:3007`
- Citas: `http://[IP_EXTERNA_DE_LA_VM]:3008`
- Alertas: `http://[IP_EXTERNA_DE_LA_VM]:3009`

**Consola Couchbase**

- URL: `http://[IP_EXTERNA_DE_LA_VM]:8091`
- Usuario: `Alfredo`
- Password: `alfredo124`

#### 7️⃣ Configurar App Móvil para GCP

Para que la app móvil funcione con el despliegue en GCP:

1. Abre Android Studio
2. Abre el archivo:
   ```
   enutritrack-app/Enutritrackapp/app/src/main/java/com/example/enutritrack_app/config/ApiConfig.kt
   ```
3. Cambia estas dos líneas:
   ```kotlin
   private const val PROD_IP = "34.123.45.67"  // Reemplaza con tu IP de GCP
   private const val USE_PRODUCTION = true    // Cambiar a true
   ```
4. Recompila la app: **Build** > **Rebuild Project**
5. Instala el APK en tu dispositivo

### Comandos Útiles en GCP

```bash
# Ver logs de los servicios
pm2 logs

# Ver estado de servicios
pm2 status

# Reiniciar servicios
pm2 restart all

# Ver logs de PostgreSQL
docker logs enutritrack_postgres

# Reiniciar bases de datos
cd /opt/enutritrack/enutritrack-server
docker compose restart

# Ver IP externa de la VM
curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"
```

### Troubleshooting en GCP

#### PostgreSQL no inicia correctamente

El script tiene manejo automático de errores con reintentos. Si aún falla:

```bash
cd /opt/enutritrack/enutritrack-server
docker compose logs postgres
docker compose restart postgres
```

#### Los servicios no responden

```bash
# Verificar que PM2 esté corriendo
pm2 status

# Ver logs de errores
pm2 logs --err

# Reiniciar todos los servicios
pm2 restart all
```

#### Los servicios no inician con PM2

```bash
# Verificar que PM2 esté instalado
pm2 --version

# Ver logs detallados
pm2 logs --lines 100

# Reiniciar todos los servicios
pm2 restart all

# Si hay problemas, eliminar y volver a iniciar
pm2 delete all
./start-services.sh
```

## 📁 Estructura del Proyecto

```
Cliente (enutritrack-client)
enutritrack/enutritrack-client/src/
├── api/
├── components/
├── context/
├── css/
├── hooks/
├── pages/
├── routes/
├── App.jsx
├── ProtectedRoutes.jsx
└── main.jsx
Microservicios (enutritrack-microservices)
enutritrack/enutritrack-microservices/src/
├── activity/
├── auth/
├── medical-history/
├── nutrition/
├── doctor/
├── recommendation/
├── users/
├── app.module.ts
└── main.ts
Servidor (enutritrack-server)
enutritrack/enutritrack-server/src/
├── activity/
├── auth/
├── couchbase/
├── medical-history/
├── doctor/
├── nutrition/
├── recommendation/
├── redis/
├── test/
├── users/
├── app.module.ts
└── main.ts
```

## 🔧 Configuración

### Puertos de los Servicios

| Servicio                          | Puerto | Descripción                                |
| --------------------------------- | ------ | ------------------------------------------ |
| BACKEND                           | 4000   | Punto de entrada principal                 |
| MICROSERVICIOS MAIN               | 3000   | MAIN Principal                             |
| MICROSERVICIOS USUARIO            | 3001   | Gestion de usuario                         |
| MICROSERVICIOS HISTORIAL MEDICO   | 3002   | Gestion de historial medico                |
| MICROSERVICIOS NUTRICION          | 3003   | Gestion de registro de comida              |
| MICROSERVICIOS AUTENTICACION      | 3004   | Autorizacion y validacion de usuario       |
| MICROSERVICIOS ACTIVIDAD FISICA   | 3005   | Gestion de actividades fiscias del usuario |
| MICROSERVICIOS RECOMENDACIONES IA | 3006   | Gestion de recomendaciones hechas por IA   |
| MICROSERVICIOS DOCTORES           | 3007   | Microservicio para los doctores            |
| MICROSERVICIOS CITAS              | 3008   | Gestión de citas médicas                   |
| MICROSERVICIOS ALERTAS           | 3009   | Gestión de alertas del sistema             |
| FRONTEND                          | 5174   | Portal de doctores (Vite dev server)        |
| COUCHBASE                         | 8091   | Consola web de Couchbase                    |

## 🔧 Troubleshooting

### Problemas Comunes y Soluciones

#### Error de conexión a Couchbase

```bash
# Reinicia el contenedor
docker-compose restart couchbase

# Verifica que las credenciales sean correctas:
# Username: Alfredo (con mayúscula inicial)
# Password: alfredo124 (sin caracteres especiales)
```

#### Error de conexión a PostgreSQL

```bash
# Reinicia el contenedor
docker-compose restart postgres

# Verifica que el puerto 5433 esté disponible
# Credenciales: enutritrack / enutritrack2024
```

#### Error de conexión a Redis

```bash
docker-compose restart redis
```

#### El backend no arranca - Error con stored procedures

Asegúrate de haber ejecutado:

```powershell
cd enutritrack-server/scripts
.\apply-stored-procedures.ps1
```

#### No puedo acceder al dashboard de superusuario

1. Verifica que el backend esté corriendo en `http://localhost:4000`
2. Verifica que el superusuario exista en la base de datos:
   ```sql
   SELECT * FROM cuentas WHERE email = 'admin@enutritrack.com';
   ```
3. Si no existe, ejecuta `scripts/init-db.sql` o `scripts/create-admin.ps1`

#### Error 401 en el frontend

Borra las cookies y vuelve a hacer login. El token JWT puede haber expirado.

### Crear Superusuario Adicional

Si necesitas crear otro administrador manualmente:

```powershell
cd enutritrack-server/scripts
.\create-admin.ps1
```

O ejecuta directamente en PostgreSQL:

```sql
-- 1. Crear cuenta
INSERT INTO cuentas (email, password_hash, tipo_cuenta, activa)
VALUES ('nuevoadmin@example.com', crypt('password123', gen_salt('bf')), 'admin', TRUE)
RETURNING id;

-- 2. Crear perfil de admin (usa el id de arriba)
INSERT INTO perfil_admin (cuenta_id, nombre)
VALUES ('uuid-de-cuenta-aqui', 'Nombre del Admin');
```

### Verificar Estado de Servicios

```powershell
# Ver contenedores Docker activos
docker ps

# Ver logs de un contenedor específico
docker logs enutritrack_postgres
docker logs enutritrack_couchbase
docker logs enutritrack_redis
```

## 🏆 Equipo

- **Alfredo José** - Project Manager
- **Contribuidores**
  -- **Juan Carmona**
  -- **Andres Gonzalez**
  -- **Angel Muñoz**
