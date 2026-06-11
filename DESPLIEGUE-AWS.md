# Enutritrack - Guía de Despliegue en AWS

Guía completa para desplegar el proyecto Enutritrack (plataforma de nutrición basada en IA con arquitectura de microservicios) en AWS.

---

## ⚠️ Requisitos Previos

**IMPORTANTE:** Antes de comenzar, asegúrate de tener **Docker Desktop ejecutándose** en tu máquina local. Todos los pasos que involucren construcción de imágenes Docker requieren que Docker Desktop esté activo.

```bash
# Verificar que Docker está corriendo
docker --version
docker ps
```

Si Docker no está iniciado, inicia Docker Desktop desde tu sistema operativo.

---

## Tabla de Contenidos

1. [Configuración de Entorno](#configuración-de-entorno)
2. [Construcción de Imágenes Docker](#construcción-de-imágenes-docker)
3. [Despliegue con Terraform](#despliegue-con-terraform)
4. [Configuración del Frontend](#configuración-del-frontend)
5. [Subida de Imágenes a AWS](#subida-de-imágenes-a-aws)
6. [Inicialización de Base de Datos](#inicialización-de-base-de-datos)
7. [Reconstrucción de Servicios ECS](#reconstrucción-de-servicios-ecs)
8. [Verificación y Pruebas](#verificación-y-pruebas)
9. [Pruebas de la App Móvil](#pruebas-de-la-app-móvil)

---

## Configuración de Entorno

### Paso 1: Configurar AWS CLI

Asegúrate de tener AWS CLI instalado y configurado con tus credenciales:

```bash
aws configure
```

Deberás proporcionar:
- AWS Access Key ID
- AWS Secret Access Key
- Región predeterminada (ej: us-east-1)
- Formato de salida (json)

### Paso 2: Configurar upload-all.ps1

Edita el archivo `upload-all.ps1` y actualiza la variable `$ACCOUNT` con tu ID de cuenta de AWS:

```powershell
$ACCOUNT = "YOUR_AWS_ACCOUNT_ID"
```

### Paso 3: Configurar Terraform Variables

Edita el archivo `terraform.tfvars` y asigna tu API key de Gemini:

```hcl
gemini_api_key = "your-gemini-api-key-here"
```

---

## Construcción de Imágenes Docker

### Paso 4: Crear Imágenes Docker

Sigue la nomenclatura exacta para crear todas las imágenes de Docker necesarias.

#### Backend CMS

```bash
cd enutritrack-server
docker build -t enutritrack-server-cms:latest .
```

#### Microservicios

Navega a la carpeta de microservicios y crea las imágenes para cada servicio:

```bash
cd enutritrack-microservices

# Servicio de Autenticación
docker build -f src/auth/Dockerfile -t enutritrack-microservices-auth:latest .

# Servicio de Usuarios
docker build -f src/users/Dockerfile -t enutritrack-microservices-users:latest .

# Servicio de Doctor
docker build -f src/doctor/Dockerfile -t enutritrack-microservices-doctor:latest .

# Servicio de Nutrición
docker build -f src/nutrition/Dockerfile -t enutritrack-microservices-nutrition:latest .

# Servicio de Actividad
docker build -f src/activity/Dockerfile -t enutritrack-microservices-activity:latest .

# Servicio de Recomendaciones
docker build -f src/recommendation/Dockerfile -t enutritrack-microservices-recommendation:latest .

# Servicio de Historial Médico
docker build -f src/medical-history/Dockerfile -t enutritrack-microservices-medical-history:latest .

# Servicio de Alertas
docker build -f src/alertas/Dockerfile -t enutritrack-microservices-alertas:latest .

# Servicio de Citas
docker build -f src/citas/Dockerfile -t enutritrack-microservices-citas:latest .
```

> **Nota:** El frontend será construido más adelante, después de completar el despliegue inicial.

---

## Despliegue con Terraform

### Paso 5: Aplicar Cambios en Terraform

Navega a la carpeta de Terraform y aplica la configuración:

```bash
cd Terraform

# Formatear archivos de Terraform
terraform fmt

# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Ver plan de despliegue
terraform plan

# Aplicar cambios
terraform apply -auto-approve
```

---

## Configuración del Frontend

### Paso 6: Actualizar Nginx con DNS del Backend

Una vez completado el `terraform apply`, obtén el DNS del Application Load Balancer (ALB) de microservicios:

```bash
terraform output alb_microservices_dns
```

Edita el archivo `nginx.conf` del frontend y reemplaza la URL del backend con el DNS obtenido. Solo cambia la parte del dominio:

```nginx
# Ejemplo de antes:
proxy_pass http://enutritrack-microservices-1357728765.us-east-1.elb.amazonaws.com/ruta/ruta;

# Ejemplo de después (reemplaza con tu DNS):
proxy_pass http://YOUR_ALB_MICROSERVICES_DNS/ruta/ruta;
```

El resto de la configuración se mantiene igual.

### Paso 7: Construir Imagen del Frontend

```bash
cd enutritrack-client
docker build -t enutritrack-client:latest .
```

---

## Subida de Imágenes a AWS

### Paso 8: Subir Imágenes a ECR

Desde la raíz del proyecto, ejecuta el script de subida:

```powershell
.\upload-all -Action all
```

Este script subirá todas las imágenes Docker a los repositorios de Amazon ECR.

---

## Inicialización de Base de Datos

### Paso 9: Ejecutar Scripts de Base de Datos

Una vez que todas las imágenes se hayan subido exitosamente a ECR, procede a inicializar la base de datos.

#### 9.1: Navegar a la carpeta de Terraform

```bash
cd Terraform
```

#### 9.2: Configurar Permisos de Clave Temporal

Otorga los permisos necesarios al archivo de clave temporal (`temp-key.pem`):

```powershell
icacls.exe temp-key.pem /reset
icacls.exe temp-key.pem /inheritance:r
icacls.exe temp-key.pem /grant:r "${env:USERNAME}:R"
```

#### 9.3: Conectarse a la Instancia EC2 e Instalar PostgreSQL

En una terminal, obtén la IP pública de la instancia temporal:

```bash
terraform output temp_sql_runner_public_ip
```

Conéctate a la instancia:

```bash
ssh -i temp-key.pem ec2-user@<IP_DE_LA_INSTANCIA>
```

Cuando se te pregunte, escribe `yes` para confirmar la conexión.

Instala PostgreSQL 14:

```bash
sudo amazon-linux-extras install postgresql14 -y
```

#### 9.4: Subir Scripts SQL a la Instancia

En otra terminal, sube los scripts de inicialización a la instancia:

```bash
# Obtén la IP nuevamente
terraform output temp_sql_runner_public_ip

# Sube el script de inicialización
scp -i temp-key.pem ../enutritrack-server/scripts/init-db.sql ec2-user@<IP_DE_LA_INSTANCIA>:/tmp/init-db.sql

# Sube el script de stored procedures
scp -i temp-key.pem ../enutritrack-server/scripts/stored-procedures.sql ec2-user@<IP_DE_LA_INSTANCIA>:/tmp/stored-procedures.sql
```

#### 9.5: Ejecutar Scripts en la Instancia EC2

En la terminal donde conectaste con SSH, obtén el host de RDS ejecutando el siguiente comando en otra terminal:

```bash
cd Terraform
terraform output rds_address
```

El host debe verse así:
```
enutritrack-postgres-dev.c3wys8w0u0qm.us-east-1.rds.amazonaws.com
```

Si prefieres buscarlo manualmente, ve a la consola de AWS → RDS → Databases → Copia el endpoint.

Ejecuta los scripts SQL reemplazando `<RDS_HOST>` con el host obtenido:

```bash
# Script de inicialización
PGPASSWORD="enutritrack2024" psql "sslmode=require host=<RDS_HOST> port=5433 dbname=enutritrack user=enutritrack" -f /tmp/init-db.sql

# Script de stored procedures
PGPASSWORD="enutritrack2024" psql "sslmode=require host=<RDS_HOST> port=5433 dbname=enutritrack user=enutritrack" -f /tmp/stored-procedures.sql
```

**Ejemplo con valor real:**
```bash
PGPASSWORD="enutritrack2024" psql "sslmode=require host=enutritrack-postgres-dev.c3wys8w0u0qm.us-east-1.rds.amazonaws.com port=5433 dbname=enutritrack user=enutritrack" -f /tmp/init-db.sql
```

---

## Reconstrucción de Servicios ECS

### Paso 9.6: Reiniciar Todos los Servicios ECS

En una terminal diferente (dentro de la carpeta Terraform), reconstruye todos los servicios ECS para que utilicen las nuevas imágenes:

```bash
cd Terraform

terraform apply \
  -replace="module.ecs_service_cms.aws_ecs_service.this" \
  -replace="module.ecs_service_auth.aws_ecs_service.this" \
  -replace="module.ecs_service_users.aws_ecs_service.this" \
  -replace="module.ecs_service_doctor.aws_ecs_service.this" \
  -replace="module.ecs_service_nutrition.aws_ecs_service.this" \
  -replace="module.ecs_service_activity.aws_ecs_service.this" \
  -replace="module.ecs_service_recommendation.aws_ecs_service.this" \
  -replace="module.ecs_service_medical_history.aws_ecs_service.this" \
  -replace="module.ecs_service_alertas.aws_ecs_service.this" \
  -replace="module.ecs_service_citas.aws_ecs_service.this" \
  -auto-approve
```

---

## Verificación y Pruebas

### Paso 10: Verificar que los Contenedores Estén en Ejecución

Espera a que todos los contenedores ECS cambien su estado a **RUNNING**. Puedes verificar esto en la consola de AWS ECS.

### URLs de Prueba

#### Frontend
```
http://enutritrack-alb-frontend-1931897726.us-east-1.elb.amazonaws.com
```

#### Backend CMS
```
http://enutritrack-alb-cms-2141858571.us-east-1.elb.amazonaws.com/auth/login
```

### Credenciales de Prueba - CMS

- **Usuario:** admin@enutritrack.com
- **Contraseña:** admin123

### Credenciales de Prueba - Frontend (Doctor)

- **Usuario:** dr.perez@enutritrack.com
- **Contraseña:** doctor123

---

## Pruebas de la App Móvil

### Paso 11: Configurar la Aplicación Móvil

Para probar la aplicación móvil, necesitas actualizar el archivo de configuración con los DNS obtenidos.

#### Ubicación del archivo

```
/enutritrack-app/Enutritrackapp/app/src/main/java/com.example.enutritrack_app/config/ApiConfig.kt
```

#### Variables a actualizar

Actualiza las siguientes variables con los DNS de tu despliegue:

```kotlin
// Variable ALB_CMS_DNS
ALB_CMS_DNS = "tu-cms-dns-aqui.us-east-1.elb.amazonaws.com"

// Variable ALB_MICROSERVICES_DNS
ALB_MICROSERVICES_DNS = "tu-microservices-dns-aqui.us-east-1.elb.amazonaws.com"
```

Obtén estos valores ejecutando:

```bash
cd Terraform

# DNS del CMS
terraform output alb_cms_dns

# DNS de Microservicios
terraform output alb_microservices_dns
```

### Paso 11.2: Ejecutar la Aplicación

1. Abre un emulador móvil de Android
2. En Android Studio, ejecuta la aplicación seleccionando "Run App"

### Credenciales de Prueba - App Móvil (Paciente)

- **Usuario:** camila.ortiz@enutritrack.com
- **Contraseña:** paciente123

---

## Resumen del Flujo de Despliegue

```
1. Configurar entorno (AWS CLI, variables, API keys)
   ↓
2. Construir imágenes Docker (9 microservicios + CMS)
   ↓
3. Desplegar infraestructura con Terraform
   ↓
4. Configurar DNS del frontend en nginx
   ↓
5. Construir imagen del frontend
   ↓
6. Subir todas las imágenes a ECR
   ↓
7. Inicializar base de datos PostgreSQL
   ↓
8. Reconstruir servicios ECS
   ↓
9. Verificar que los contenedores estén en RUNNING
   ↓
10. Probar en navegador y aplicación móvil
```

---

## Notas Importantes

- ⚠️ **Permisos:** Asegúrate de tener los permisos necesarios en tu cuenta de AWS
- 🔐 **Credenciales:** Nunca hagas commit de tus API keys o credenciales a control de versión
- 🌍 **Región:** El despliegue está configurado para `us-east-1`, ajusta si es necesario
- 🔄 **Terraform State:** Mantén seguro tu archivo `terraform.tfstate`
- ⏱️ **Tiempo:** El despliegue completo puede tardar 20-30 minutos

---

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| Error en `terraform init` | Verifica que hayas configurado AWS CLI correctamente |
| Error de permisos en temp-key.pem | Ejecuta nuevamente los comandos de `icacls.exe` |
| Contenedores en estado FAILED | Revisa los logs en CloudWatch para diagnosticar el problema |
| DNS no responde | Espera 2-3 minutos para que los ALBs estén completamente activos |

---

**Última actualización:** Junio 2024  
**Versión de Enutritrack:** 1.0  
**Tecnologías:** NestJS, React, Kotlin, PostgreSQL, Couchbase, Redis, AWS, Terraform