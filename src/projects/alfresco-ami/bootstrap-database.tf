# WARNING
# This is _not_ the right way to do this, it's just convenient for PoC env.
resource "terraform_data" "alfresco_db_bootstrap" {
  depends_on = [module.alfresco_database, module.alfresco_instance]

  triggers_replace = [
    module.alfresco_database.instance_ids,
    filemd5("${path.module}/bootstrap-database.tf"),
    filemd5("${path.module}/database-init/init.template.sql")
  ]

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
      "sudo dnf install --assumeyes mariadb",
      "mysql --host=${module.alfresco_database.endpoint} --user=${module.alfresco_database.admin_username} --password=${module.alfresco_database.admin_password} ${module.alfresco_database.database_name} < /tmp/init.sql",
      "rm -rf /tmp/init.sql",
      "sudo dnf remove --assumeyes mariadb"
    ]
  }
}
