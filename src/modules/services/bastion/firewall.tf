resource "aws_security_group" "this" {
  vpc_id = var.vpc.id
  name = "${local.name}-instance"

  tags = {
    Name = "${local.name}-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "all" {
  for_each = var.allowed_ingress

  security_group_id = aws_security_group.this.id
  ip_protocol = "tcp"
  from_port = each.value.port
  to_port = each.value.port
  cidr_ipv4 = each.value.cidr_block

  tags = {
    Name = each.key
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
