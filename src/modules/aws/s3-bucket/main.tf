terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" { type = string }

variable "versioning_enabled" { type = bool }

variable "bucket_policy" {
  type = string
  default = null
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-${module.name_suffix.result}"

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = var.bucket_policy != null ? var.bucket_policy : ""
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

# DEPRECATED - do not use
output "bucket" {
  value = {
    id = aws_s3_bucket.this.id
    arn = aws_s3_bucket.this.arn
    bucket = aws_s3_bucket.this.bucket
  }
}
