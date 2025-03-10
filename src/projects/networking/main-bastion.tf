module "bastion_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-bastion"
  ami_id = data.aws_ami.bastion.id
  instance_type = "t3.micro"
  subnet_id = module.network.private_subnets.0.id
  associate_public_ip_address = false

  tags = {
    DailyShutdown = "Yes"
  }
}

# todo - make this work with SSM SM
