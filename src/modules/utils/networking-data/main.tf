data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.module}/../../../projects/networking/terraform.tfstate"
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

data "aws_instance" "bastion" {
  instance_id = data.terraform_remote_state.networking.outputs.bastion_instance_id
}

output "bastion_instance" {
  value = data.aws_instance.bastion
}

data "aws_security_group" "bastion" {
  id = data.terraform_remote_state.networking.outputs.bastion_security_group_id
}

output "bastion_security_group" {
  value = data.aws_security_group.bastion
}

output "bastion_ssh_private_key" {
  value = data.terraform_remote_state.networking.outputs.bastion_ssh_private_key
}
