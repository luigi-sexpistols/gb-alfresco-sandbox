resource "aws_security_group" "storage" {
  vpc_id = var.vpc.id
  name = "${local.name}-storage"

  tags = {
    "Name" = "${local.name}-storage"
  }
}

resource "aws_vpc_security_group_ingress_rule" "storage_nfs_alfresco" {
  security_group_id = aws_security_group.storage.id
  ip_protocol = "tcp"
  from_port = 2049
  to_port = 2049
  referenced_security_group_id = aws_security_group.instance.id

  tags = {
    Name = "nfs-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_storage_all" {
  security_group_id = aws_security_group.storage.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

