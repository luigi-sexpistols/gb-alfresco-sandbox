module "alfresco_instance_profile" {
  source = "../../modules/aws/instance-profile"

  name = local.name
  policy_arns = {}
}

module "alfresco_instance_key_pair" {
  source = "../../modules/aws/key-pair"

  name = local.name
}

module "alfresco_instance" {
  source = "../../modules/aws/ec2-instance"

  name = local.name
  ami_id = module.alfresco_image.ami_id
  instance_profile_name = module.alfresco_instance_profile.instance_profile_name
  instance_type = "t3.medium"
  subnet_id = data.aws_subnet.instance.id
  key_pair_name = module.alfresco_instance_key_pair.key_name

  tags = {
    DailyShutdown = "Yes"
  }
}

module "alfresco_instance_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_instance.security_group_id

  ingress = {
    "http-lb" = {
      protocol = "tcp"
      port = 8080
      referenced_security_group_id = module.alfresco_proxy_security_group.security_group_id
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
