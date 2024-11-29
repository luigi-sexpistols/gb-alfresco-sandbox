resource "random_password" "alfresco_mq_admin" {
  length = 16
  special = false
}

resource "random_password" "alfresco_mq_user" {
  length = 32
  special = true
}

resource "aws_security_group" "alfresco_mq" {
  name = "gb-alfresco-mq"
  vpc_id = aws_vpc.alfresco.id

  tags = {
    Name = "gb-alfresco-mq"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_mq_mq_alfresco" {
  security_group_id = aws_security_group.alfresco_mq.id
  ip_protocol = "tcp"
  from_port = 61616
  to_port = 61616
  referenced_security_group_id = aws_security_group.alfresco_instance.id

  tags = {
    Name = "mq-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_mq_all" {
  security_group_id = aws_security_group.alfresco_mq.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "aws_mq_broker" "alfresco" {
  broker_name = "gb-alfresco"
  engine_type = "ActiveMQ"
  engine_version = "5.18"
  host_instance_type = "mq.t3.micro"
  deployment_mode = "SINGLE_INSTANCE"
  auto_minor_version_upgrade = true
  publicly_accessible = false
  subnet_ids = [aws_subnet.private[0].id]
  security_groups = [aws_security_group.alfresco_mq.id]

  apply_immediately = true

  user {
    username = local.mq.admin_username
    password = random_password.alfresco_mq_admin.result
  }

  user {
    username = local.mq.user_username
    password = random_password.alfresco_mq_user.result
  }
}
