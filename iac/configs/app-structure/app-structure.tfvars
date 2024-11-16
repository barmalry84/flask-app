base_name = "flask-app"
env = "prod"
tags = {
    "Application": "flask-app-2"
    "Owner": "devops5"
}
task_cpu = 256
task_mem = 512
docker_image = "746669199028.dkr.ecr.eu-west-1.amazonaws.com/flask-app"
docker_image_version = "0.0.6"
task_count = 3
region = "eu-west-1"