# modules/alb-microservices/variables.tf

variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "Lista de security groups que pueden acceder al ALB"
}
