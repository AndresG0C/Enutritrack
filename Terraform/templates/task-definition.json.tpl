[
  {
    "name": "${service_name}",
    "image": "${image}",
    "essential": true,

    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port},
        "protocol": "tcp"
      }
    ],

    "environment": [
      %{ for env in env_vars ~}
      {
        "name": "${env.name}",
        "value": "${env.value}"
      }%{ if env != env_vars[length(env_vars)-1] },%{ endif }
      %{ endfor ~}
    ],

    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${service_name}",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]