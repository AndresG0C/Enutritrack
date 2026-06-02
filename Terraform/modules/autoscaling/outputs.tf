output "autoscaling_target_id" {
  description = "ID del target de autoscaling"
  value       = aws_appautoscaling_target.ecs_service.id
}

output "cpu_policy_arn" {
  description = "ARN de la política de escalado por CPU"
  value       = aws_appautoscaling_policy.cpu_policy.arn
}
