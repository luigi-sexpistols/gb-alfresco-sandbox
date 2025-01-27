output "alfresco_instance_private_ip" {
  value = module.alfresco_instance.private_ip_address
}

output "alfresco_instance_ssh_private_key" {
  value = module.alfresco_instance.ssh_private_key
  sensitive = true
}

output "alfresco_url" {
  value = module.alfresco_proxy.public_dns
}

output "alfresco_db_admin_username" {
  value = module.alfresco_database.admin_username
}

output "alfresco_db_admin_password" {
  value = module.alfresco_database.admin_password
  sensitive = true
}

output "alfresco_db_app_username" {
  value = local.db.username
  depends_on = [module.alfresco_database]
}

output "alfresco_db_app_password" {
  value = module.alfresco_db_user_password.result
  sensitive = true
  depends_on = [module.alfresco_database]
}
