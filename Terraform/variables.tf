variable "aws_region" {
  type        = string
  description = "Región de AWS global"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Ambiente de ejecución"
  default     = "production"
}

variable "project_name" {
  type        = string
  description = "Nombre base para los recursos del proyecto"
  default     = "enutritrack"
}

variable "db_username" {
  type        = string
  description = "Usuario de la base de datos"
  default     = "enutritrack"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Contraseña de la base de datos"
}

variable "db_name" {
  type        = string
  description = "Nombre de la base de datos"
  default     = "enutritrack"
}
