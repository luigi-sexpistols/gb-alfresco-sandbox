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

data "aws_iam_policy_document" "builder_extra" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${module.image_builder_bucket.bucket.arn}/*"]
  }
}
