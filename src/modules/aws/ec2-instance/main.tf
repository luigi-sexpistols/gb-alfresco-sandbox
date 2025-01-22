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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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

variable "instance_profile_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "key_pair_name" {
  type = string
  default = null
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

resource "random_string" "sg_suffix" {
  length = 5
  upper = false
  lower = true
  special = false
  numeric = false
}

resource "tls_private_key" "this" {
  count = var.key_pair_name == null ? 1 : 0

  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "this" {
  count = var.key_pair_name == null ? 1 : 0

  public_key = tls_private_key.this.0.public_key_openssh
}

module "security_group" {
  source = "../security-group"

  name = "${var.name}-${random_string.sg_suffix.result}"
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_instance" "this" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.destination.id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = concat([module.security_group.security_group_id], var.security_group_ids)
  key_name = var.key_pair_name != null ? var.key_pair_name : aws_key_pair.this.0.key_name
  iam_instance_profile = var.instance_profile_name

  tags = merge({ Name = var.name }, var.tags)
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
  value = var.key_pair_name == null ? tls_private_key.this.0.private_key_pem : "provided key"
  sensitive = true
  depends_on = [aws_instance.this]
}

output "availability_zone" {
  value = aws_instance.this.availability_zone
}
