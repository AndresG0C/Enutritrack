# --- Grupo de Subredes para la Base de Datos (Agrupa las subredes de datos en Multi-AZ) ---
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# --- Instancia de PostgreSQL en AWS RDS (Alta Disponibilidad Multi-AZ) ---
resource "aws_db_instance" "postgres" {
  identifier            = "${var.project_name}-postgres"
  engine                = "postgres"
  engine_version        = "15"          # Versión estable y robusta
  instance_class        = "db.t3.micro" # AWS Free Tier / Económica para el proyecto
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  port                  = 5433

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [var.db_security_sg]

  # 🚀 ALTA DISPONIBILIDAD ACTIVADA
  multi_az = true

  skip_final_snapshot = true
  publicly_accessible = false # Nadie desde internet puede tocarla

  tags = { Name = "${var.project_name}-postgres-rds" }
}


# ==============================================================================
# SERVIDOR COUCHBASE (Subred Privada Datos 1 - AZ A)
# ==============================================================================
resource "aws_instance" "couchbase" {
  ami                    = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI estable en us-east-1
  instance_type          = "t3.medium"             # Couchbase requiere al menos 4GB de RAM para iniciar holgado
  subnet_id              = var.data_subnet_ids[0]  # Se instala en private_data_1
  vpc_security_group_ids = [var.db_security_sg]

  # Script de automatización para instalar Docker y Couchbase al arrancar
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              
              # Levantar Couchbase Server oficial
              docker run -d --name couchbase-server \
                -p 8091-8096:8091-8096 \
                -p 11210-11211:11210-11211 \
                couchbase:community-7.2.0
              EOF

  tags = {
    Name = "${var.project_name}-couchbase"
  }
}

# ==============================================================================
# SERVIDOR REDIS CACHE (Subred Privada Datos 2 - AZ B)
# ==============================================================================
resource "aws_instance" "redis" {
  ami                    = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI
  instance_type          = "t3.micro"              # Redis es súper ligero, t3.micro es suficiente
  subnet_id              = var.data_subnet_ids[1]  # Se instala en private_data_2 (Alta Disponibilidad cruzada)
  vpc_security_group_ids = [var.db_security_sg]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              
              # Levantar Redis protegido sin contraseña expuesta externamente (solo accesos VPC)
              docker run -d --name redis-cache \
                -p 6379:6379 \
                redis:7-alpine
              EOF

  tags = {
    Name = "${var.project_name}-redis"
  }
}
