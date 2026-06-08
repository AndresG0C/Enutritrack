#############################################
# RDS SUBNET GROUP
#############################################

resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-rds-subnet-group"
  description = "Subnet group for RDS PostgreSQL"
  subnet_ids  = var.private_subnets

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

#############################################
# PARAMETER GROUP (Puerto 5433)
#############################################

resource "aws_db_parameter_group" "this" {
  name   = "${var.project_name}-pg-5433"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # 0 = no forzar SSL, 1 = forzar SSL
  }

  tags = {
    Name = "${var.project_name}-pg-5433"
  }
}

#############################################
# POSTGRESQL RDS INSTANCE
#############################################

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-postgres-${var.environment}"

  engine         = "postgres"
  engine_version = "15.10"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5433

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  storage_type          = "gp3"

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot = var.environment != "prod"
  deletion_protection = var.environment == "prod"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-postgres"
  }
}
