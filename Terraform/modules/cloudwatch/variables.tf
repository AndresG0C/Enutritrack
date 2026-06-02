variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_services" {
  type    = list(string)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "rds_identifier" {
  type    = string
  default = ""
}

variable "redis_cluster_id" {
  type    = string
  default = ""
}

variable "cpu_alarm_threshold" {
  type    = number
  default = 80
}

variable "memory_alarm_threshold" {
  type    = number
  default = 85
}
