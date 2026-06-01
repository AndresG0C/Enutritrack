output "postgres_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "Direccion de conexion para PostgreSQL"
}

output "couchbase_private_ip" {
  value       = aws_instance.couchbase.private_ip
  description = "IP privada del servidor Couchbase"
}

output "redis_private_ip" {
  value       = aws_instance.redis.private_ip
  description = "IP privada del servidor Redis"
}
