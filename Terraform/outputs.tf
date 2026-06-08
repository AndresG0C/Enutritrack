output "rds_address" {
  value = module.rds.rds_address
}

output "rds_port" {
  value = module.rds.rds_port
}

output "alb_frontend_dns" {
  value = module.alb_frontend.alb_dns_name
}

output "alb_cms_dns" {
  value = module.alb_cms.alb_dns_name
}

output "redis_endpoint" {
  value = module.redis.redis_endpoint
}

output "couchbase_private_ip" {
  value = module.couchbase.couchbase_private_ip
}

output "couchbase_public_ip" {
  value = module.couchbase.couchbase_public_ip
}
