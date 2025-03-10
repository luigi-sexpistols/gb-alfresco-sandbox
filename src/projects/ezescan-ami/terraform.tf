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
    key = "ezescan-ami/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  profile = "terraform"

  default_tags {
    tags = {
      Environment = "Ashley Sandbox"
      Project = var.gb_project_code
      map-project = var.map_project_code
    }
  }
}
