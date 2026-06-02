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
