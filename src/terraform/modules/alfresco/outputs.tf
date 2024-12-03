output "instance" {
  value = aws_instance.this
}

output "ssh_private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
  depends_on = [aws_instance.this]
}

output "public_url" {
  value = aws_lb.proxy.dns_name
}

output "file_system" {
  value = aws_efs_file_system.this
}

output "file_system_mount_target" {
  value = aws_efs_mount_target.alfresco
}

output "tomcat_admin_username" {
  value = local.tomcat.admin_username
}

# output "message_queue_admin_username" {
#   value = local.message_queue.admin_username
# }
#
# output "message_queue_admin_password" {
#   value = random_password.mq_admin.result
#   sensitive = true
#   depends_on = [aws_mq_broker.this]
# }
#
# output "message_queue_user_username" {
#   value = local.message_queue.user_username
# }
#
# output "message_queue_user_password" {
#   value = random_password.mq_user.result
#   sensitive = true
#   depends_on = [aws_mq_broker.this]
# }
#
# output "database_admin_username" {
#   value = local.database.admin_username
# }
#
# output "database_admin_password" {
#   value = random_password.db_admin.result
#   sensitive = true
#   depends_on = [aws_rds_cluster_instance.this]
# }
#
# output "database_user_username" {
#   value = local.database.user_username
# }
#
# output "database_user_password" {
#   value = random_password.db_user.result
#   sensitive = true
#   depends_on = [aws_rds_cluster_instance.this]
# }
