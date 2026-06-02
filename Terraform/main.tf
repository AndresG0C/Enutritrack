#############################################
# VPC
#############################################
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

#############################################
# SECURITY GROUPS
#############################################
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  admin_ip     = var.admin_ip
}

#############################################
# IAM (LabRole)
#############################################
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

#############################################
# ECR REPOSITORIES
#############################################
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  repositories = var.repositories
}

#############################################
# RDS (PostgreSQL)
#############################################
module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  environment       = var.environment
  private_subnets   = module.vpc.private_subnets
  security_group_id = module.security_groups.rds_sg_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

#############################################
# REDIS (ElastiCache)
#############################################
module "redis" {
  source = "./modules/redis"

  project_name      = var.project_name
  environment       = var.environment
  private_subnets   = module.vpc.private_subnets
  security_group_id = module.security_groups.redis_sg_id
}

#############################################
# COUCHBASE EC2
#############################################
module "couchbase" {
  source = "./modules/couchbase-ec2"

  project_name      = var.project_name
  environment       = var.environment
  private_subnets   = module.vpc.private_subnets
  security_group_id = module.security_groups.couchbase_sg_id
  instance_type     = var.couchbase_instance_type
  assign_eip        = var.assign_couchbase_eip
}

#############################################
# ALB - FRONTEND
#############################################
module "alb_frontend" {
  source = "./modules/alb"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
}

#############################################
# ALB - CMS
#############################################
module "alb_cms" {
  source = "./modules/alb-cms"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
}

#############################################
# ECS CLUSTER
#############################################
module "ecs_cluster" {
  source = "./modules/ecs/cluster"

  project_name = var.project_name
  cluster_name = var.cluster_name
}

#############################################
# VARIABLES COMUNES DE ENTORNO
#############################################
locals {
  common_env_vars = [
    { name = "NODE_ENV", value = var.environment },
    { name = "DB_HOST", value = module.rds.rds_address },
    { name = "DB_PORT", value = tostring(module.rds.rds_port) },
    { name = "DB_NAME", value = module.rds.rds_db_name },
    { name = "DB_USER", value = module.rds.rds_username },
    { name = "DB_PASSWORD", value = var.db_password },
    { name = "REDIS_HOST", value = module.redis.redis_endpoint },
    { name = "REDIS_PORT", value = tostring(module.redis.redis_port) },
    { name = "COUCHBASE_HOST", value = module.couchbase.couchbase_private_ip },
    { name = "COUCHBASE_PORT", value = "8091" },
    { name = "COUCHBASE_USERNAME", value = "Admin" },
    { name = "COUCHBASE_PASSWORD", value = "admin123" },
    { name = "COUCHBASE_BUCKET", value = "enutritrack" }
  ]
}

# ===========================================
# 1. FRONTEND - Expuesto al ALB Frontend (puerto 5174)
# ===========================================
module "task_definition_frontend" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-client"
  image              = "${module.ecr.repository_urls["enutritrack-client"]}:latest"
  container_port     = 80
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_frontend" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-client"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_frontend.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = true
  target_group_arn    = module.alb_frontend.target_group_frontend_arn
  container_name      = "enutritrack-client"
  container_port      = 80
}

# ===========================================
# 2. CMS - Expuesto al ALB CMS (puerto 4000)
# ===========================================
module "task_definition_cms" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy, module.rds]

  project_name       = var.project_name
  service_name       = "enutritrack-server-cms"
  image              = "${module.ecr.repository_urls["enutritrack-server-cms"]}:latest"
  container_port     = 4000
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_cms" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-server-cms"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_cms.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = true
  target_group_arn    = module.alb_cms.target_group_cms_arn
  container_name      = "enutritrack-server-cms"
  container_port      = 4000
}

# ===========================================
# 3. MICROSERVICIOS - INTERNOS (sin ALB)
# ===========================================

# Auth (puerto 3001)
module "task_definition_auth" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-auth"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-auth"]}:latest"
  container_port     = 3001
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_auth" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-auth"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_auth.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-auth"
  container_port      = 3001
}

# Users (puerto 3002)
module "task_definition_users" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-users"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-users"]}:latest"
  container_port     = 3002
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_users" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-users"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_users.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-users"
  container_port      = 3002
}

