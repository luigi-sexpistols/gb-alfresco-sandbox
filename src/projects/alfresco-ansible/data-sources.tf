module "network_data" {
  source = "../../modules/utils/networking-data"
}

module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
}

data "aws_ami" "rhel9" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*-x86_64-*"]
  }
}
