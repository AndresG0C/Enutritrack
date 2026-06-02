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
# SCALE OUT POLICY (CPU >= 70%)
# Escala de 1 a 2 cuando la CPU supera 70%
#############################################

resource "aws_appautoscaling_policy" "scale_out" {
  name               = "${var.service_name}-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 70.0
      scaling_adjustment          = 1
    }
  }
}

#############################################
# SCALE IN POLICY (CPU <= 40%)
# Escala de 2 a 1 cuando la CPU baja a 40% o menos
#############################################

resource "aws_appautoscaling_policy" "scale_in" {
  name               = "${var.service_name}-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 40.0
      scaling_adjustment          = -1
    }
  }
}

#############################################
# CLOUDWATCH ALARM PARA ESCALAR (CPU >= 70%)
#############################################

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "CPU > 70% - escalar servicio"

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out.arn]
}

#############################################
# CLOUDWATCH ALARM PARA REDUCIR (CPU <= 40%)
#############################################

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.service_name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 40
  alarm_description   = "CPU <= 40% - reducir servicio"

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in.arn]
}
