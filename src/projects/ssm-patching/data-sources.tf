data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data"
}

module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
}

module "linux_ami" {
  source = "../../modules/aws/amazon-ami-data"

  platform = "ami-amazon-linux-latest"
  name = "al2023-ami-kernel-default-x86_64"
}

resource "random_shuffle" "subnet_id_pool" {
  input = module.network_data.private_subnets.*.id
}

data "aws_subnet" "instance" {
  id = random_shuffle.subnet_id_pool.result[0]
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "maintenance_window" {
  name = "AmazonSSMMaintenanceWindowRole"
}

data "aws_iam_policy" "logging" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "service_role_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "service_role_pass_role" {
  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "instance_s3" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${module.baselines_bucket.bucket_arn}/*"]
  }
}
