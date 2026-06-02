#############################################
# REDIS SUBNET GROUP
#############################################

resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.project_name}-redis-subnet-group"
  description = "Subnet group for Redis"
  subnet_ids  = var.private_subnets
}

#############################################
# REDIS CLUSTER
#############################################

resource "aws_elasticache_cluster" "this" {
  cluster_id = "${var.project_name}-redis-${var.environment}"

  engine          = "redis"
  engine_version  = "7.1"
  node_type       = var.node_type
  num_cache_nodes = 1

  port = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.security_group_id]

  parameter_group_name = "default.redis7"

  apply_immediately = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-redis"
  }
}
