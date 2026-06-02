output "autoscaling_target_id" {
  value = aws_appautoscaling_target.ecs_service.id
}

output "scale_out_policy_arn" {
  value = aws_appautoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  value = aws_appautoscaling_policy.scale_in.arn
}
