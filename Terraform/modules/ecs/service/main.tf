#############################################
# ECS SERVICE - ENUTRITRACK
# Fargate + ALB + Autoscaling
#############################################

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  platform_version = "LATEST"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = {
    Project = var.project_name
  }
}
