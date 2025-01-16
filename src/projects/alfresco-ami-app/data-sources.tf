data "aws_caller_identity" "current" {}

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.root}/../networking/ashley-sbx/terraform.tfstate"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc.id
}

data "aws_subnets" "private" {
  filter {
    name = "subnet-id"
    values = data.terraform_remote_state.networking.outputs.private_subnets.*.id
  }
}

data "aws_subnets" "public" {
  filter {
    name = "subnet-id"
    values = data.terraform_remote_state.networking.outputs.public_subnets.*.id
  }
}

resource "random_shuffle" "instance_subnet_ids_pool" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "instance" {
  id = random_shuffle.instance_subnet_ids_pool.result[0]
}

resource "random_shuffle" "message_queue_subnet_ids_pool" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "message_queue" {
  id = random_shuffle.message_queue_subnet_ids_pool.result[0]
}

data "terraform_remote_state" "alfresco_builder" {
  backend = "local"

  config = {
    path = "${path.root}/../alfresco-ami-2-builder/terraform.tfstate"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "local"

  config = {
    path = "${path.root}/../bastion/ashley-sbx/terraform.tfstate"
  }
}

data "aws_instance" "bastion" {
  instance_id = data.terraform_remote_state.bastion.outputs.instance_id
}

data "aws_security_group" "bastion" {
  id = data.terraform_remote_state.bastion.outputs.reference_security_group_id
}

data "aws_imagebuilder_image_pipeline" "alfresco" {
  arn = data.terraform_remote_state.alfresco_builder.outputs.image_builder_pipeline_arn
}

data "aws_ami" "alfresco" {
  most_recent = true
  owners = [data.aws_caller_identity.current.account_id]

  filter {
    name = "name"
    values = ["${data.aws_imagebuilder_image_pipeline.alfresco.name}-*"]
  }
}
