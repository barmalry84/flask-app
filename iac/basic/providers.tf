provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "devops5-tf-state"
    key = "iac/basic.tfstate"
    region = "eu-west-1"
  }
}