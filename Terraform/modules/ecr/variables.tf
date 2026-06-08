#############################################
# VARIABLES ECR
#############################################

variable "project_name" {
  type = string
}

variable "repositories" {
  type = list(string)

  description = "Lista de repositorios Docker"

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

  validation {
    condition = alltrue([
      for repo in var.repositories : length(repo) <= 256
    ])
    error_message = "Cada nombre de repositorio debe tener máximo 256 caracteres."
  }

  validation {
    condition = alltrue([
      for repo in var.repositories : can(regex("^[a-z0-9][a-z0-9-_]+$", repo))
    ])
    error_message = "Los nombres solo pueden contener letras minúsculas, números, guiones y guiones bajos, y deben empezar con letra o número."
  }
}
