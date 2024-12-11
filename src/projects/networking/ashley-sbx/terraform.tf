terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # for networking and other "global" resources
  profile = "terraform"

  default_tags {
    tags = {
      Tenant = var.tenant
      Environment = var.environment
      Name = "${var.tenant}-${var.environment}-shared"
    }
  }
}
