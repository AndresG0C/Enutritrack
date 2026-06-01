# --- Clúster ECS Fargate ---
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# --- CloudWatch Logs para centralizar logs de NestJS y React ---
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

# --- Application Load Balancer (ALB Público) ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.public_subnets

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client.arn
  }
}

# ==============================================================================
# 1. FRONTEND: enutritrack-client (React apuntando a ECR)
# ==============================================================================
resource "aws_ecs_task_definition" "client" {
  family                   = "${var.project_name}-client"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::127348835096:role/LabRole"
  task_role_arn            = "arn:aws:iam::127348835096:role/LabRole"

  container_definitions = templatefile("${path.root}/templates/container_definition.json.tpl", {
    container_name = "enutritrack-client"
    image_url      = "127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-client:latest"
    container_port = 80
    db_host        = ""
    db_username    = ""
    db_password    = ""
    db_name        = ""
    couchbase_host = ""
    redis_host     = ""
    log_group      = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_lb_target_group" "client" {
  name        = "${var.project_name}-tg-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health.html"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 20
  }
}

resource "aws_ecs_service" "client" {
  name            = "${var.project_name}-client"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.client.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [var.ecs_tasks_sg]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.client.arn
    container_name   = "enutritrack-client"
    container_port   = 80
  }
}

# ==============================================================================
# 2. API GATEWAY: enutritrack-microservices-gateway (Apuntando a ECR)
# ==============================================================================
resource "aws_ecs_task_definition" "gateway" {
  family                   = "${var.project_name}-gateway"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::127348835096:role/LabRole"
  task_role_arn            = "arn:aws:iam::127348835096:role/LabRole"

  container_definitions = templatefile("${path.root}/templates/container_definition.json.tpl", {
    container_name = "enutritrack-gateway"
    image_url      = "127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-gateway:latest"
    container_port = 3000
    db_host        = element(split(":", var.postgres_endpoint), 0)
    db_username    = var.db_username
    db_password    = var.db_password
    db_name        = var.db_name
    couchbase_host = var.couchbase_private_ip
    redis_host     = var.redis_private_ip
    log_group      = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_lb_target_group" "gateway" {
  name        = "${var.project_name}-tg-gateway"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health/health" # Ajustado
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 20
  }
}

resource "aws_lb_listener_rule" "gateway" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
  condition {
    path_pattern { values = ["/api", "/api/*"] }
  }
}

resource "aws_ecs_service" "gateway" {
  name            = "${var.project_name}-gateway"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.gateway.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [var.ecs_tasks_sg]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.gateway.arn
    container_name   = "enutritrack-gateway"
    container_port   = 3000
  }
}

# ==============================================================================
# 3. SERVER CENTRAL: enutritrack-server (Migrado a puerto 4000 y ruta /admin)
# ==============================================================================
resource "aws_ecs_task_definition" "server" {             # 👈 Cambiado de "cms" a "server"
  family                   = "${var.project_name}-server" # 👈 Nombre de familia limpio
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::127348835096:role/LabRole"
  task_role_arn            = "arn:aws:iam::127348835096:role/LabRole"

  container_definitions = templatefile("${path.root}/templates/container_definition.json.tpl", {
    container_name = "enutritrack-server"                                                                     # 👈 Nombre del contenedor unificado
    image_url      = "127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-server:latest" # 👈 Nueva ruta del repositorio
    container_port = 4000
    db_host        = element(split(":", var.postgres_endpoint), 0)
    db_username    = var.db_username
    db_password    = var.db_password
    db_name        = var.db_name
    couchbase_host = ""
    redis_host     = ""
    log_group      = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_lb_target_group" "cms" {
  name        = "${var.project_name}-tg-cms"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 20
  }
}

resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cms.arn
  }
  condition {
    path_pattern { values = ["/admin", "/admin/*"] }
  }
}

resource "aws_ecs_service" "server" {
  name            = "${var.project_name}-server"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.server.arn # 👈 Apunta al nuevo recurso .server
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [var.ecs_tasks_sg]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cms.arn
    container_name   = "enutritrack-server" # 👈 Vinculado al nuevo nombre de contenedor
    container_port   = 4000
  }
}

# --- Mapa local con los microservicios restantes ---
locals {
  microservices = {
    auth            = { repo = "enutritrack-microservices-auth", port = 3001 }
    users           = { repo = "enutritrack-microservices-users", port = 3002 }
    doctor          = { repo = "enutritrack-microservices-doctor", port = 3003 }
    nutrition       = { repo = "enutritrack-microservices-nutrition", port = 3004 }
    activity        = { repo = "enutritrack-microservices-activity", port = 3005 }
    recommendation  = { repo = "enutritrack-microservices-recommendation", port = 3006 }
    medical-history = { repo = "enutritrack-microservices-medical-history", port = 3007 }
    citas           = { repo = "enutritrack-microservices-citas", port = 3008 }
    alertas         = { repo = "enutritrack-microservices-alertas", port = 3009 }
  }
}

# ==============================================================================
# 4. MICROSERVICIOS DINÁMICOS (Apuntando a ECR de forma automatizada)
# ==============================================================================
resource "aws_ecs_task_definition" "services" {
  for_each                 = local.microservices
  family                   = "${var.project_name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::127348835096:role/LabRole"
  task_role_arn            = "arn:aws:iam::127348835096:role/LabRole"

  container_definitions = templatefile("${path.root}/templates/container_definition.json.tpl", {
    container_name = each.value.repo
    image_url      = "127348835096.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-${each.key}:latest"
    container_port = each.value.port
    db_host        = element(split(":", var.postgres_endpoint), 0)
    db_username    = var.db_username
    db_password    = var.db_password
    db_name        = var.db_name
    couchbase_host = var.couchbase_private_ip
    redis_host     = var.redis_private_ip
    log_group      = aws_cloudwatch_log_group.ecs.name
    aws_region     = var.aws_region
  })
}

resource "aws_ecs_service" "services" {
  for_each        = local.microservices
  name            = "${var.project_name}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnets
    security_groups  = [var.ecs_tasks_sg]
    assign_public_ip = true
  }
}
