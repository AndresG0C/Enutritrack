# Script para iniciar todos los servicios de Enutritrack en Windows
# Abre 10 terminales PowerShell, una para cada servicio

Write-Host "===============================================================" -ForegroundColor Green
Write-Host "Iniciando servicios de Enutritrack" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host ""

# Obtener el directorio del script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "Directorio del proyecto: $ScriptDir" -ForegroundColor Cyan
Write-Host ""

# Función para abrir una nueva ventana de PowerShell y ejecutar un comando
function Start-ServiceWindow {
    param(
        [string]$Title,
        [string]$Directory,
        [string]$Command
    )
    
    Write-Host "   Iniciando: $Title" -ForegroundColor Yellow
    
    # Crear un script temporal para ejecutar en la nueva ventana
    $TempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
    $ScriptContent = @"
`$Host.UI.RawUI.WindowTitle = '$Title'
Set-Location '$Directory'
Write-Host '===============================================================' -ForegroundColor Green
Write-Host '$Title' -ForegroundColor Green
Write-Host '===============================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Directorio: $Directory' -ForegroundColor Cyan
Write-Host 'Comando: $Command' -ForegroundColor Cyan
Write-Host ''
$Command
"@
    
    $ScriptContent | Out-File -FilePath $TempScript -Encoding UTF8
    
    # Abrir nueva ventana de PowerShell
    $argList = "-NoExit", "-File", $TempScript
    Start-Process powershell.exe -ArgumentList $argList
    
    Start-Sleep -Milliseconds 500
}

Write-Host "Abriendo terminales para cada servicio..." -ForegroundColor Yellow
Write-Host ""

# 1. Backend
Start-ServiceWindow -Title "Enutritrack - Backend (CMS)" -Directory "$ScriptDir\enutritrack-server" -Command "npm run start:dev"

# 2. Gateway de Microservicios
Start-ServiceWindow -Title "Enutritrack - Gateway" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:gateway"

# 3. Microservicio de Auth
Start-ServiceWindow -Title "Enutritrack - Auth (3004)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:auth"

# 4. Microservicio de Usuarios
Start-ServiceWindow -Title "Enutritrack - Users (3001)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:user"

# 5. Microservicio de Doctores
Start-ServiceWindow -Title "Enutritrack - Doctors (3007)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:doctor"

# 6. Microservicio de Nutricion
Start-ServiceWindow -Title "Enutritrack - Nutrition (3003)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:nutrition"

# 7. Microservicio de Actividad
Start-ServiceWindow -Title "Enutritrack - Activity (3005)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:activity"

# 8. Microservicio de Recomendaciones
Start-ServiceWindow -Title "Enutritrack - Recommendation (3006)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:recommendation"

# 9. Microservicio de Historial Medico
Start-ServiceWindow -Title "Enutritrack - Medical History (3002)" -Directory "$ScriptDir\enutritrack-microservices" -Command "npm run dev:medical"

# 10. Frontend
Start-ServiceWindow -Title "Enutritrack - Frontend (5174)" -Directory "$ScriptDir\enutritrack-client" -Command "npm run dev"

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "10 terminales abiertas!" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Servicios iniciados:" -ForegroundColor Cyan
Write-Host "   1. Backend (CMS) - Puerto 4000" -ForegroundColor White
Write-Host "   2. Gateway - Puerto 3000" -ForegroundColor White
Write-Host "   3. Auth - Puerto 3004" -ForegroundColor White
Write-Host "   4. Users - Puerto 3001" -ForegroundColor White
Write-Host "   5. Doctors - Puerto 3007" -ForegroundColor White
Write-Host "   6. Nutrition - Puerto 3003" -ForegroundColor White
Write-Host "   7. Activity - Puerto 3005" -ForegroundColor White
Write-Host "   8. Recommendation - Puerto 3006" -ForegroundColor White
Write-Host "   9. Medical History - Puerto 3002" -ForegroundColor White
Write-Host "  10. Frontend - Puerto 5174" -ForegroundColor White
Write-Host ""
Write-Host "URLs de acceso:" -ForegroundColor Cyan
Write-Host "   Frontend:  http://localhost:5174" -ForegroundColor White
Write-Host "   CMS:       http://localhost:4000/auth/login" -ForegroundColor White
Write-Host "   Swagger:   http://localhost:4000/api/docs" -ForegroundColor White
Write-Host ""
Write-Host "Para detener los servicios, cierra cada ventana de PowerShell" -ForegroundColor Yellow
Write-Host ""
