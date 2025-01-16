data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.root}/../networking/ashley-sbx/terraform.tfstate"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc.id
}

resource "random_shuffle" "builder_subnet_ids_pool" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "builder" {
  id = random_shuffle.builder_subnet_ids_pool.result[0]
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
