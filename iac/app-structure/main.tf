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




