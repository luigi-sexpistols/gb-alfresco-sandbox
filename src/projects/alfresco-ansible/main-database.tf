module "alfresco_database" {
  source = "../../modules/aws/rds-cluster"

  name = "${local.name_prefix}-alfresco"
  engine = "postgresql"
  database_name = "alfresco"
  subnet_ids = module.network_data.private_subnets.*.id
  instance_count = 1
  admin_username = "alf_admin"
}

module "alfresco_db_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_database.security_group_id

  ingress = {
    "postgresql-alfresco" = {
      protocol = "tcp"
      port = 5432
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}

module "alfresco_db_user_password" {
  source = "../../modules/utils/password"

  length = 24
}
