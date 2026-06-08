#############################################
# SECURITY GROUP: ALB
# Expone tráfico público HTTP/HTTPS
#############################################

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

#############################################
# SECURITY GROUP: ECS (FARGATE)
# Recibe tráfico SOLO del ALB
# CMS + Microservicios (3001–4000)
#############################################

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  ingress {
    description     = "ALB to Frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }


  ingress {
    description     = "ALB to ECS (CMS + Microservices)"
    from_port       = 3000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

#############################################
# SECURITY GROUP: RDS (PostgreSQL)
# SOLO acceso desde ECS
# Puerto: 5433
#############################################

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from ECS"
    from_port       = 5433
    to_port         = 5433
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

#############################################
# SECURITY GROUP: REDIS
# Solo ECS puede acceder
# Puerto: 6379
#############################################

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

#############################################
# SECURITY GROUP: COUCHBASE (EC2)
#############################################

resource "aws_security_group" "couchbase" {
  name        = "${var.project_name}-couchbase-sg"
  description = "Security group for Couchbase EC2"
  vpc_id      = var.vpc_id

  ##################################################
  # SSH - SOLO TU IP
  ##################################################
  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ##################################################
  # ADMIN UI - SOLO TU IP
  ##################################################
  ingress {
    description = "Couchbase Admin UI"
    from_port   = 8091
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ##################################################
  # CLUSTER MANAGER - ECS
  ##################################################
  ingress {
    description     = "Couchbase Cluster Manager from ECS"
    from_port       = 8091
    to_port         = 8091
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ##################################################
  # VIEWS / INDEX
  ##################################################
  ingress {
    description     = "Couchbase Views from ECS"
    from_port       = 8092
    to_port         = 8092
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ##################################################
  # QUERY (N1QL)
  ##################################################
  ingress {
    description     = "Couchbase Query from ECS"
    from_port       = 8093
    to_port         = 8093
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ##################################################
  # SEARCH (FTS)
  ##################################################
  ingress {
    description     = "Couchbase Search from ECS"
    from_port       = 8094
    to_port         = 8094
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ##################################################
  # DATA SERVICE (SDK)
  ##################################################
  ingress {
    description     = "Couchbase Data Service from ECS"
    from_port       = 11210
    to_port         = 11210
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ##################################################
  # SALIDA
  ##################################################
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-couchbase-sg"
  }
}
