data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "${path.root}/../../networking/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.networking.outputs.vpc.id
}

data "aws_subnet" "shared_private" {
  for_each = toset([ for subnet in data.terraform_remote_state.networking.outputs.private_subnets : subnet.id ])

  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [each.value]
  }
}
