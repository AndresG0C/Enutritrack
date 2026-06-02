#############################################
# IAM OUTPUTS
#############################################

output "labrole_arn" {
  description = "ARN del LabRole (AWS Academy)"
  value       = data.aws_iam_role.labrole.arn
}

output "labrole_name" {
  description = "Nombre del LabRole"
  value       = data.aws_iam_role.labrole.name
}
