#############################################
# AUTO SCALING TARGET (ECS SERVICE)
# Min: 1, Max: 2
#############################################

resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#############################################
# SCALING POLICY BASADA EN CPU
# Escala cuando CPU > 70%, reduce cuando CPU < 40%
#############################################

resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300 # 5 minutos para reducir
    scale_out_cooldown = 60  # 1 minuto para escalar
  }
}
