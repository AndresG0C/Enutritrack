output "url_enutritrack_client" {
  value       = "http://${module.ecs.alb_dns_name}/"
  description = "Plataforma Principal de Clientes y Nutricionistas (React)"
}

output "url_enutritrack_gestion" {
  value       = "http://${module.ecs.alb_dns_name}/admin/auth/login"
  description = "Módulo de Gestión Centralizada (enutritrack-server) - ¡Sin puertos visibles!"
}

output "url_api_gateway" {
  value       = "http://${module.ecs.alb_dns_name}/api"
  description = "Punto de entrada expuesto del API Gateway (enutritrack-microservices)"
}

output "postgres_rds_endpoint" {
  value       = module.database.postgres_endpoint
  description = "Endpoint privado de la base de datos PostgreSQL en RDS"
}

output "ip_publica_bastion" {
  value       = module.vpc.bastion_public_ip
  description = "IP del Bastión de seguridad para auditoría externa de la Base de Datos"
}
