terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type = string
}

variable "operating_system" {
  type = string
}

variable "patch_filters" {
  type = map(list(string))
}

variable "approve_until_date" {
  type = string
}

resource "aws_ssm_patch_baseline" "this" {
  name = var.name
  operating_system = var.operating_system
  approved_patches = []
  rejected_patches = []

  global_filter {
    key = "PRODUCT"
    values = ["AmazonLinux2023"]
  }

  approval_rule {
    approve_until_date = var.approve_until_date

    dynamic "patch_filter" {
      for_each = var.patch_filters
      iterator = each

      content {
        key = each.key
        values = each.value
      }
    }
  }

  tags = {
    Name = var.name
  }
}

output "baseline_id" {
  value = aws_ssm_patch_baseline.this.id
}

output "baseline_arn" {
  value = aws_ssm_patch_baseline.this.arn
}

output "baseline_json" {
  value = aws_ssm_patch_baseline.this.json
}

output "baseline_name" {
  value = aws_ssm_patch_baseline.this.name
}
