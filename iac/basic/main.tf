module "vpc-module" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "v5.15.0"
  name                   = var.vpc_name
  cidr                   = var.cidr_base
  azs                    = var.azs
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
}

resource "aws_ecr_repository" "flask-app" {
  name                 = "flask-app"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}