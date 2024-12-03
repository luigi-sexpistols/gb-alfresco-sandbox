data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "terraform_data" "local_cidr" {
  input = "${trimspace(data.http.local_ip.response_body)}/32"
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc.id
  name = "${local.name}-instance"

  tags = {
    Name = "${local.name}-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_developer" {
  security_group_id = aws_security_group.this.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = terraform_data.local_cidr.output

  tags = {
    Name = "ssh-developer"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/32"

  tags = {
    Name = "all"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_vpc" {
  security_group_id = aws_security_group.this.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = var.vpc.cidr_block

  tags = {
    Name = "ssh-vpc"
  }
}
