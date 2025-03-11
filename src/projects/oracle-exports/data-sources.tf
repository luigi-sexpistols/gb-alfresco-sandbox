data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data"
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


data "aws_iam_policy_document" "kms" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [module.iam_role.role_arn]
    }
  }

  statement {
    effect = "Allow"
    actions = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["export.rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "export" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.exports_bucket.bucket_arn,
      "${module.exports_bucket.bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant"
    ]
    resources = [aws_kms_key.exports.arn]
  }
}
