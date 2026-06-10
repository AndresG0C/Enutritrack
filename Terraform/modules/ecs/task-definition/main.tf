#############################################
# ECS TASK DEFINITION MODULE
# Reutilizable para todos los microservicios
#############################################

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = templatefile(
    "${path.root}/templates/task-definition.json.tpl",
    {
      service_name   = var.service_name
      image          = var.image
      container_port = var.container_port
      env_vars       = var.env_vars
    }
  )

  tags = {
    Project = var.project_name
  }
}
