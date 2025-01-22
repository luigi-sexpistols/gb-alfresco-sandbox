terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
variable "name" {
  type = string
}

variable "retention_in_days" {
  type = number
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.name
  retention_in_days = var.retention_in_days

  tags = {
    Name = var.name
  }
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
