data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    profile = "terraform"
    bucket = "ashley-sbx-terraform-state-pjbfg"
    key = "networking-alb-oauth/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc_id
}

output "vpc" {
  value = data.aws_vpc.shared
}

data "aws_subnet" "private" {
  count = length(data.terraform_remote_state.networking.outputs.private_subnet_ids)

  id = data.terraform_remote_state.networking.outputs.private_subnet_ids[count.index]
}

output "private_subnets" {
  value = data.aws_subnet.private
}

data "aws_subnet" "public" {
  count = length(data.terraform_remote_state.networking.outputs.public_subnet_ids)

  id = data.terraform_remote_state.networking.outputs.public_subnet_ids[count.index]
}

output "public_subnets" {
  value = data.aws_subnet.public
}
