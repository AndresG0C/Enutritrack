# ============================================
# 1. CORREGIR PERMISOS DE LA LLAVE SSH (desde PowerShell como Admin)
# ============================================
cd C:\ENUTRITRACK\enutritrack\terraform

icacls.exe temp-key.pem /reset
icacls.exe temp-key.pem /inheritance:r
icacls.exe temp-key.pem /grant:r "${env:USERNAME}:R"

terraform output temp_sql_runner_public_ip 

# ============================================
# 2. CONECTARSE A LA EC2 TEMPORAL
# ============================================
ssh -i temp-key.pem ec2-user@<DIR IP>

# ============================================
# 3. DENTRO DE LA EC2, INSTALAR POSTGRESQL CLIENT
# ============================================
sudo amazon-linux-extras install postgresql14 -y

# ============================================
# 4. EN TU MÁQUINA LOCAL (OTRA TERMINAL), COPIAR LOS SCRIPTS
# ============================================
cd C:\ENUTRITRACK\enutritrack\terraform
terraform output temp_sql_runner_public_ip


scp -i temp-key.pem ../enutritrack-server/scripts/init-db.sql ec2-user@<DIR IP>:/tmp/init-db.sql
scp -i temp-key.pem ../enutritrack-server/scripts/stored-procedures.sql ec2-user@<DIR IP>:/tmp/stored-procedures.sql

# ============================================
# 5. DENTRO DE LA EC2, EJECUTAR LOS SCRIPTS
# ============================================
PGPASSWORD="enutritrack2024" psql "sslmode=require host=enutritrack-postgres-dev.c3wys8w0u0qm.us-east-1.rds.amazonaws.com port=5433 dbname=enutritrack user=enutritrack" -f /tmp/init-db.sql

PGPASSWORD="enutritrack2024" psql "sslmode=require host=enutritrack-postgres-dev.c3wys8w0u0qm.us-east-1.rds.amazonaws.com port=5433 dbname=enutritrack user=enutritrack" -f /tmp/stored-procedures.sql

# ============================================
# 6. VERIFICAR QUE LOS PROCEDIMIENTOS SE CREARON
# ============================================
PGPASSWORD="enutritrack2024" psql "sslmode=require host=enutritrack-postgres-dev.c3wys8w0u0qm.us-east-1.rds.amazonaws.com port=5433 dbname=enutritrack user=enutritrack" -c "\df sp_*"

# ============================================
# 7. RECREAR LOS SERVICIOS ECS (desde tu máquina local)
# ============================================
cd C:\ENUTRITRACK\enutritrack\terraform

terraform apply -replace="module.ecs_service_cms.aws_ecs_service.this" -replace="module.ecs_service_auth.aws_ecs_service.this" -replace="module.ecs_service_users.aws_ecs_service.this" -replace="module.ecs_service_doctor.aws_ecs_service.this" -replace="module.ecs_service_nutrition.aws_ecs_service.this" -replace="module.ecs_service_activity.aws_ecs_service.this" -replace="module.ecs_service_recommendation.aws_ecs_service.this" -replace="module.ecs_service_medical_history.aws_ecs_service.this" -replace="module.ecs_service_alertas.aws_ecs_service.this" -replace="module.ecs_service_citas.aws_ecs_service.this" -auto-approve

# ============================================
# 8. VERIFICAR HEALTH CHECKS
# ============================================
curl http://enutritrack-alb-frontend-1856857295.us-east-1.elb.amazonaws.com/health.html
curl http://enutritrack-alb-cms-596885596.us-east-1.elb.amazonaws.com/health/check

# ============================================
# 9. DESTRUIR LA EC2 TEMPORAL (opcional)
# ============================================
terraform destroy -target=aws_instance.temp_sql_runner -auto-approve