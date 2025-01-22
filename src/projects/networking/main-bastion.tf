module "bastion_instance_profile" {
  source = "../../modules/aws/instance-profile"

  name = "${local.name_prefix}-bastion"
  policy_arns = {}
}

module "bastion_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-bastion"
  ami_id = data.aws_ami.bastion.id
  instance_type = "t3.micro"
  subnet_id = module.network.public_subnets.0.id
  associate_public_ip_address = true
  instance_profile_name = module.bastion_instance_profile.instance_profile_name

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
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}
