module "network" {
  source = "../../modules/services/network"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "shared"
  cidr_block = var.cidr_block
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}

# todo - modularise the s3 bucket below

resource "aws_s3_bucket" "public" {
  bucket = "${var.tenant}-${var.environment}-shared"
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.bucket
  block_public_acls = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls = true
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "public_bucket" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.public.arn}/*"]

    principals {
      identifiers = ["*"]
      type = "*"
    }
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.bucket
  policy = data.aws_iam_policy_document.public_bucket.json
}
