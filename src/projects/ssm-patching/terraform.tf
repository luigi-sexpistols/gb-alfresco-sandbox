terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "ssm-patching/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  # for networking and other "global" resources
  profile = "terraform"
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Environment = "Ashley Sandbox"
      Project = var.gb_project_code
      map-project = var.map_project_code
    }
  }
}
