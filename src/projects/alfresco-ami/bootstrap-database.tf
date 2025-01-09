# resource "terraform_data" "bootstrap_alfresco_database" {
#   depends_on = [module.alfresco_database, module.alfresco_instance]
#
#   triggers_replace = concat(
#     module.alfresco_database.instance_ids,
#     [
#       filemd5("${path.module}/database-init/init.template.sql")
#     ]
#   )
#
#   connection {
#     bastion_host = data.aws_instance.bastion.public_ip
#     bastion_user = "ec2-user"
#     bastion_private_key = data.terraform_remote_state.bastion.outputs.ssh_private_key
#     type = "ssh"
#     host = module.alfresco_instance.private_ip_address
#     user = "ec2-user"
#     private_key = module.alfresco_instance_key_pair.private_key
#   }
#
#   provisioner "file" {
#     destination = "/tmp/init.sql"
#     content = templatefile("${path.module}/database-init/init.template.sql", {
#       username = local.db.username
#       password = module.alfresco_database_password.result
#       database = module.alfresco_database.database_name
#     })
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo dnf install --assumeyes mariadb",
#       "mysql --host=${module.alfresco_database.endpoint} --user=${module.alfresco_database.admin_username} --password=${module.alfresco_database.admin_password} ${module.alfresco_database.database_name} < /tmp/init.sql",
#       "sudo dnf remove --assumeyes mariadb",
#       "rm -rf /tmp/init.sql"
#     ]
#   }
# }
