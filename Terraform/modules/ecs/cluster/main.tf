#############################################
# ECS CLUSTER - ENUTRITRACK
# Fargate only (serverless)
#############################################

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = var.project_name
  }
}
