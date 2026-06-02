
#############################################
# VARIABLES TASK DEFINITION
#############################################

variable "project_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Agrega esta variable
variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}
