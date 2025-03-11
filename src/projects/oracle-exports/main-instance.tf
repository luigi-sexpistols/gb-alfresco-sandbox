module "instance" {
  source = "../../modules/aws/ec2-instance"

  name = local.name
  ami_id = module.linux_ami.ami.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.instance.id
  associate_public_ip_address = false

  tags = {
    DailyShutdown = "Yes"
  }
}

module "linux_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.instance.security_group_id

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}
