data "aws_vpc" "main_vpc" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["main-vpc-private*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["main-vpc-public*"]
  }
}