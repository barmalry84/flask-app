variable "cidr_base" {
  description = "IPv4 VPC range"
  #default     = "10.3.0.0/16"
}

variable "private_subnets" {
  description = "List of CIDR ranges for the private subnets"
  #default     = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
}

variable "public_subnets" {
  description = "List of CIDR ranges for the public subnets"
  #default     = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]
}

variable "region" {
  description = "Region to run"
}

variable "azs" {
}

variable "vpc_name" {
  description = "VPC name"
}