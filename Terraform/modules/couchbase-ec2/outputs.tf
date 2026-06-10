output "couchbase_instance_id" {
  value = aws_instance.couchbase.id
}

output "couchbase_private_ip" {
  value = aws_instance.couchbase.private_ip
}

output "couchbase_public_ip" {
  value = length(var.public_subnets) > 0 ? aws_instance.couchbase.public_ip : null
}

output "couchbase_admin_url" {
  value = "http://${aws_instance.couchbase.private_ip}:8091"
}

output "couchbase_eip" {
  value = var.assign_eip ? aws_eip.couchbase[0].public_ip : null
}
