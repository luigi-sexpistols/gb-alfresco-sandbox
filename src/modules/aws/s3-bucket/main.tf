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
}

resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = {
    Name = var.name
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

output "bucket" {
  value = {
    id = aws_s3_bucket.this.id
    arn = aws_s3_bucket.this.arn
    bucket = aws_s3_bucket.this.bucket
  }
}
