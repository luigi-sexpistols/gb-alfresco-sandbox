data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data"
}

module "linux_ami" {
  source = "../../modules/aws/amazon-ami-data"

  platform = "ami-amazon-linux-latest"
  name = "al2023-ami-kernel-default-x86_64"
}

resource "random_shuffle" "subnet_id_pool" {
  input = module.network_data.private_subnets.*.id
}

data "aws_subnet" "instance" {
  id = random_shuffle.subnet_id_pool.result[0]
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}
