#############################################
# APPLICATION LOAD BALANCER - MICROSERVICIOS
#############################################

resource "aws_lb" "this" {
  name               = "${var.project_name}-alb-microservices"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_sg_id]
  subnets         = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name    = "${var.project_name}-alb-microservices"
    Service = "microservices"
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
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Microservices API Gateway"
      status_code  = "200"
    }
  }
}
