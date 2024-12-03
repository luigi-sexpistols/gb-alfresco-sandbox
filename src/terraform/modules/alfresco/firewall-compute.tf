resource "aws_security_group" "instance" {
  vpc_id = var.vpc.id
  name = "${local.name}-instance"

  tags = {
    Name = "${local.name}-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_additional" {
  count = length(var.additional_instance_ingress_rules)

  security_group_id = aws_security_group.instance.id
  ip_protocol = var.additional_instance_ingress_rules[count.index].protocol
  from_port = var.additional_instance_ingress_rules[count.index].port
  to_port = var.additional_instance_ingress_rules[count.index].port
  referenced_security_group_id = try(var.additional_instance_ingress_rules[count.index].security_group_id, null)
  cidr_ipv4 = try(var.additional_instance_ingress_rules[count.index].cidr, null)

  tags = {
    Name = var.additional_instance_ingress_rules[count.index].name
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_http_lb" {
  security_group_id = aws_security_group.instance.id
  ip_protocol = "tcp"
  from_port = 8080
  to_port = 8080
  referenced_security_group_id = aws_security_group.proxy.id

  tags = {
    Name = "http-proxy"
  }
}

resource "aws_vpc_security_group_egress_rule" "instance_all" {
  security_group_id = aws_security_group.instance.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}
