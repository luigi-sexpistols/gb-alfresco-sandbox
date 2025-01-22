module "master_instance_profile" {
  source = "../../modules/aws/instance-profile"

  name = "${local.name_prefix}-master"
  policy_arns = {}
}

module "master_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-master"
  ami_id = data.aws_ami.rhel9.id
  instance_type = "t3.micro"
  subnet_id = module.network_data.private_subnets.0.id
  instance_profile_name = module.master_instance_profile.instance_profile_name

  tags = {
    DailyShutdown = "Yes"
  }
}

module "master_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.master_instance.security_group_id

  ingress = {
    "ssh-bastion" = {
      protocol = "tcp"
      port = 22
      referenced_security_group_id = module.network_data.bastion_security_group.id
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
