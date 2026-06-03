
# AWS ACADEMY LEARNER LAB CONFIGURATION

aws_region   = "us-east-1"
project_name = "enutritrack"
environment  = "dev"

# IP de administración para Couchbase UI
admin_ip = "186.169.55.241/32" # CAMBIA POR TU IP REAL

# Networking
vpc_cidr = "10.0.0.0/16"

# RDS PostgreSQL
db_name     = "enutritrack"
db_username = "enutritrack"
db_password = "enutritrack2024"

# Couchbase
couchbase_instance_type = "t3.large"
assign_couchbase_eip    = true

# ECS
cluster_name  = "enutritrack"
desired_count = 1

# Repositorios ECR
repositories = [
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
