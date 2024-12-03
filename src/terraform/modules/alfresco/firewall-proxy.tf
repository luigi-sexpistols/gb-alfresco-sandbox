resource "aws_security_group" "proxy" {
  vpc_id = var.vpc.id
  name = "${local.name}-proxy"

  tags = {
    Name = "${local.name}-proxy"
  }
}

resource "aws_vpc_security_group_ingress_rule" "proxy_additional" {
  count = length(var.additional_proxy_ingress_rules)

  security_group_id = aws_security_group.proxy.id
  ip_protocol = var.additional_proxy_ingress_rules[count.index].protocol
  from_port = var.additional_proxy_ingress_rules[count.index].port
  to_port = var.additional_proxy_ingress_rules[count.index].port
  referenced_security_group_id = try(var.additional_proxy_ingress_rules[count.index].security_group_id, null)
  cidr_ipv4 = try(var.additional_proxy_ingress_rules[count.index].cidr, null)

  tags = {
    Name = var.additional_proxy_ingress_rules[count.index].name
  }
}

resource "aws_vpc_security_group_egress_rule" "proxy_http_alfresco" {
  security_group_id = aws_security_group.proxy.id
  ip_protocol = "tcp"
  from_port = 8080
  to_port = 8080
  referenced_security_group_id = aws_security_group.instance.id

  tags = {
    Name = "http-alfresco"
  }
}

