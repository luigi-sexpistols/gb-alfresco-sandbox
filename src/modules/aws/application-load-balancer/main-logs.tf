data "aws_caller_identity" "current" {
  count = var.enable_access_logging ? 1 : 0
}

data "aws_iam_policy_document" "access_logs_bucket" {
  count = var.enable_access_logging ? 1 : 0

  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      module.access_logs_bucket.0.bucket_arn,
      "${module.access_logs_bucket.0.bucket_arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::783225319266:root"]
    }
  }
}

module "access_logs_bucket" {
  source = "../s3-bucket"
  count = var.enable_access_logging ? 1 : 0

  name = "${var.name}-access-logs"
  versioning_enabled = false
  bucket_policy = data.aws_iam_policy_document.access_logs_bucket.0.json
}
