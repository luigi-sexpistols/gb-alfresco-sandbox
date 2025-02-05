output "vpc_id" {
  value = module.network.vpc.id
}

output "public_subnet_ids" {
  value = module.network.public_subnets.*.id
}

output "private_subnet_ids" {
  value = module.network.private_subnets.*.id
}

# output "bastion_instance_id" {
#   value = module.bastion_instance.instance_id
# }
#
# output "bastion_security_group_id" {
#   value = module.bastion_instance.security_group_id
# }
#
# output "bastion_public_ip_address" {
#   value = module.bastion_instance.public_ip_address
# }
#
# output "bastion_ssh_private_key" {
#   value = module.bastion_instance.ssh_private_key
#   sensitive = true
# }
