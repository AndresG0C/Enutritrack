# upload-images.ps1
param(
    [string]$Action = "all"
)

$ACCOUNT = "127348835096"
$REGION = "us-east-1"

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
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUBIENDO IMAGENES A ECR" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Login a ECR
    Write-Host "Autenticando en ECR..." -ForegroundColor Yellow
    $loginResult = aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com" 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo autenticar en ECR" -ForegroundColor Red
        Write-Host $loginResult -ForegroundColor Red
        exit 1
    }
    Write-Host "Autenticacion exitosa" -ForegroundColor Green
    
    foreach ($repo in $repos) {
        Write-Host "`nSubiendo $repo..." -ForegroundColor Yellow
        
        # Verificar que la imagen local existe (ahora solo con el nombre del repo)
        $localImage = docker images --format "{{.Repository}}" | Where-Object { $_ -eq $repo }
        if (-not $localImage) {
            Write-Host "WARNING: Imagen $repo no encontrada localmente" -ForegroundColor Red
            Write-Host "Construyela primero con: docker build -t $repo ." -ForegroundColor Yellow
            continue
        }
        
        # Taggear (ya no hay andresg0c)
        Write-Host "   Taggeando imagen..." -ForegroundColor Gray
        docker tag $repo "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$repo`:latest" 2>&1
        
        # Subir
        Write-Host "   Subiendo a ECR (esto puede tomar varios minutos)..." -ForegroundColor Gray
        $pushResult = docker push "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$repo`:latest" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $repo subida correctamente" -ForegroundColor Green
        }
        else {
            Write-Host "   ERROR: No se pudo subir $repo" -ForegroundColor Red
            Write-Host $pushResult -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "TODAS LAS IMAGENES SUBIDAS CORRECTAMENTE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

if ($Action -eq "images") {
    Invoke-ImageUpload
}
elseif ($Action -eq "all") {
    Invoke-ImageUpload
}
else {
    Write-Host "Uso: .\upload-images.ps1 -Action images" -ForegroundColor Cyan
}