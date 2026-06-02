# upload-all.ps1
# Script para subir imágenes a ECR y ejecutar scripts SQL en RDS
# Uso: .\upload-all.ps1 [-Action images|sql|all]

param(
    [string]$Action = "all"
)

$ACCOUNT = "127348835096"
$REGION = "us-east-1"
$DB_NAME = "enutritrack"
$DB_USER = "enutritrack"
$DB_PASSWORD = "enutritrack2024"

$repos = @(
    "enutritrack-client",
    "enutritrack-server-cms",
    "enutritrack-microservices-auth",
    "enutritrack-microservices-users",
    "enutritrack-microservices-doctor",
    "enutritrack-microservices-nutrition",
    "enutritrack-microservices-activity",
    "enutritrack-microservices-recommendation",
    "enutritrack-microservices-medical-history",
    "enutritrack-microservices-alertas",
    "enutritrack-microservices-citas"
)

function Invoke-ImageUpload {
    Write-Host "Autenticando en ECR..." -ForegroundColor Yellow
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en autenticacion ECR" -ForegroundColor Red
        exit 1
    }
    Write-Host "Autenticacion exitosa" -ForegroundColor Green
    
    foreach ($repo in $repos) {
        Write-Host "Subiendo $repo..." -ForegroundColor Yellow
        
        $localImage = docker images --format "{{.Repository}}" | Where-Object { $_ -eq "andresg0c/$repo" }
        if (-not $localImage) {
            Write-Host "Imagen andresg0c/$repo no encontrada localmente, omitiendo..." -ForegroundColor Red
            continue
        }
        
        docker tag "andresg0c/$repo" "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$repo`:latest"
        docker push "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$repo`:latest"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$repo subida correctamente" -ForegroundColor Green
        } else {
            Write-Host "Error subiendo $repo" -ForegroundColor Red
        }
    }
    
    Write-Host "Proceso de subida completado" -ForegroundColor Cyan
}

function Invoke-SqlScripts {
    Write-Host "Ejecutando scripts SQL en RDS..." -ForegroundColor Yellow
    
    $rdsEndpoint = terraform -chdir="terraform" output -raw rds_address 2>$null
    if (-not $rdsEndpoint) {
        Write-Host "No se pudo obtener RDS endpoint" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "RDS Endpoint: $rdsEndpoint" -ForegroundColor Cyan
    
    $initScript = "$PWD/enutritrack-server/scripts/init-db.sql"
    $procScript = "$PWD/enutritrack-server/scripts/stored-procedures.sql"
    
    if (-not (Test-Path $initScript)) {
        Write-Host "No se encuentra: $initScript" -ForegroundColor Red
        exit 1
    }
    
    if (-not (Test-Path $procScript)) {
        Write-Host "No se encuentra: $procScript" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Esperando a que RDS este disponible..." -ForegroundColor Yellow
    for ($i = 1; $i -le 60; $i++) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $asyncResult = $tcpClient.BeginConnect($rdsEndpoint, 5433, $null, $null)
            $wait = $asyncResult.AsyncWaitHandle.WaitOne(2000)
            if ($wait -and $tcpClient.Connected) {
                $tcpClient.Close()
                Write-Host "RDS disponible" -ForegroundColor Green
                break
            }
            $tcpClient.Close()
        } catch {
            # Ignorar error
        }
        if ($i % 10 -eq 0) {
            Write-Host "Esperando... ($i/60)"
        }
        Start-Sleep -Seconds 5
    }
    
    Write-Host "Ejecutando init-db.sql..." -ForegroundColor Yellow
    docker run --rm -v "${PWD}/enutritrack-server/scripts:/scripts" -e PGPASSWORD=$DB_PASSWORD postgres:15 psql -h $rdsEndpoint -p 5433 -U $DB_USER -d postgres -f /scripts/init-db.sql
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "init-db.sql ejecutado correctamente" -ForegroundColor Green
    } else {
        Write-Host "Error ejecutando init-db.sql" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Ejecutando stored-procedures.sql..." -ForegroundColor Yellow
    docker run --rm -v "${PWD}/enutritrack-server/scripts:/scripts" -e PGPASSWORD=$DB_PASSWORD postgres:15 psql -h $rdsEndpoint -p 5433 -U $DB_USER -d $DB_NAME -f /scripts/stored-procedures.sql
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "stored-procedures.sql ejecutado correctamente" -ForegroundColor Green
    } else {
        Write-Host "Error ejecutando stored-procedures.sql" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Scripts SQL ejecutados correctamente" -ForegroundColor Green
}

if ($Action -eq "images") {
    Invoke-ImageUpload
} elseif ($Action -eq "sql") {
    Invoke-SqlScripts
} elseif ($Action -eq "all") {
    Invoke-ImageUpload
    Invoke-SqlScripts
} else {
    Write-Host "Uso: .\upload-all.ps1 [-Action images|sql|all]" -ForegroundColor Cyan
}