#############################################
# OUTPUTS TASK DEFINITION
#############################################

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_family" {
  value = aws_ecs_task_definition.this.family
}
