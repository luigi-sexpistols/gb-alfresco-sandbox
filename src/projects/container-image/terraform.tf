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
    key = "container-image/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  # for networking and other "global" resources
  profile = "terraform"
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Tenant = "Ashley"
      Environment = "Sandbox"
      Project = "Fineos Cloud Upgrade"
    }
  }
}
