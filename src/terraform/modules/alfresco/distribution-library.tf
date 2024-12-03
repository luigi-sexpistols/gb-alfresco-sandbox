resource "aws_s3_bucket" "dist" {
  bucket = "${local.name}-dist"

  tags = {
    Name = "${local.name}-dist"
  }
}

resource "aws_s3_bucket_versioning" "dist" {
  bucket = aws_s3_bucket.dist.bucket

  versioning_configuration {
    status = "Disabled"
  }
}
