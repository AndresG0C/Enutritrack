# Script para aplicar stored procedures al dashboard de superusuario
# Este script debe ejecutarse despues de inicializar la base de datos

Write-Host '===============================================' -ForegroundColor Cyan
Write-Host '  Aplicando Stored Procedures al Dashboard' -ForegroundColor Cyan
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
    Write-Host "  Abre pgAdmin, conectate a la base de datos $DB_NAME y ejecuta el archivo stored-procedures.sql" -ForegroundColor Gray
    Write-Host ''
    exit 1
}

# Aplicar stored procedures
try {
    $env:PGPASSWORD = $DB_PASSWORD
    
    Write-Host 'Aplicando stored procedures...' -ForegroundColor Yellow
    
    # Construir el argumento para psql
    $arguments = @(
        "-U", $DB_USER,
        "-h", $DB_HOST,
        "-p", $DB_PORT,
        "-d", $DB_NAME,
        "-f", "stored-procedures.sql"
    )
    
    # Ejecutar psql con la ruta completa
    $process = Start-Process -FilePath $psqlPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -eq 0) {
        Write-Host ''
        Write-Host 'Stored procedures aplicados exitosamente!' -ForegroundColor Green
        Write-Host ''
        Write-Host 'Procedimientos principales creados:' -ForegroundColor Cyan
        Write-Host '  - sp_get_all_patients()' -ForegroundColor Gray
        Write-Host '  - sp_get_patient_details(patient_id)' -ForegroundColor Gray
        Write-Host '  - sp_update_patient_doctor(patient_id, doctor_id)' -ForegroundColor Gray
        Write-Host '  - sp_toggle_patient_status(patient_id)' -ForegroundColor Gray
        Write-Host '  - sp_get_all_doctors()' -ForegroundColor Gray
        Write-Host '  - sp_get_doctor_patients(doctor_id)' -ForegroundColor Gray
        Write-Host '  - sp_create_doctor(...)' -ForegroundColor Gray
        Write-Host '  - sp_update_doctor(...)' -ForegroundColor Gray
        Write-Host '  - sp_get_all_admins()' -ForegroundColor Gray
        Write-Host '  - sp_get_admin_details(email)' -ForegroundColor Gray
        Write-Host '  - sp_get_dashboard_stats()' -ForegroundColor Gray
        Write-Host '  - sp_get_patients_by_gender()' -ForegroundColor Gray
        Write-Host '  - sp_get_recent_registrations()' -ForegroundColor Gray
        Write-Host '  - obtener_historial_medico_completo()' -ForegroundColor Gray
        Write-Host '  - analisis_progreso_peso()' -ForegroundColor Gray
        Write-Host '  - reporte_consumo_mensual()' -ForegroundColor Gray
        Write-Host '  - dashboard_estadisticas_generales()' -ForegroundColor Gray
        Write-Host '  - buscar_usuarios_por_patron_medico()' -ForegroundColor Gray
        Write-Host '  - buscar_usuarios_por_perfil()' -ForegroundColor Gray
        Write-Host '  - buscar_staff_por_patron()' -ForegroundColor Gray
        Write-Host ''
    } else {
        Write-Host ''
        Write-Host 'ERROR al aplicar stored procedures.' -ForegroundColor Red
        Write-Host 'Exit Code: ' + $process.ExitCode -ForegroundColor Red
        Write-Host ''
        exit 1
    }
} catch {
    Write-Host ''
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ''
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host 'Proceso completado.' -ForegroundColor Green
Write-Host ''