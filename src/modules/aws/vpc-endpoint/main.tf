terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

data "aws_vpc" "destination" {

}

module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = var.vpc_id

  ingress_rules = {

  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = var.vpc_id
  service_name = var.service_name
  security_group_ids = [module.security_group.security_group_id]

  tags = {
    Name = var.name
  }
}

output "endpoint" {
  value = aws_vpc_endpoint.ssm.dns_entry
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
