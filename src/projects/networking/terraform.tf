terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "networking/terraform.tfstate"
    region = "ap-southeast-2"
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
