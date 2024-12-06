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

resource "aws_iam_role" "instance_profile" {
  name = "${local.name}-instance"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json

  tags = {
    Name = "${local.name}-instance"
  }
}

resource "aws_iam_policy" "instance_profile" {
  name = "${local.name}-instance"
  policy = data.aws_iam_policy_document.instance_permissions.json
}

resource "aws_iam_role_policy_attachment" "instance_profile" {
  policy_arn = aws_iam_policy.instance_profile.arn
  role = aws_iam_role.instance_profile.name
}

resource "aws_iam_instance_profile" "this" {
  name = local.name
  role = aws_iam_role.instance_profile.name
}

resource "aws_instance" "this" {
  ami = data.aws_ami.rhel9.id
  instance_type = "t3.medium"
  subnet_id = var.instance_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = aws_key_pair.this.key_name
  iam_instance_profile = aws_iam_instance_profile.this.id
}
