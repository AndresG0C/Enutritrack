# Script para inicializar la base de datos PostgreSQL
# Ejecuta el archivo init-db.sql que contiene la estructura y datos iniciales

Write-Host '===============================================' -ForegroundColor Cyan
Write-Host '  Inicializando Base de Datos PostgreSQL' -ForegroundColor Cyan
Write-Host '===============================================' -ForegroundColor Cyan
Write-Host ''

# Configuracion de la base de datos
$DB_HOST = 'localhost'
$DB_PORT = '5433'
$DB_NAME = 'enutritrack'
$DB_USER = 'enutritrack'
$DB_PASSWORD = 'enutritrack2024'

Write-Host 'Conectando a PostgreSQL...' -ForegroundColor Yellow
Write-Host "Host: $DB_HOST" -ForegroundColor Gray
Write-Host "Port: $DB_PORT" -ForegroundColor Gray
Write-Host "Database: $DB_NAME" -ForegroundColor Gray
Write-Host "User: $DB_USER" -ForegroundColor Gray
Write-Host ''

# Verificar que el archivo init-db.sql existe
$scriptPath = Join-Path $PSScriptRoot "init-db.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: No se encontró el archivo init-db.sql en: $scriptPath" -ForegroundColor Red
    Write-Host ''
    exit 1
}

Write-Host "Archivo SQL encontrado: $scriptPath" -ForegroundColor Green
Write-Host ''

# Buscar psql en rutas comunes
Write-Host 'Buscando PostgreSQL en rutas comunes...' -ForegroundColor Yellow

$possiblePaths = @(
    "C:\Program Files\PostgreSQL\18\bin\psql.exe",
    "C:\Program Files\PostgreSQL\15\bin\psql.exe",
    "C:\Program Files\PostgreSQL\14\bin\psql.exe",
    "C:\Program Files\PostgreSQL\13\bin\psql.exe",
    "C:\Program Files\PostgreSQL\12\bin\psql.exe"
)

$psqlPath = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $psqlPath = $path
        Write-Host "PostgreSQL encontrado en: $path" -ForegroundColor Green
        break
    }
}

if (-not $psqlPath) {
    Write-Host 'ERROR: No se pudo encontrar PostgreSQL en las rutas comunes.' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Por favor, asegurate de que PostgreSQL esté instalado o proporciona la ruta manualmente.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'O puedes ejecutar manualmente desde pgAdmin:' -ForegroundColor Cyan
    Write-Host "  1. Abre pgAdmin" -ForegroundColor Gray
    Write-Host "  2. Conectate a localhost:5433 (user: $DB_USER, password: $DB_PASSWORD)" -ForegroundColor Gray
    Write-Host "  3. Abre la base de datos $DB_NAME" -ForegroundColor Gray
    Write-Host "  4. Ejecuta el archivo: $scriptPath" -ForegroundColor Gray
    Write-Host ''
    Write-Host 'O usando Docker:' -ForegroundColor Cyan
    Write-Host "  docker exec -i enutritrack_postgres psql -U $DB_USER -d enutritrack < $scriptPath" -ForegroundColor Gray
    Write-Host ''
    exit 1
}

# Verificar conexión a la base de datos
Write-Host 'Verificando conexión a la base de datos...' -ForegroundColor Yellow
try {
    $env:PGPASSWORD = $DB_PASSWORD
    $testConnection = & $psqlPath -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "SELECT version();" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo conectar a la base de datos." -ForegroundColor Red
        Write-Host "Detalles: $testConnection" -ForegroundColor Red
        Write-Host ''
        Write-Host 'Asegurate de que:' -ForegroundColor Yellow
        Write-Host "  - PostgreSQL esté corriendo en ${DB_HOST}:${DB_PORT}" -ForegroundColor Gray
        Write-Host "  - La base de datos '$DB_NAME' exista" -ForegroundColor Gray
        Write-Host "  - Las credenciales sean correctas" -ForegroundColor Gray
        Write-Host ''
        Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        exit 1
    }
    Write-Host 'Conexión exitosa!' -ForegroundColor Green
    Write-Host ''
} catch {
    Write-Host "ERROR al verificar conexión: $_" -ForegroundColor Red
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    exit 1
}

# Ejecutar init-db.sql
try {
    Write-Host 'Ejecutando init-db.sql...' -ForegroundColor Yellow
    Write-Host 'Esto puede tardar varios minutos dependiendo del tamaño del script...' -ForegroundColor Gray
    Write-Host ''
    
    # Construir los argumentos para psql
    $arguments = @(
        "-U", $DB_USER,
        "-h", $DB_HOST,
        "-p", $DB_PORT,
        "-d", $DB_NAME,
        "-f", $scriptPath
    )
    
    # Ejecutar psql con la ruta completa
    $process = Start-Process -FilePath $psqlPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host ''
        Write-Host '===============================================' -ForegroundColor Green
        Write-Host '  Base de datos inicializada exitosamente!' -ForegroundColor Green
        Write-Host '===============================================' -ForegroundColor Green
        Write-Host ''
        Write-Host 'La base de datos ha sido poblada con:' -ForegroundColor Cyan
        Write-Host '  - Estructura de tablas' -ForegroundColor Gray
        Write-Host '  - Datos iniciales (alimentos, tipos de actividad, etc.)' -ForegroundColor Gray
        Write-Host '  - Usuarios de prueba (si están incluidos)' -ForegroundColor Gray
        Write-Host ''
        Write-Host 'Próximos pasos:' -ForegroundColor Yellow
        Write-Host '  1. Ejecutar apply-stored-procedures.ps1 para agregar funciones almacenadas' -ForegroundColor Gray
        Write-Host '  2. Verificar que todas las tablas se crearon correctamente' -ForegroundColor Gray
        Write-Host ''
    } else {
        Write-Host ''
        Write-Host 'ERROR al ejecutar init-db.sql' -ForegroundColor Red
        Write-Host "Exit Code: $($process.ExitCode)" -ForegroundColor Red
        Write-Host ''
        Write-Host 'Posibles causas:' -ForegroundColor Yellow
        Write-Host '  - Errores de sintaxis en el script SQL' -ForegroundColor Gray
        Write-Host '  - Tablas ya existentes con conflictos' -ForegroundColor Gray
        Write-Host '  - Problemas de permisos' -ForegroundColor Gray
        Write-Host '  - La base de datos no está vacía' -ForegroundColor Gray
        Write-Host ''
        Write-Host 'Revisa los mensajes de error anteriores para más detalles.' -ForegroundColor Yellow
        Write-Host ''
        Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        exit 1
    }
} catch {
    Write-Host ''
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ''
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host 'Proceso completado.' -ForegroundColor Green
Write-Host ''

