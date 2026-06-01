variable "project_name" {
  type        = string
  description = "Nombre del proyecto para las etiquetas"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC principal"
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs de las subredes privadas de datos (Multi-AZ)"
}

variable "db_security_sg" {
  type        = string
  description = "ID del Security Group para las bases de datos"
}

variable "db_username" {
  type        = string
  description = "Usuario administrador de PostgreSQL"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Contraseña de PostgreSQL"
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos inicial"
}
