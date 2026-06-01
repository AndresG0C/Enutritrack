# --- 1. Grupo de Seguridad para el Balanceador de Carga (ALB) y Bastión ---
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite trafico HTTP y SSH desde el exterior"
  vpc_id      = var.vpc_id

  # Tráfico Web Público
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tráfico SSH para el Bastión (Acomodado dentro del recurso)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

# --- 2. Grupo de Seguridad para los Contenedores (ECS Fargate) ---
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Permite acceso a los contenedores solo si viene desde el ALB"
  vpc_id      = var.vpc_id

  # Abre el rango de puertos HTTP de tus microservicios (3000 al 3009)
  ingress {
    from_port       = 3000
    to_port         = 3009
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Comunicación interna cruzada entre microservicios
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-ecs-tasks-sg" }
}

# --- 3. Grupo de Seguridad para las Bases de Datos (Postgres, Couchbase, Redis) ---
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Permite acceso exclusivo a los puertos de DB desde los contenedores y el bastion"
  vpc_id      = var.vpc_id

  # Puerto 5433: PostgreSQL (Simplificado en una sola regla para ECS y Bastión)
  ingress {
    from_port       = 5433
    to_port         = 5433
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id, aws_security_group.alb.id]
  }

  # Puerto Couchbase: 8091 (Admin/Web) y 11210 (Data Engine) - Solo desde ECS
  ingress {
    from_port       = 8091
    to_port         = 8091
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }
  ingress {
    from_port       = 11210
    to_port         = 11210
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Puerto 6379: Redis (Solo desde ECS)
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-db-sg" }
}
