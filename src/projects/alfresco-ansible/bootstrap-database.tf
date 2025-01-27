# WARNING
# This is _not_ the right way to do this, it's just convenient for PoC env.
resource "terraform_data" "alfresco_db_bootstrap" {
  depends_on = [module.alfresco_instance, module.alfresco_database]

  triggers_replace = [
    module.alfresco_database.cluster_id,
    filesha1("./bootstrap-database.tf"),
    filesha1("${path.module}/files/bootstrap-database.template.sql")
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
    destination = "/tmp/db-init.sql"
    content = templatefile("${path.module}/files/bootstrap-database.template.sql", {
      username = local.db.username
      password = module.alfresco_db_user_password.result
      database = module.alfresco_database.database_name
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install --assumeyes postgresql",
      "PGPASSWORD=${module.alfresco_db_user_password.result} psql -h '${module.alfresco_database.endpoint}' -U '${module.alfresco_database.admin_username}' -d template1 -f '/tmp/db-init.sql'",
      "sudo dnf remove --assumeyes postgresql"
    ]
  }
}
