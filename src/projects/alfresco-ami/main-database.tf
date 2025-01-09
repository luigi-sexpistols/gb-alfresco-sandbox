locals {
  db = {
    username = "alfresco"
  }
}

module "alfresco_database_password" {
  source = "../../modules/utils/password"
}

module "alfresco_database" {
  source = "../../modules/aws/rds-cluster"

  name = local.name
  database_name = "alfresco"
  subnet_ids = data.aws_subnets.shared_private.ids
}

module "alfresco_db_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_database.security_group_id

  ingress = {
    "mysql-alfresco" = {
      port = 3306
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}

output "db_admin_password" {
  value = module.alfresco_database.admin_password
  sensitive = true
}
