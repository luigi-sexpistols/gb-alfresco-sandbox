data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"] // todo - var?
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
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id = var.subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name
}
