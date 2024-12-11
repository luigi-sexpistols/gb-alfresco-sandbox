output "public_ip_address" {
  value = module.bastion.instance.public_ip
}

output "ssh_private_key" {
  value = module.bastion.ssh_private_key
  sensitive = true
}

output "instance_id" {
  value = module.bastion.instance.id
}

output "reference_security_group_id" {
  value = module.bastion.reference_security_group.id
}
