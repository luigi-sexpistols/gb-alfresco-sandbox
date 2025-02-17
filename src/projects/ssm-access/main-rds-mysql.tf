module "mysql_database" {
  source = "../../modules/aws/rds-cluster"

  name = "${local.name_prefix}-mysql"
  database_name = "ssm_poc"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  subnet_ids = module.network_data.private_subnets.*.id
  instance_count = 1
}

module "mysql_database_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.mysql_database.security_group_id

  ingress = {
    "mysql-linux" = {
      protocol = "tcp"
      port = 3306
      referenced_security_group_id = module.linux_instance.security_group_id
    }
  }
}
