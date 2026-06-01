output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "ID del Security Group del Balanceador de Carga"
}

output "ecs_tasks_sg_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "ID del Security Group de las tareas de ECS"
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "ID del Security Group de las Bases de Datos"
}
