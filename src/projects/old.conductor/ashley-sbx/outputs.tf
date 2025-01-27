output "instance_id" {
  value = module.conductor.instance.id
}

output "private_ip_address" {
  value = module.conductor.instance.private_ip
}

output "ssh_private_key" {
  value = module.conductor.ssh_private_key
  sensitive = true
}

output "reference_security_group_id" {
  value = module.conductor.instance_security_group.id
}

output "ansible_public_key" {
  value = module.conductor.ansible_public_key
}

output "ansible_working_dir" {
  value = local.ansible_working_dir
  # depends_on = [terraform_data.bootstrap]
}
