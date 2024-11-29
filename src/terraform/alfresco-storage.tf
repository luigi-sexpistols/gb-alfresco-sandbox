resource "aws_efs_file_system" "alfresco" {
  creation_token = "gb-alfresco"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}

resource "aws_security_group" "alfresco_storage" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-alfresco-storage"

  tags = {
    "Name" = "gb-alfresco-storage"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_storage_nfs_alfresco" {
  security_group_id = aws_security_group.alfresco_storage.id
  ip_protocol = "tcp"
  from_port = 2049
  to_port = 2049
  referenced_security_group_id = aws_security_group.alfresco_instance.id

  tags = {
    Name = "nfs-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_storage_all" {
  security_group_id = aws_security_group.alfresco_storage.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "aws_efs_mount_target" "alfresco" {
  file_system_id = aws_efs_file_system.alfresco.id
  subnet_id = aws_subnet.private[0].id
  security_groups = [aws_security_group.alfresco_storage.id]
}
