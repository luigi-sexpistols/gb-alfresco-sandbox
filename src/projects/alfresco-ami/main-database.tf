module "alfresco_database" {
  source = "../../modules/aws/rds-cluster"

  name = local.name
  engine = "mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  database_name = local.db.database
  subnet_ids = module.network_data.private_subnets.*.id
  instance_count = 1
}

module "alfresco_db_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_database.security_group_id

  ingress = {
    "mysql-alfresco" = {
      protocol = "tcp"
      port = 3306
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}

module "alfresco_db_user_password" {
  source = "../../modules/utils/password"

  length = 24
}
