variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS"
}

variable "alb_sg" {
  type        = string
  description = "SG del ALB para compartírselo al Bastión"
}
