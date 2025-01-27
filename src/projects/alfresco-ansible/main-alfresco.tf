module "alfresco_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-alfresco"
  ami_id = data.aws_ami.rhel9.id
  instance_type = "t3.xlarge"
  subnet_id = module.network_data.private_subnets.1.id

  tags = {
    DailyShutdown = "Yes"
  }
}

module "alfresco_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_instance.security_group_id

  ingress = {
    "ssh-ansible" = {
      protocol = "tcp"
      port = 22
      referenced_security_group_id = module.master_instance.security_group_id
    }

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
