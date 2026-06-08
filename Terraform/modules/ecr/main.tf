#############################################
# ECR REPOSITORIES - ENUTRITRACK
# 11 imágenes Docker
#############################################

resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repositories)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Project = var.project_name
  }
}
