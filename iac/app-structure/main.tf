locals {
  cluster_name      = format("%s-%s-cluster", var.base_name, var.env)
  cw_log_group_name = format("%s-%s-log_group", var.base_name, var.env)
  task_role_name    = format("%s-%s-task_role", var.base_name, var.env)
  task_policy_name  = format("%s-%s-task_policy", var.base_name, var.env)
  sec_group         = format("%s-%s-sec_group", var.base_name, var.env)
  task_name         = format("%s-%s-task", var.base_name, var.env)
  service_name      = format("%s-%s-service", var.base_name, var.env)
}

#### ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(var.tags, { "Name" = local.cluster_name })
}

#### Cloudwatch Log group
resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name              = local.cw_log_group_name
  retention_in_days = 7
  tags              = merge(var.tags, { "Name" = local.cw_log_group_name })
}

#### IAM role + policies
resource "aws_iam_role" "ecs_task_role" {
  name = local.task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
  tags = merge(var.tags, { "Name" = local.task_role_name })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name = local.task_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["ecr:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

#### Security group
resource "aws_security_group" "fargate" {

  name   = local.sec_group
  vpc_id = data.aws_vpc.main_vpc.id
  tags   = merge(var.tags, { "Name" = local.sec_group })
}

resource "aws_security_group_rule" "ingress" {

  type              = "ingress"
  from_port         = 5010
  to_port           = 5010
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate.id
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate.id
}

### Task definition
resource "aws_ecs_task_definition" "task" {
  family                   = local.task_name
  container_definitions    = data.template_file.task.rendered
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_mem
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  tags                     = merge(var.tags, { "Name" = local.task_name }, { "Cluster" = local.cluster_name })
}

data "template_file" "task" {
  template = templatefile("${path.module}/container-definitions/container.json.tpl", {

    name        = "flask-app"
    log_group   = local.cw_log_group_name
    app_image   = var.docker_image
    app_version = var.docker_image_version
  })
}

# Service
resource "aws_ecs_service" "service" {

  name                              = local.service_name
  launch_type                       = "FARGATE"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.task.arn
  desired_count                     = var.task_count
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [aws_security_group.fargate.id]
  }

  tags = merge(var.tags, { "Name" = local.service_name }, { "Cluster" = local.cluster_name })
}