# Doctor (puerto 3003)
module "task_definition_doctor" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-doctor"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-doctor"]}:latest"
  container_port     = 3003
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_doctor" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-doctor"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_doctor.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-doctor"
  container_port      = 3003
}

# Nutrition (puerto 3004)
module "task_definition_nutrition" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-nutrition"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-nutrition"]}:latest"
  container_port     = 3004
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_nutrition" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-nutrition"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_nutrition.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-nutrition"
  container_port      = 3004
}

# Activity (puerto 3005)
module "task_definition_activity" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-activity"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-activity"]}:latest"
  container_port     = 3005
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_activity" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-activity"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_activity.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-activity"
  container_port      = 3005
}

# Recommendation (puerto 3006)
module "task_definition_recommendation" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-recommendation"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-recommendation"]}:latest"
  container_port     = 3006
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_recommendation" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-recommendation"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_recommendation.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-recommendation"
  container_port      = 3006
}

# Medical History (puerto 3007)
module "task_definition_medical_history" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-medical-history"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-medical-history"]}:latest"
  container_port     = 3007
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_medical_history" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-medical-history"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_medical_history.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-medical-history"
  container_port      = 3007
}

# Alertas (puerto 3008)
module "task_definition_alertas" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-alertas"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-alertas"]}:latest"
  container_port     = 3008
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_alertas" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-alertas"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_alertas.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-alertas"
  container_port      = 3008
}

# Citas (puerto 3009)
module "task_definition_citas" {
  source = "./modules/ecs/task-definition"

  depends_on = [terraform_data.deploy]

  project_name       = var.project_name
  service_name       = "enutritrack-microservices-citas"
  image              = "${module.ecr.repository_urls["enutritrack-microservices-citas"]}:latest"
  container_port     = 3009
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.labrole_arn
  task_role_arn      = module.iam.labrole_arn
  env_vars           = local.common_env_vars
}

module "ecs_service_citas" {
  source = "./modules/ecs/service"

  project_name        = var.project_name
  service_name        = "enutritrack-microservices-citas"
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.task_definition_citas.task_definition_arn
  desired_count       = var.desired_count
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.security_groups.ecs_sg_id]
  enable_alb          = false
  container_name      = "enutritrack-microservices-citas"
  container_port      = 3009
}

# ===========================================
# AUTO SCALING
# ===========================================

# Frontend
module "autoscaling_frontend" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_frontend.service_name
}

# CMS
module "autoscaling_cms" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_cms.service_name
}

# Auth
module "autoscaling_auth" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_auth.service_name
}

# Users
module "autoscaling_users" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_users.service_name
}

# Doctor
module "autoscaling_doctor" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_doctor.service_name
}

# Nutrition
module "autoscaling_nutrition" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_nutrition.service_name
}

# Activity
module "autoscaling_activity" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_activity.service_name
}

# Recommendation
module "autoscaling_recommendation" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_recommendation.service_name
}

# Medical History
module "autoscaling_medical_history" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_medical_history.service_name
}

# Alertas
module "autoscaling_alertas" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_alertas.service_name
}

# Citas
module "autoscaling_citas" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service_citas.service_name
}

# ===========================================
# CLOUDWATCH
# ===========================================
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name     = var.project_name
  aws_region       = var.aws_region
  cluster_name     = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_service_frontend.service_name
  ecs_services     = var.repositories
  rds_identifier   = module.rds.rds_address
  redis_cluster_id = "${var.project_name}-redis-${var.environment}"
}

#############################################
# EJECUTAR SCRIPT COMPLETO (subir imágenes + SQL)
#############################################

resource "terraform_data" "deploy" {
  depends_on = [
    module.ecr,
    module.rds,
    module.ecs_cluster,
    module.alb_frontend,
    module.alb_cms
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "========================================="
      echo "Ejecutando script de despliegue completo..."
      echo "========================================="
      powershell -ExecutionPolicy Bypass -File "${path.cwd}/../upload-all.ps1" -Action all
      echo "========================================="
      echo "✅ Despliegue completado"
      echo "========================================="
    EOT
  }
}
