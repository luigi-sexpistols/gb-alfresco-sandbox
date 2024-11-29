terraform {
  required_providers {
    # terraform = {
    #   source = "builtin/terraform"
    #   # version = ""
    # }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
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
}

provider "aws" {
  profile = "gb-sandbox"

  default_tags {
    tags = {
      "Name" = "gb-alfresco"
    }
  }
}
