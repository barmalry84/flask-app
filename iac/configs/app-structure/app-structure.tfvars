base_name = "flask-app"
env = "prod"
tags = {
    "Application": "flask-app"
    "Owner": "devops5"
}
task_cpu = 256
task_mem = 512
docker_image = "746669199028.dkr.ecr.eu-west-1.amazonaws.com/flask-app"
task_count = 3
region = "eu-west-1"