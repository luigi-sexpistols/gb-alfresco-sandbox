output "image_builder_ssh_private_key" {
  value = module.alfresco_image.builder_ssh_private_key
  sensitive = true
}

output "alfresco_instance_public_ip_address" {
  value = module.alfresco_instance.public_ip_address
}

output "alfresco_private_ip_address" {
  value = module.alfresco_instance.private_ip_address
}

output "alfresco_private_key" {
  value = module.alfresco_instance_key_pair.private_key
  sensitive = true
}

output "alfresco_public_dns" {
  value = module.alfresco_proxy.public_dns
}
