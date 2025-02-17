module "image_builder_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "${local.name_prefix}-image-builder-files"
  versioning_enabled = false
  bucket_policy = data.aws_iam_policy_document.image_builder_bucket.json
}
