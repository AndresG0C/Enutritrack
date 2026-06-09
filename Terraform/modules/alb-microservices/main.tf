# modules/alb-microservices/main.tf

resource "aws_lb" "microservices" {
  name               = "${var.project_name}-microservices"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.microservices_alb.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name        = "${var.project_name}-microservices"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ============================================
# TARGET GROUPS PARA CADA MICROSERVICIO
# ============================================

# Users (puerto 3001)
resource "aws_lb_target_group" "users" {
  name        = "${var.project_name}-users-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/users/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-users-tg"
  }
}

# Medical History (puerto 3002)
resource "aws_lb_target_group" "medical_history" {
  name        = "${var.project_name}-medical-history-tg"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/medical-history/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-medical-history-tg"
  }
}

# Nutrition (puerto 3003)
resource "aws_lb_target_group" "nutrition" {
  name        = "${var.project_name}-nutrition-tg"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/nutrition/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-nutrition-tg"
  }
}

# Auth (puerto 3004)
resource "aws_lb_target_group" "auth" {
  name        = "${var.project_name}-auth-tg"
  port        = 3004
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/auth/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-auth-tg"
  }
}

# Activity (puerto 3005)
resource "aws_lb_target_group" "activity" {
  name        = "${var.project_name}-activity-tg"
  port        = 3005
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/physical-activity/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-activity-tg"
  }
}

# Recommendation (puerto 3006)
resource "aws_lb_target_group" "recommendation" {
  name        = "${var.project_name}-recommendation-tg"
  port        = 3006
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/recommendations/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-recommendation-tg"
  }
}

# Doctor (puerto 3007)
resource "aws_lb_target_group" "doctor" {
  name        = "${var.project_name}-doctor-tg"
  port        = 3007
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/doctors/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-doctor-tg"
  }
}

# Citas (puerto 3008)
resource "aws_lb_target_group" "citas" {
  name        = "${var.project_name}-citas-tg"
  port        = 3008
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/citas-medicas/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-citas-tg"
  }
}

# Alertas (puerto 3009)
resource "aws_lb_target_group" "alertas" {
  name        = "${var.project_name}-alertas-tg"
  port        = 3009
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/alerts/health/check"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-alertas-tg"
  }
}

# ============================================
# LISTENER PRINCIPAL (SOLO HTTP - SIN SSL)
# ============================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.microservices.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({
        error   = "Service not found",
        message = "The requested endpoint does not exist"
      })
      status_code = "404"
    }
  }
}

# ============================================
# REGLAS DE ENRUTAMIENTO
# ============================================

# Users
resource "aws_lb_listener_rule" "users" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.users.arn
  }

  condition {
    path_pattern {
      values = ["/users*"]
    }
  }
}

# Medical History
resource "aws_lb_listener_rule" "medical_history" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.medical_history.arn
  }

  condition {
    path_pattern {
      values = ["/medical-history*"]
    }
  }
}

# Nutrition
resource "aws_lb_listener_rule" "nutrition" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nutrition.arn
  }

  condition {
    path_pattern {
      values = ["/nutrition*"]
    }
  }
}

# Auth
resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth*"]
    }
  }
}

# Activity
resource "aws_lb_listener_rule" "activity" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 140

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.activity.arn
  }

  condition {
    path_pattern {
      values = ["/physical-activity*"]
    }
  }
}

# Recommendation
resource "aws_lb_listener_rule" "recommendation" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 150

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.recommendation.arn
  }

  condition {
    path_pattern {
      values = ["/recommendation*"]
    }
  }
}

# Doctor
resource "aws_lb_listener_rule" "doctor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 160

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doctor.arn
  }

  condition {
    path_pattern {
      values = ["/doctor*"]
    }
  }
}

# Citas
resource "aws_lb_listener_rule" "citas" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 170

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.citas.arn
  }

  condition {
    path_pattern {
      values = ["/citas*"]
    }
  }
}

# Alertas
resource "aws_lb_listener_rule" "alertas" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 180

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alertas.arn
  }

  condition {
    path_pattern {
      values = ["/alerts*"]
    }
  }
}

# ============================================
# SECURITY GROUP PARA EL ALB PÚBLICO
# ============================================

resource "aws_security_group" "microservices_alb" {
  name        = "${var.project_name}-microservices-sg"
  description = "Security group for public microservices ALB"
  vpc_id      = var.vpc_id

  # Regla única para HTTP desde Frontend y CMS (combinados)
  ingress {
    description     = "HTTP from Frontend and CMS ALBs"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  # HTTP desde internet (para apps móviles)
  ingress {
    description = "HTTP from internet (mobile apps)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida a internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-microservices-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}
