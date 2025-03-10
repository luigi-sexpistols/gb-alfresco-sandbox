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
      Environment = "Ashley Sandbox"
      Project = var.gb_project_code
      map-project = var.map_project_code
    }
  }
}

variable "gb_project_code" {
  type = string
}

variable "map_project_code" {
  type = string
}

module "state_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "ashley-sbx-terraform-state"
  versioning_enabled = true
}
