terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "terraform"

  default_tags {
    tags = {
      Tenant = var.tenant
      Environment = var.environment
      Name = "APPLY_TO_RESOURCES"
    }
  }
}
