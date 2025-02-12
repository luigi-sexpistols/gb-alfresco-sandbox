module "networking_data" {
  source = "../../modules/utils/networking-data"
}

module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
}

resource "random_shuffle" "instance_subnet_ids_pool" {
  input = module.networking_data.private_subnets.*.id
}

resource "random_shuffle" "rdgw_subnet_ids_pool" {
  input = module.networking_data.public_subnets.*.id
}

data "aws_subnet" "ezescan" {
  id = random_shuffle.instance_subnet_ids_pool.result[0]
}

data "aws_subnet" "ezescan_rdgw" {
  id = random_shuffle.rdgw_subnet_ids_pool.result[0]
}

data "aws_caller_identity" "this" {}

data "aws_ami" "ezescan" {
  most_recent = true
  owners = [data.aws_caller_identity.this.account_id]

  filter {
    name = "name"
    values = ["*-ezeami-*"]
  }
}
