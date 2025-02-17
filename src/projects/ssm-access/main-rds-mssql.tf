module "mssql_database" {
  source = "../../modules/aws/rds-instance"

  name = "${local.name_prefix}-mssql"
  database_name = null
  engine = "sqlserver-ex"
  engine_version = "15.00.4415.2.v1"
  subnet_ids = module.network_data.private_subnets.*.id
  serverless = false
}

module "mssql_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.mssql_database.security_group_id

  ingress = {
    "mssql-linux" = {
      protocol = "tcp"
      port = 1433
      referenced_security_group_id = module.linux_instance.security_group_id
    }
  }
}
