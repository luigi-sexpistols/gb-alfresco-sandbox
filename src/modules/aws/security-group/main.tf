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

variable "ingress_rules" {
  type = map(object({
    protocol = optional(string, "tcp")
    port = number
    cidr_block = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

variable "egress_rules" {
  type = map(object({
    protocol = optional(string, "tcp")
    port = number
    cidr_block = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_security_group" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.this.id
  ip_protocol = each.value.protocol
  from_port = each.value.port
  to_port = each.value.port
  cidr_ipv4 = try(each.value.cidr_block, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)

  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  security_group_id = aws_security_group.this.id
  ip_protocol = each.value.protocol
  from_port = each.value.port
  to_port = each.value.port
  cidr_ipv4 = try(each.value.cidr_block, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)

  tags = {
    Name = each.key
  }
}

output "security_group_id" {
  value = aws_security_group.this.id
}
