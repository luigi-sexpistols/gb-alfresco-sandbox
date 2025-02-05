output "windows_admin_password" {
  value = module.windows_instance.instance_password
  sensitive = true
}
