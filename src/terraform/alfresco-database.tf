resource "random_password" "alfresco_db_admin" {
  length = 16
  special = false
}

resource "aws_security_group" "alfresco_db" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-alfresco"
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_db_mysql_alfresco" {
  security_group_id = aws_security_group.alfresco_db.id
  ip_protocol = "tcp"
  from_port = 3306
  to_port = 3306
  referenced_security_group_id = aws_security_group.alfresco_instance.id

  tags = {
    Name = "mysql-alfresco"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_db_all" {
  security_group_id = aws_security_group.alfresco_db.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "aws_db_subnet_group" "alfresco" {
  name = "gb-alfresco"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_rds_cluster" "alfresco" {
  cluster_identifier = "gb-alfresco"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  availability_zones = aws_subnet.private.*.availability_zone
  database_name = "alfresco"
  master_username = "admin"
  master_password = random_password.alfresco_db_admin.result
  backup_retention_period = 1
  vpc_security_group_ids = [aws_security_group.alfresco_db.id]
  db_subnet_group_name = aws_db_subnet_group.alfresco.name

  apply_immediately = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "alfresco" {
  cluster_identifier = aws_rds_cluster.alfresco.cluster_identifier
  instance_class = "db.serverless"
  engine = aws_rds_cluster.alfresco.engine
  engine_version = aws_rds_cluster.alfresco.engine_version
}
