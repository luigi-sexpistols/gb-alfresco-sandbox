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
  # for networking and other "global" resources
  profile = "terraform"

  default_tags {
    tags = {
      Environment = local.environment
      Name = "${local.environment}-main"
    }
  }
}

provider "aws" {
  alias = "deployer"
  profile = "terraform"

  default_tags {
    tags = {
      Environment = local.environment
      Name = "${local.environment}-deployer"
    }
  }
}

provider "aws" {
  alias = "alfresco"
  profile = "terraform"

  default_tags {
    tags = {
      Environment = local.environment
      Name = "${local.environment}-alfresco"
    }
  }
}

provider "aws" {
  alias = "bastion"
  profile = "terraform"

  default_tags {
    tags = {
      Environment = local.environment
      Name = "${local.environment}-bastion"
    }
  }
}
