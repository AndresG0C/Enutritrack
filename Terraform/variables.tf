#############################################
# VARIABLES GLOBALES
#############################################

variable "aws_region" {
  description = "Región de AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto (usado en tags y naming)"
  type        = string
  default     = "enutritrack"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

#############################################
# VARIABLES DE RED (VPC)
#############################################

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_ip" {
  description = "Tu IP pública para acceder a Couchbase UI (ej: 190.242.30.60)"
  type        = string
}

#############################################
# VARIABLES DE RDS (POSTGRESQL)
#############################################

variable "db_name" {
  description = "Nombre de la base de datos PostgreSQL"
  type        = string
  default     = "enutritrack"
}

variable "db_username" {
  description = "Usuario administrador de PostgreSQL"
  type        = string
  default     = "enutritrack"
}

variable "db_password" {
  description = "Contraseña del usuario administrador de PostgreSQL"
  type        = string
  sensitive   = true
  default     = "enutritrack2024"
}

variable "db_instance_class" {
  description = "Tipo de instancia para RDS"
  type        = string
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado a RDS en GB"
  type        = number
  default     = 20
}

#############################################
# VARIABLES DE COUCHBASE EC2
#############################################

variable "couchbase_instance_type" {
  description = "Tipo de instancia EC2 para Couchbase"
  type        = string
  default     = "t2.medium"
}

variable "assign_couchbase_eip" {
  description = "Asignar Elastic IP pública a Couchbase"
  type        = bool
  default     = true
}

#############################################
# VARIABLES DE ECS
#############################################

variable "cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
  default     = "enutritrack"
}

variable "desired_count" {
  description = "Número deseado de tareas ECS"
  type        = number
  default     = 1
}

#############################################
# VARIABLES DE ECR
#############################################

variable "repositories" {
  description = "Lista de repositorios ECR a crear"
  type        = list(string)
  default = [
    "enutritrack-client",
    "enutritrack-server-cms",
    "enutritrack-microservices-gateway",
    "enutritrack-microservices-auth",
    "enutritrack-microservices-users",
    "enutritrack-microservices-doctor",
    "enutritrack-microservices-nutrition",
    "enutritrack-microservices-activity",
    "enutritrack-microservices-recommendation",
    "enutritrack-microservices-medical-history",
    "enutritrack-microservices-alertas",
    "enutritrack-microservices-citas"
  ]
}
