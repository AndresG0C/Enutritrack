
#############################################
# VARIABLES ECS CLUSTER
#############################################

variable "project_name" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Nombre del cluster ECS"
  default     = "enutritrack-cluster"
}
