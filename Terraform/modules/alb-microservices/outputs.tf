# modules/alb-microservices/outputs.tf

output "alb_dns_name" {
  value = aws_lb.microservices.dns_name
}

output "alb_zone_id" {
  value = aws_lb.microservices.zone_id
}

output "alb_sg_id" {
  value = aws_security_group.microservices_alb.id # ← Referencia directa, no module.self
}

# Target groups ARNs
output "users_target_group_arn" {
  value = aws_lb_target_group.users.arn
}

output "medical_history_target_group_arn" {
  value = aws_lb_target_group.medical_history.arn
}

output "nutrition_target_group_arn" {
  value = aws_lb_target_group.nutrition.arn
}

output "auth_target_group_arn" {
  value = aws_lb_target_group.auth.arn
}

output "activity_target_group_arn" {
  value = aws_lb_target_group.activity.arn
}

output "recommendation_target_group_arn" {
  value = aws_lb_target_group.recommendation.arn
}

output "doctor_target_group_arn" {
  value = aws_lb_target_group.doctor.arn
}

output "citas_target_group_arn" {
  value = aws_lb_target_group.citas.arn
}

output "alertas_target_group_arn" {
  value = aws_lb_target_group.alertas.arn
}
