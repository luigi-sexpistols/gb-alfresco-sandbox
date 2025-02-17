# this should be ready to go when mssql testing is done
# may need updates if mssql changes

module "oracle_database" {
  source = "../../modules/aws/rds-instance"

  name = "${local.name_prefix}-oracle"
  database_name = "SSMTEST"
  engine = "oracle-se2"
  engine_version = "19.0.0.0.ru-2025-01.rur-2025-01.r1"
  subnet_ids = module.network_data.private_subnets.*.id
  serverless = false
  license_model = "license-included"
  instance_class = "db.t3.small"
}

module "oracle_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.oracle_database.security_group_id

  ingress = {
    "oracle-linux" = {
      protocol = "tcp"
      port = 1521
      referenced_security_group_id = module.linux_instance.security_group_id
    }
  }
}
