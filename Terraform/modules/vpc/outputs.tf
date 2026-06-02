#############################################
# OUTPUTS DE LA VPC
# Se usan en otros módulos (ECS, RDS, ALB)
#############################################

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Lista de subnets públicas"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnets" {
  description = "Lista de subnets privadas"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "public_subnet_1_id" {
  description = "ID de la primera subnet pública"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID de la segunda subnet pública"
  value       = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  description = "ID de la primera subnet privada"
  value       = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "ID de la segunda subnet privada"
  value       = aws_subnet.private_2.id
}

output "availability_zones" {
  description = "Zonas de disponibilidad usadas"
  value = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
}
