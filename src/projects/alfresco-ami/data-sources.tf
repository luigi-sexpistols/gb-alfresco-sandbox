data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.root}/../networking/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc.id
}

resource "random_shuffle" "builder_subnet_ids" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "builder" {
  id = random_shuffle.builder_subnet_ids.result[0]
}

resource "random_shuffle" "instance_subnet_ids" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "instance" {
  id = random_shuffle.instance_subnet_ids.result[0]
}

data "aws_subnets" "shared_private" {
  filter {
    name = "subnet-id"
    values = data.terraform_remote_state.networking.outputs.private_subnets.*.id
  }
}

data "aws_subnets" "shared_public" {
  filter {
    name = "subnet-id"
    values = data.terraform_remote_state.networking.outputs.public_subnets.*.id
  }
}

data "terraform_remote_state" "bastion" {
  backend = "local"

  config = {
    path = "${path.root}/../bastion/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_instance" "bastion" {
  instance_id = data.terraform_remote_state.bastion.outputs.instance_id
}

data "aws_security_group" "bastion" {
  id = data.terraform_remote_state.bastion.outputs.reference_security_group_id
}

data "aws_iam_policy_document" "image_builder_bucket" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${module.image_builder_bucket.bucket.arn}/*"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "builder_extra" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${module.image_builder_bucket.bucket.arn}/*"]
  }
}
