# Define a security group for ALB to allow HTTP/HTTPS traffic
resource "aws_security_group" "alb_sg" {
  name   = "${local.service_name}-alb-sg"
  vpc_id = data.aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { "Name" = "${local.service_name}-alb-sg" })
}


resource "aws_lb" "ecs_alb" {
  name               = "${local.service_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = merge(var.tags, { "Name" = "${local.service_name}-alb" })
}

# Define the Target Group
resource "aws_lb_target_group" "ecs_target_group" {
  name     = "${local.service_name}-tg"
  port     = 5010
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = merge(var.tags, { "Name" = "${local.service_name}-tg" })
}

# Define a Listener for the ALB (HTTP Listener on port 80)
resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}