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

variable "retention_in_days" {
  type = number
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  retention_in_days = var.retention_in_days

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
