variable "project_name" {
  type        = string
  description = "Nombre base del proyecto para nombrar los recursos de ECS"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS donde se configuran los logs de CloudWatch"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se amarran los Target Groups del ALB"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de subredes públicas para posicionar el Load Balancer"
}

variable "app_subnets" {
  type        = list(string)
  description = "Lista de subredes privadas de app para desplegar Fargate"
}

variable "ecs_tasks_sg" {
  type        = string
  description = "ID del Security Group perimetral de los contenedores"
}

variable "alb_sg" {
  type        = string
  description = "ID del Security Group del Load Balancer"
}

# --- Inyecciones desde el Módulo de Base de Datos ---
variable "postgres_endpoint" {
  type        = string
  description = "Endpoint de conexión de RDS PostgreSQL"
}

variable "db_username" {
  type        = string
  description = "Usuario de la base de datos PostgreSQL"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Contraseña de la base de datos PostgreSQL"
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos en PostgreSQL"
}

variable "couchbase_private_ip" {
  type        = string
  description = "IP privada de la instancia EC2 con Couchbase"
}

variable "redis_private_ip" {
  type        = string
  description = "IP privada de la instancia EC2 con Redis"
}
