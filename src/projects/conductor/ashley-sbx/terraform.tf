terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  profile = "terraform"

  default_tags {
    tags = {
      Tenant = var.tenant
      Environment = var.environment
      Name = "${var.tenant}-${var.environment}-conductor"
    }
  }
}
