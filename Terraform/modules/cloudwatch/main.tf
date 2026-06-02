
#############################################
# CLOUDWATCH LOG GROUP FOR ECS
#############################################

resource "aws_cloudwatch_log_group" "ecs_services" {
  for_each = toset(var.ecs_services)

  name              = "/ecs/${each.value}"
  retention_in_days = var.log_retention_days

  tags = {
    Project = var.project_name
    Service = each.value
  }
}

#############################################
# DASHBOARD PRINCIPAL
#############################################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.cluster_name],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS CPU & Memory Usage"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
          title  = "RDS Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", var.redis_cluster_id],
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", var.redis_cluster_id]
          ]
          period = 300
          stat   = "Average"
          title  = "Redis Metrics"
        }
      },
      {
        type = "log"
        properties = {
          title  = "ECS Error Logs"
          region = var.aws_region
          query  = "fields @timestamp, @message | filter @logStream like /ecs/ | filter @message like /(?i)(error|exception|fail)/ | sort @timestamp desc | limit 50"
          time_range = {
            from = "-1h"
            to   = "now"
          }
        }
      }
    ]
  })
}

#############################################
# ALARMAS CRÍTICAS
#############################################

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "ECS CPU utilization is too high"

  dimensions = {
    ServiceName = var.ecs_service_name
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "ECS Memory utilization is too high"

  dimensions = {
    ServiceName = var.ecs_service_name
    ClusterName = var.cluster_name
  }
}
