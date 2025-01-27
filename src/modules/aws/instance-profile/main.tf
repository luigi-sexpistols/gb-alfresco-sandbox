terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" { type = string }

variable "policy_arns" {
  type = map(string)
  default = {}
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_iam_role" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  role = aws_iam_role.this.name

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_iam_policy_attachment" "this" {
  for_each = var.policy_arns

  name = "${var.name}-${module.name_suffix.result}-${each.key}"
  roles = [aws_iam_role.this.name]
  policy_arn = each.value
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}

output "role_name" {
  value = aws_iam_role.this.name
}
