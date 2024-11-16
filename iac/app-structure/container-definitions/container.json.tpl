${jsonencode([
    {
      "name": "${name}",
      "privileged": false,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "eu-west-1",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "flask-app"
        }
      },
      "image": "${app_image}:${app_version}",
      "essential": true,
      "portMappings": [
      {
          "hostPort": "5010",
          "containerPort": "5010",
          "protocol": "tcp"
      }
      ]
    }
]
)}