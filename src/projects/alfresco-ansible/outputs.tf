output "master_instance_private_ip_address" {
  value = module.master_instance.private_ip_address
}

output "master_ssh_private_key" {
  value = module.master_instance.ssh_private_key
  sensitive = true
}

output "alfresco_instance_private_ip_address" {
  value = module.alfresco_instance.private_ip_address
}

output "alfresco_instance_ssh_private_key" {
  value = module.alfresco_instance.ssh_private_key
  sensitive = true
}

output "alfresco_url" {
  value = module.alfresco_proxy.public_dns
}
