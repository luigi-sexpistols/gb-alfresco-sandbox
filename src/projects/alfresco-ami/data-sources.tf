data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data"
}

data "terraform_remote_state" "alfresco_builder" {
  backend = "s3"

  config = {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "alfresco-ami-builder/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

resource "random_shuffle" "instance_subnet_ids_pool" {
  input = module.network_data.private_subnets.*.id
}

data "aws_subnet" "instance" {
  id = random_shuffle.instance_subnet_ids_pool.result[0]
}

resource "random_shuffle" "message_queue_subnet_ids_pool" {
  input = module.network_data.private_subnets.*.id
}

data "aws_subnet" "message_queue" {
  id = random_shuffle.message_queue_subnet_ids_pool.result[0]
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
