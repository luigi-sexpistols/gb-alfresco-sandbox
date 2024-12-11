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
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
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
      Name = "${var.tenant}-${var.environment}-alfresco-ansible"
    }
  }
}
