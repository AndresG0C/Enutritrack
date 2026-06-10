variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_ip" {
  type        = string
  description = "Your public IP for Couchbase access"
}

variable "alb_microservices_sg_id" {
  description = "Security group ID del ALB de microservicios"
  type        = string
  default     = null
}
