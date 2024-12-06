resource "aws_db_subnet_group" "this" {
  name = local.name
  subnet_ids = var.database_subnets.*.id
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = local.name
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  availability_zones = var.database_subnets.*.availability_zone
  database_name = "alfresco"
  master_username = var.database.admin.username
  master_password = var.database.admin.password
  backup_retention_period = 1
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot = true

  apply_immediately = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "this" {
  cluster_identifier = aws_rds_cluster.this.cluster_identifier
  instance_class = "db.serverless"
  engine = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
}
