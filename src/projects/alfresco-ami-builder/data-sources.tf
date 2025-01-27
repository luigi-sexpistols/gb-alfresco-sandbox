module "networking_data" {
  source = "../../modules/utils/networking-data"
}

resource "random_shuffle" "builder_subnet_ids_pool" {
  input = module.networking_data.private_subnets.*.id
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

data "aws_iam_policy_document" "alfresco_builder_s3" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${module.image_builder_bucket.bucket.arn}/*"]
  }
}

data "aws_ami" "alfresco_builder" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }
}
