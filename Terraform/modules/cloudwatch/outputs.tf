output "log_group_names" {
  value = { for k, v in aws_cloudwatch_log_group.ecs_services : k => v.name }
}

output "dashboard_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-dashboard"
}
