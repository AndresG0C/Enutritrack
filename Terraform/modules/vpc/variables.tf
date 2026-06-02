#############################################
# VARIABLES DEL MÓDULO VPC
#############################################

variable "project_name" {
  description = "Nombre del proyecto (usado en tags)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)"
  type        = string
}

variable "aws_region" {
  description = "Región AWS donde se despliega la infraestructura"
  type        = string
}
