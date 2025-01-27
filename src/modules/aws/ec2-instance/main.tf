terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}

data "aws_subnet" "destination" {
  filter {
    name = "subnet-id"
    values = [var.subnet_id]
  }
}

data "aws_vpc" "destination" {
  filter {
    name = "vpc-id"
    values = [data.aws_subnet.destination.vpc_id]
  }
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

module "key_pair" {
  source = "../key-pair"

  name = var.name
}

module "instance_profile" {
  source = "../instance-profile"

  name = var.name
}


module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_instance" "this" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.destination.id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = concat([module.security_group.security_group_id], var.security_group_ids)
  key_name = module.key_pair.key_name
  iam_instance_profile = module.instance_profile.instance_profile_name

  tags = merge({ Name = "${var.name}-${module.name_suffix.result}" }, var.tags)
}

output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip_address" {
  value = aws_instance.this.private_ip
}

output "public_ip_address" {
  value = aws_instance.this.public_ip
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "ssh_private_key" {
  value = module.key_pair.private_key
  sensitive = true
  depends_on = [aws_instance.this]
}

output "availability_zone" {
  value = aws_instance.this.availability_zone
}

output "instance_profile_name" {
  value = aws_instance.this.iam_instance_profile
}

output "iam_role_name" {
  value = aws_instance.this.iam_instance_profile
}
