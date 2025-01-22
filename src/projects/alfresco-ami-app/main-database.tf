module "alfresco_database" {
  source = "../../modules/aws/rds-cluster"

  name = "${local.name_prefix}-alfresco"
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

resource "terraform_data" "alfresco_db_bootstrap" {
  depends_on = [module.alfresco_database, module.alfresco_instance]

  triggers_replace = concat(
    module.alfresco_database.instance_ids,
    [
      filemd5("${path.module}/database-init/init.template.sql")
    ]
  )

  connection {
    bastion_host = module.network_data.bastion_instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = module.network_data.bastion_ssh_private_key
    type = "ssh"
    host = module.alfresco_instance.private_ip_address
    user = "ec2-user"
    private_key = module.alfresco_instance.ssh_private_key
  }

  provisioner "file" {
    destination = "/tmp/init.sql"
    content = templatefile("${path.module}/database-init/init.template.sql", {
      username = local.db.username
      password = module.alfresco_db_user_password.result
      database = module.alfresco_database.database_name
    })
  }

  provisioner "remote-exec" {
    inline = [
      "mysql --host=${module.alfresco_database.endpoint} --user=${module.alfresco_database.admin_username} --password=${module.alfresco_database.admin_password} ${module.alfresco_database.database_name} < /tmp/init.sql",
      "rm -rf /tmp/init.sql"
    ]
  }
}
