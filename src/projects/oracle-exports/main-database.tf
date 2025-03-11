# this should be ready to go when mssql testing is done
# may need updates if mssql changes

module "oracle_database" {
  source = "../../modules/aws/rds-instance"

  name = local.name
  database_name = "ORCL"
  engine = "oracle-se2-cdb"
  engine_version = "21.0.0.0.ru-2025-01.rur-2025-01.r2"
  subnet_ids = module.network_data.private_subnets.*.id
  serverless = false
  license_model = "license-included"
  instance_class = "db.t3.small"
  encrypted = true
}

module "oracle_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.oracle_database.security_group_id

  ingress = {
    "oracle-linux" = {
      protocol = "tcp"
      port = 1521
      referenced_security_group_id = module.instance.security_group_id
    }
  }
}
