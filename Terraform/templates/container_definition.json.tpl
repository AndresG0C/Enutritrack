[
  {
    "name": "${container_name}",
    "image": "${image_url}",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      { "name": "NODE_ENV", "value": "production" },
      { "name": "PORT", "value": "${container_port}" },
      { "name": "DB_HOST", "value": "${db_host}" },
      { "name": "DB_PORT", "value": "5433" },
      { "name": "DB_USERNAME", "value": "${db_username}" },
      { "name": "DB_PASSWORD", "value": "${db_password}" },
      { "name": "DB_DATABASE", "value": "${db_name}" },
      { "name": "COUCHBASE_HOST", "value": "${couchbase_host}" },
      { "name": "REDIS_HOST", "value": "${redis_host}" },
      { "name": "REDIS_PORT", "value": "6379" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]