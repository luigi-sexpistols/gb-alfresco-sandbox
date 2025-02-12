module "ezescan_instance" {
  source = "../../modules/aws/ec2-instance"

  name = local.name
  ami_id = data.aws_ami.ezescan.id
  instance_type = "t3.medium"
  subnet_id = data.aws_subnet.ezescan.id
  associate_public_ip_address = false
}

module "ezescan_instance_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.ezescan_instance.security_group_id

  ingress = {
    "rdp-bastion" = {
      protocol = "tcp"
      port = 3389
      referenced_security_group_id = module.networking_data.bastion_security_group.id
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

module "ezescan_log_group" {
  source = "../../modules/aws/cloudwatch-log-group"

  name = "${local.name}-es-install"
  retention_in_days = 1
}


