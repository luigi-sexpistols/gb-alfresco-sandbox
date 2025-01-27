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

variable "subnet_id" {
  type = string
}

variable "terminate_on_fail" {
  type = bool
  default = false
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy" "instance_profile_for_image_builder" {
  name = "EC2InstanceProfileForImageBuilder"
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "build_permissions" {
  statement {
    effect = "Allow"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:aws:ec2::${data.aws_caller_identity.this.account_id}:instance/*",
      "arn:aws:ssm::${data.aws_caller_identity.this.account_id}:document/*"
    ]
  }
}

data "aws_subnet" "destination" {
  id = var.subnet_id
}

data "aws_vpc" "destination" {
  id = data.aws_subnet.destination.vpc_id
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_iam_policy" "builder" {
  name = "${var.name}-${module.name_suffix.result}"
  policy = data.aws_iam_policy_document.build_permissions.json
}

module "instance_profile" {
  source = "../instance-profile"

  name = var.name

  policy_arns = {
    "instance-profile" = data.aws_iam_policy.instance_profile_for_image_builder.arn,
    "ssm-instance-core" = data.aws_iam_policy.ssm_managed_instance_core.arn,
    "builder" = aws_iam_policy.builder.arn
  }
}

module "key_pair" {
  source = "../key-pair"

  name = var.name
}

module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = data.aws_vpc.destination.id

  egress_rules = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  subnet_id = data.aws_subnet.destination.id
  key_pair = module.key_pair.key_name
  instance_profile_name = module.instance_profile.instance_profile_name
  instance_types = ["t3.micro"]
  security_group_ids = [module.security_group.security_group_id]

  instance_metadata_options {
    http_tokens = "required"
  }

  terminate_instance_on_failure = var.terminate_on_fail

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "infrastructure_config_id" {
  value = aws_imagebuilder_infrastructure_configuration.this.id
}

output "iam_role_name" {
  value = module.instance_profile.role_name
}
