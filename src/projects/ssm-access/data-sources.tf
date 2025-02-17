data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data"
}

module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
}

module "windows_ami" {
  source = "../../modules/aws/amazon-ami-data"

  platform = "ami-windows-latest"
  name = "Windows_Server-2025-English-Full-Base"
}

module "linux_ami" {
  source = "../../modules/aws/amazon-ami-data"

  platform = "ami-amazon-linux-latest"
  name = "al2023-ami-kernel-default-x86_64"
}

resource "random_shuffle" "subnet_id_pool" {
  input = module.network_data.private_subnets.*.id
}

data "aws_subnet" "linux" {
  id = random_shuffle.subnet_id_pool.result[0]
}

data "aws_subnet" "windows" {
  id = random_shuffle.subnet_id_pool.result[1]
}

data "aws_subnet" "mysql" {
  id = random_shuffle.subnet_id_pool.result[0]
}

data "aws_subnet" "sqlserver" {
  id = random_shuffle.subnet_id_pool.result[1]
}

data "aws_subnet" "oracle_db" {
  id = random_shuffle.subnet_id_pool.result[2]
}
