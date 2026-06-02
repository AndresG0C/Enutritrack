
#############################################
# VARIABLES ECS SERVICE
#############################################

variable "project_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "enable_alb" {
  type    = bool
  default = true
}

variable "target_group_arn" {
  type    = string
  default = null
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}
