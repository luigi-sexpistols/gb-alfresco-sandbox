resource "aws_security_group" "mq" {
  name = "${local.name}-mq"
  vpc_id = var.vpc.id

  tags = {
    Name = "${local.name}-mq"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mq_mq_alfresco" {
  security_group_id = aws_security_group.mq.id
  ip_protocol = "tcp"
  from_port = 61616
  to_port = 61616
  referenced_security_group_id = aws_security_group.instance.id

  tags = {
    Name = "mq-alfresco"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mq_mqssl_alfresco" {
  security_group_id = aws_security_group.mq.id
  ip_protocol = "tcp"
  from_port = 61617
  to_port = 61617
  referenced_security_group_id = aws_security_group.instance.id

  tags = {
    Name = "mqssl-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "mq_all" {
  security_group_id = aws_security_group.mq.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

