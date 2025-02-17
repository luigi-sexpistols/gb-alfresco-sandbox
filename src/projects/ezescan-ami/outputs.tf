output "ezescan_private_ip_address" {
  value = module.ezescan_instance.private_ip_address
}

output "ezescan_rdp_username" {
  value = "Administrator"
}

output "ezescan_rdp_password" {
  value = module.ezescan_instance.instance_password
  sensitive = true
}
