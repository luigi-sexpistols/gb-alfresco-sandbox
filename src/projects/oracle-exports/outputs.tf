output "db_hostname" {
  value = split(":", module.oracle_database.endpoint)[0]
}

output "db_port" {
  value = split(":", module.oracle_database.endpoint)[1]
}

output "db_username" {
  value = module.oracle_database.admin_username
}

output "db_password" {
  value = module.oracle_database.admin_password
  sensitive = true
}

output "instance_id" {
  value = module.instance.instance_id
}

output "bucket_name" {
  value = module.exports_bucket.bucket_name
}

output "iam_role_arn" {
  value = module.iam_role.role_arn
}

output "kms_key_id" {
  value = aws_kms_key.exports.id
}
