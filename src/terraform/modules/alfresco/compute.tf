data "aws_ami" "rhel9" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "this" {
  key_name = local.name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  ami = data.aws_ami.rhel9.id
  instance_type = "t3.micro"
  subnet_id = var.instance_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = aws_key_pair.this.key_name
}
