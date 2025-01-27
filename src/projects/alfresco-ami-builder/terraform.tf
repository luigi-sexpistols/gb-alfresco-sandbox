terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
    counters = {
      source = "RutledgePaulV/counters"
      version = "0.0.5"
    }
  }

  backend "s3" {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "alfresco-ami-builder/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  profile = "terraform"

  default_tags {
    tags = {
      Tenant = "ashley"
      Environment = "sandbox"
    }
  }
}
