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

data "aws_caller_identity" "this" {}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = "${var.name}-${module.name_suffix.result}"

  distribution {
    region = "ap-southeast-2"

    ami_distribution_configuration {
      name = "${var.name}-{{ imagebuilder:buildDate }}"
      target_account_ids = [data.aws_caller_identity.this.account_id]

      ami_tags = {
        Name = "${var.name}-{{ imagebuilder:buildDate }}"
      }
    }
  }

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

output "distribution_configuration_id" {
  value = aws_imagebuilder_distribution_configuration.this.id
}

output "distribution_configuration_arn" {
  value = aws_imagebuilder_distribution_configuration.this.arn
}
