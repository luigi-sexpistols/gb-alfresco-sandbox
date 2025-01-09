terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "security_group_id" {
  type = string
}

variable "ingress" {
  type = map(object({
    protocol = optional(string, "tcp")
    port = number
    referenced_security_group_id = optional(string)
    cidr_block = optional(string)
  }))
  default = {}
}

variable "egress" {
  type = map(object({
    protocol = optional(string, "tcp")
    port = number
    referenced_security_group_id = optional(string)
    cidr_block = optional(string)
  }))
  default = {}
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress

  security_group_id = var.security_group_id
  ip_protocol = each.value.protocol
  from_port = each.value.port
  to_port = each.value.port
  referenced_security_group_id = each.value.referenced_security_group_id
  cidr_ipv4 = each.value.cidr_block

  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress

  security_group_id = var.security_group_id
  ip_protocol = each.value.protocol
  from_port = each.value.port
  to_port = each.value.port
  referenced_security_group_id = each.value.referenced_security_group_id
  cidr_ipv4 = each.value.cidr_block

  tags = {
    Name = each.key
  }
}
