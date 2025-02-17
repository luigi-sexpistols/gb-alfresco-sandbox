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

# data "aws_iam_policy_document" "alfresco_builder_s3" {
#   statement {
#     effect = "Allow"
#     actions = ["s3:GetObject"]
#     resources = ["${module.image_builder_bucket.bucket.arn}/*"]
#   }
# }

data "aws_ssm_parameter" "base_ami_windows_2025" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2025-English-Full-Base"
}

data "aws_ami" "base_ami_windows_2025" {
  id = data.aws_ssm_parameter.base_ami_windows_2025.value
}

data "aws_ami" "base_ami_rhel9" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }
}
