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

variable "assuming_services" {
  type = list(string)
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = var.assuming_services
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = var.name
  }
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}
