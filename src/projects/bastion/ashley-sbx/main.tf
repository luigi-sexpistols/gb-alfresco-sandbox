module "bastion" {
  source = "../../../modules/services/bastion"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "bastion"
  vpc = data.aws_vpc.shared
  subnet = data.aws_subnet.shared_public

  allowed_ingress = {
    "ssh-ashley" = {
      port = 22
      cidr_block = terraform_data.developer_ingress_cidr.output
    }
  }

  instance_tags = {
    DailyShutdown = "Yes"
  }
}
