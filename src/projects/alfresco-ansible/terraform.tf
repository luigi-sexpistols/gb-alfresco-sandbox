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
  }

  backend "s3" {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "alfresco-ansible/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  profile = "terraform"

  default_tags {
    tags = {
      Environment = "Ashley Sandbox"
      Project = var.gb_project_code
      map-migrated = var.map_project_code
    }
  }
}
