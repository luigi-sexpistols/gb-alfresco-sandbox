terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" { type = string }

variable "vpc_id" { type = string }

variable "subnet_ids" { type = set(string) }

variable "ingress_from" {
  type = map(string)
  default = {}
}

module "security_group" {
  source = "../security_group"

  name = "${var.name}-efs"
  vpc_id = var.vpc_id

  ingress_rules = {
    for name, referenced_sg_id in var.ingress_from : name => {
      protocol = "tcp"
      port = 2049
      referenced_security_group_id = referenced_sg_id
      tags = {
        Name = name
      }
    }
  }
}

resource "aws_efs_file_system" "this" {
  creation_token = var.name
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}

resource "aws_efs_mount_target" "this" {
  for_each = var.subnet_ids

  file_system_id = aws_efs_file_system.this.id
  subnet_id = each.value
  security_groups = [module.security_group.security_group_id]
}

output "file_system_id" {
  value = aws_efs_file_system.this.id
}

output "mount_target_dns_name" {
  value = { for k, v in aws_efs_mount_target.this : v.availability_zone_name => v.mount_target_dns_name }
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
