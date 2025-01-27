module "bastion_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-bastion"
  ami_id = data.aws_ami.bastion.id
  instance_type = "t3.micro"
  subnet_id = module.network.public_subnets.0.id
  associate_public_ip_address = true

  tags = {
    DailyShutdown = "Yes"
  }
}

module "bastion_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.bastion_instance.security_group_id

  ingress = {
    "ssh-ashley" = {
      protocol = "tcp"
      port = 22
      cidr_block = "${trimspace(data.http.developer_ip.response_body)}/32"
    }
  }

  egress = {
    "ssh-vpc" = {
      protocol = "tcp"
      port = 22
      cidr_block = module.network.vpc.cidr_block
    }
  }
}
