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
resource "random_shuffle" "public_subnets" {
  input = data.terraform_remote_state.networking.outputs.public_subnets.*.id
}

data "aws_subnet" "shared_public" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name = "subnet-id"
    values = [random_shuffle.public_subnets.result[0]]
  }
}

data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "terraform_data" "developer_ingress_cidr" {
  input = "${trimspace(data.http.local_ip.response_body)}/32"
}
