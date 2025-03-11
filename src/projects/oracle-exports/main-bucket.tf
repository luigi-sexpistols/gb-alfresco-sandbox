module "exports_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = local.name
  versioning_enabled = false
}

module "iam_role" {
  source = "../../modules/aws/iam-role"

  name = local.name
  assume_role_policy_body = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "export" {
  name = local.name
  policy = data.aws_iam_policy_document.export.json

  tags = {
    Name = local.name
  }
}

resource "aws_iam_role_policy_attachment" "export" {
  role = module.iam_role.role_name
  policy_arn = aws_iam_policy.export.arn
}

resource "aws_kms_key" "exports" {
  policy = data.aws_iam_policy_document.kms.json

  tags = {
    Name = local.name
  }
}
