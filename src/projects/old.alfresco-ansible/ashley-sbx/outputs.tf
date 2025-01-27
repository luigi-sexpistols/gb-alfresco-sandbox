output "instance_id" {
  value = module.alfresco.instance.id
}

output "instance_private_ip_address" {
  value = module.alfresco.instance.private_ip
}

output "instance_ssh_private_key" {
  value = module.alfresco.ssh_private_key
  sensitive = true
}

output "public_url" {
  value = module.alfresco.public_url
}

output "tomcat_admin_password" {
  value = random_password.tomcat_admin.result
  sensitive = true
  depends_on = [module.alfresco]
}
