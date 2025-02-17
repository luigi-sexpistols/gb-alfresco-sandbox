terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name_prefix" {
  type = string
}

variable "name" {
  type = string
}

variable "ver" {
  type = string
  # todo - validate semver
}

variable "platform" {
  type = string
  default = "Linux"
}

variable "data" {
  type = string
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_imagebuilder_component" "this" {
  name = "${var.name_prefix}-${module.name_suffix.result}-${var.name}"
  version = var.ver
  platform = var.platform
  data = var.data

  tags = {
    Name = "${var.name_prefix}-${module.name_suffix.result}-${var.name}"
  }
}

output "component_id" {
  value = aws_imagebuilder_component.this.id
}

output "component_arn" {
  value = aws_imagebuilder_component.this.arn
}

output "component_name" {
  value = aws_imagebuilder_component.this.name
}
