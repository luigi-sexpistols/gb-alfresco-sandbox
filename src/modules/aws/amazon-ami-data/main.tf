terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "platform" {
  type = string
}

variable "name" {
  type = string
}

data "aws_ssm_parameter" "base_ami" {
  name = "/aws/service/${var.platform}/${var.name}"
}

data "aws_ami" "base_ami" {
  filter {
    name = "image-id"
    values = [data.aws_ssm_parameter.base_ami.value]
  }
}

output "ami" {
  value = data.aws_ami.base_ami
}
