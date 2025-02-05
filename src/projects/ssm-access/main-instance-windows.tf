module "windows_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-windows"
  ami_id = module.windows_ami.ami.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.windows.id
  associate_public_ip_address = false

  tags = {
    Name = "${local.name_prefix}-windows"
    DailyShutdown = "Yes"
  }
}

module "windows_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.windows_instance.security_group_id

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}
