data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.root}/../../networking/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc.id
}

# used to place the instance in a random subnet
resource "random_shuffle" "private_subnets" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "shared_private" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [random_shuffle.private_subnets.result[0]]
  }
}
#
# data "aws_security_group" "bastion" {
#   id = data.terraform_remote_state.bastion.outputs.reference_security_group_id
# }
#
# data "aws_instance" "bastion" {
#   instance_id = data.terraform_remote_state.bastion.outputs.instance_id
# }
