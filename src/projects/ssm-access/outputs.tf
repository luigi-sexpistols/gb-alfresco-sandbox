output "windows_admin_password" {
  value = module.windows_instance.instance_password
  sensitive = true
}

#### INSTANCE: LINUX ####

output "linux_instance_id" {
  value = module.linux_instance.instance_id
}

output "linux_port" {
  value = 22
}

output "linux_ssh_private_key" {
  value = module.linux_instance.ssh_private_key
  sensitive = true
}

#### DATABASE: MYSQL ####

output "mysql_host" {
  value = module.mysql_database.endpoint
}

output "mysql_port" {
  value = 3306
}

output "mysql_database" {
  value = module.mysql_database.database_name
}

output "mysql_admin_username" {
  value = module.mysql_database.admin_username
}

output "mysql_admin_password" {
  value = module.mysql_database.admin_password
  sensitive = true
}

#### DATABASE: SQL SERVER ####

output "mssql_host" {
  value = split(":", module.mssql_database.endpoint)[0]
}

output "mssql_port" {
  value = tonumber(split(":", module.mssql_database.endpoint)[1])
}

output "mssql_database" {
  value = module.mssql_database.database_name
}

output "mssql_admin_username" {
  value = module.mssql_database.admin_username
}

output "mssql_admin_password" {
  value = module.mssql_database.admin_password
  sensitive = true
}

#### DATABASE: ORACLE ####

output "oracle_host" {
  value = split(":", module.oracle_database.endpoint)[0]
}

output "oracle_port" {
  value = tonumber(split(":", module.oracle_database.endpoint)[1])
}

output "oracle_database" {
  value = module.oracle_database.database_name
}

output "oracle_admin_username" {
  value = module.oracle_database.admin_username
}

output "oracle_admin_password" {
  value = module.oracle_database.admin_password
  sensitive = true
}
