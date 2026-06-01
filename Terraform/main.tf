# ==============================================================================
# 🏢 ARQUITECTURA PRINCIPAL DE ENUTRITRACK
# ==============================================================================

# 1. Primero creamos la seguridad básica de la VPC
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# 2. Pasamos el SG al módulo de la VPC para el Bastión
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  aws_region   = var.aws_region
  alb_sg       = module.security.alb_sg_id # 👈 Inyección al bastión
}

# 3. Módulo de Bases de Datos
module "database" {
  source          = "./modules/database"
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  data_subnet_ids = module.vpc.data_subnet_ids
  db_security_sg  = module.security.db_sg_id
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name
}

# 4. Módulo de ECS Cómputo
module "ecs" {
  source               = "./modules/ecs"
  project_name         = var.project_name
  aws_region           = var.aws_region
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnet_ids
  app_subnets          = module.vpc.app_subnet_ids
  ecs_tasks_sg         = module.security.ecs_tasks_sg_id
  alb_sg               = module.security.alb_sg_id
  postgres_endpoint    = module.database.postgres_endpoint
  db_username          = var.db_username
  db_password          = var.db_password
  db_name              = var.db_name
  couchbase_private_ip = module.database.couchbase_private_ip
  redis_private_ip     = module.database.redis_private_ip
}

# ==============================================================================
# 🚀 INYECCIÓN AUTOMATIZADA DE SCRIPTS .SQL A TRAVÉS DEL BASTIÓN
# ==============================================================================
resource "null_resource" "db_init" {
  # Se ejecuta estrictamente cuando la BD y el Bastión en la VPC estén creados
  depends_on = [module.database, module.vpc]

  # Monitorea cambios en los archivos SQL; si los editas, se volverá a ejecutar en el siguiente apply
  triggers = {
    init_db_hash    = filemd5("${path.root}/../enutritrack-server/scripts/init-db.sql")
    procedures_hash = filemd5("${path.root}/../enutritrack-server/scripts/stored-procedures.sql")
  }

  provisioner "local-exec" {
    command = <<EOF
      echo "Esperando 60 segundos a que AWS RDS PostgreSQL levante por completo..."
      timeout /t 60 /nobreak > nul

      echo "Estableciendo conexion segura e inyectando tablas base (init-db.sql)..."
      
      # Inyección de la estructura e inserciones iniciales apuntando al endpoint de RDS limpio
      psql -h ${element(split(":", module.database.postgres_endpoint), 0)} -p 5432 -U ${var.db_username} -d ${var.db_name} -f "${path.root}/../enutritrack-server/scripts/init-db.sql"
      
      echo "Inyectando procedimientos almacenados (stored-procedures.sql)..."
      
      # Inyección de tus Stored Procedures de NestJS
      psql -h ${element(split(":", module.database.postgres_endpoint), 0)} -p 5432 -U ${var.db_username} -d ${var.db_name} -f "${path.root}/../enutritrack-server/scripts/stored-procedures.sql"
      
      echo "¡Base de datos Enutritrack inicializada con éxito en AWS!"
    EOF

    environment = {
      PGPASSWORD = var.db_password # Pasa la contraseña de forma segura sin exponerla en la consola
    }
  }
}

# ==============================================================================
# 📦 CONFIGURACIÓN DE REPOSITORIOS AWS ECR Y AUTOMATIZACIÓN DOCKER PUSH
# ==============================================================================

# --- Creación de Repositorios ECR ---
resource "aws_ecr_repository" "client" {
  name                 = "${var.project_name}-client"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "gateway" {
  name                 = "${var.project_name}-gateway"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "cms" {
  name                 = "${var.project_name}-server"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

locals {
  microservices = {
    auth            = { repo = "enutritrack-microservices-auth", port = 3001 }
    users           = { repo = "enutritrack-microservices-users", port = 3002 }
    doctor          = { repo = "enutritrack-microservices-doctor", port = 3003 }
    nutrition       = { repo = "enutritrack-microservices-nutrition", port = 3004 }
    activity        = { repo = "enutritrack-microservices-activity", port = 3005 }
    recommendation  = { repo = "enutritrack-microservices-recommendation", port = 3006 }
    medical-history = { repo = "enutritrack-microservices-medical-history", port = 3007 }
    citas           = { repo = "enutritrack-microservices-citas", port = 3008 }
    alertas         = { repo = "enutritrack-microservices-alertas", port = 3009 }
  }
}

resource "aws_ecr_repository" "services" {
  for_each             = local.microservices
  name                 = "${var.project_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}


# --- Automatización Total sin Bucles (Cero errores de sintaxis) ---
resource "null_resource" "docker_push" {
  depends_on = [
    aws_ecr_repository.client,
    aws_ecr_repository.gateway,
    aws_ecr_repository.cms,
    aws_ecr_repository.services
  ]

  # Forzamos a que se ejecute siempre para asegurar que suba lo que falta
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = <<EOF
      echo "Iniciando sesion en AWS ECR..."
      $ecr_password = aws ecr get-login-password --region ${var.aws_region}
      docker login --username AWS --password $ecr_password 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com

      echo "Subiendo Frontend..."
      docker tag andresg0c/enutritrack-client:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-client:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-client:latest

      echo "Subiendo API Gateway..."
      docker tag andresg0c/enutritrack-microservices-gateway:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-gateway:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-gateway:latest

      echo "Subiendo Servidor Central..."
      docker tag andresg0c/enutritrack-server-cms:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-server:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-server:latest

      echo "Subiendo Microservicios uno por uno de forma explicita..."
      
      docker tag andresg0c/enutritrack-microservices-auth:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-auth:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-auth:latest

      docker tag andresg0c/enutritrack-microservices-users:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-users:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-users:latest

      docker tag andresg0c/enutritrack-microservices-doctor:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-doctor:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-doctor:latest

      docker tag andresg0c/enutritrack-microservices-nutrition:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-nutrition:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-nutrition:latest

      docker tag andresg0c/enutritrack-microservices-activity:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-activity:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-activity:latest

      docker tag andresg0c/enutritrack-microservices-recommendation:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-recommendation:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-recommendation:latest

      docker tag andresg0c/enutritrack-microservices-medical-history:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-medical-history:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-medical-history:latest

      docker tag andresg0c/enutritrack-microservices-citas:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-citas:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-citas:latest

      docker tag andresg0c/enutritrack-microservices-alertas:latest 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-alertas:latest
      docker push 127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-alertas:latest

      echo "¡Todo el ecosistema de imagenes Enutritrack se ha migrado con exito a AWS ECR!"
    EOF
    interpreter = ["PowerShell", "-Command"]
  }
}
