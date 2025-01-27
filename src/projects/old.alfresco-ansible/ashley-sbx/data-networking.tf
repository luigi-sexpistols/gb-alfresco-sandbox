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
resource "random_shuffle" "private_subnets_instance" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "shared_private_instance" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [random_shuffle.private_subnets_instance.result[0]]
  }
}

# used to place the mq in a random subnet
resource "random_shuffle" "private_subnets_mq" {
  input = data.terraform_remote_state.networking.outputs.private_subnets.*.id
}

data "aws_subnet" "shared_private_mq" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [random_shuffle.private_subnets_mq.result[0]]
  }
}

data "aws_subnet" "shared_public" {
  count = length(data.terraform_remote_state.networking.outputs.public_subnets)

  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [data.terraform_remote_state.networking.outputs.public_subnets[count.index].id]
  }
}

data "aws_subnet" "shared_private" {
  count = length(data.terraform_remote_state.networking.outputs.private_subnets)

  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [data.terraform_remote_state.networking.outputs.private_subnets[count.index].id]
  }
}
