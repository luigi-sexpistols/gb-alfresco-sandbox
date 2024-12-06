output "bastion_public_ip_address" {
  value = module.bastion.instance.public_ip
}

output "bastion_ssh_private_key" {
  value = module.bastion.ssh_private_key
  sensitive = true
}

output "deployer_private_ip_address" {
  value = module.deployer.instance.private_ip
}

output "deployer_ssh_private_key" {
  value = module.deployer.ssh_private_key
  sensitive = true
}

output "alfresco_private_ip_address" {
  value = module.alfresco.instance.private_ip
}

output "alfresco_ssh_private_key" {
  value = module.alfresco.ssh_private_key
  sensitive = true
}

output "alfresco_public_url" {
  value = module.alfresco.public_url
}

output "alfresco_tomcat_admin_username" {
  value = "admin"
}

output "alfresco_tomcat_admin_password" {
  value = random_password.tomcat_admin.result
  sensitive = true
  depends_on = [module.alfresco]
}


# output "alfresco_mq_admin_username" {
#   value = module.alfresco.message_queue_admin_username
# }
#
# output "alfresco_mq_admin_password" {
#   value = module.alfresco.message_queue_admin_password
#   sensitive = true
# }
#
# output "alfresco_mq_user_username" {
#   value = module.alfresco.message_queue_user_username
# }
#
# output "alfresco_mq_user_password" {
#   value = module.alfresco.message_queue_user_password
#   sensitive = true
# }
#
# output "alfresco_database_admin_username" {
#   value = module.alfresco.database_admin_username
# }
#
# output "alfresco_database_admin_password" {
#   value = module.alfresco.database_admin_password
#   sensitive = true
# }
#
# output "alfresco_database_user_username" {
#   value = module.alfresco.database_user_username
# }
#
# output "alfresco_database_user_password" {
#   value = module.alfresco.database_user_password
#   sensitive = true
# }
#
# output "alfresco_tomcat_admin_username" {
#   value = local.alfresco.tomcat.admin_username
# }
#
# output "alfresco_tomcat_admin_password" {
#   value = random_password.alfresco_tomcat_admin.result
#   sensitive = true
#   depends_on = [terraform_data.deployer_bootstrap]
# }
