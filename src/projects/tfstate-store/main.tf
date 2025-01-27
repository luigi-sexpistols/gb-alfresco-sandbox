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
      Tenant = "ashley"
      Environment = "sandbox"
    }
  }
}

module "state_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "ashley-sbx-terraform-state"
  versioning_enabled = true
}
