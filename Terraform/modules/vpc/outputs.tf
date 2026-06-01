output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID de la VPC principal"
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "app_subnet_ids" {
  value = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
}

output "data_subnet_ids" {
  value = [aws_subnet.private_data_1.id, aws_subnet.private_data_2.id]
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
