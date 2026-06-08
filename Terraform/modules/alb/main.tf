#############################################
# APPLICATION LOAD BALANCER - FRONTEND
#############################################

resource "aws_lb" "this" {
  name               = "${var.project_name}-alb-frontend"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_sg_id]
  subnets         = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name    = "${var.project_name}-alb-frontend"
    Service = "frontend"
  }
}

#############################################
# LISTENER HTTP (80)
#############################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

#############################################
# TARGET GROUP: FRONTEND (puerto 5174)
#############################################

resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-tg-frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health.html"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Service = "frontend"
    Name    = "${var.project_name}-tg-frontend"
  }
}
