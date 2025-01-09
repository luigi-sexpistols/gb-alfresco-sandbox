resource "aws_security_group" "database" {
  vpc_id = var.vpc.id
  name = "${local.name}-database"

  tags = {
    Name = "${local.name}-database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql_alfresco" {
  security_group_id = aws_security_group.database.id
  ip_protocol = "tcp"
  from_port = 3306
  to_port = 3306
  referenced_security_group_id = aws_security_group.instance.id

  tags = {
    Name = "mysql-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.database.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

