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

# deprecated, use `assume_role_policy_body` instead
variable "assuming_services" {
  type = list(string)
  default = null
}

variable "assume_role_policy_body" {
  type = string
  default = null
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

data "aws_iam_policy_document" "assume_role" {
  count = var.assuming_services != null ? 1 : 0

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
  assume_role_policy = (length(data.aws_iam_policy_document.assume_role) > 0
    ? data.aws_iam_policy_document.assume_role.0.json
    : var.assume_role_policy_body)

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
