output "alfresco_private_key" {
  value = tls_private_key.alfresco_instance.private_key_pem
  sensitive = true
  depends_on = [terraform_data.alfresco_bootstrap]
}

output "alfresco_public_key" {
  value = tls_private_key.alfresco_instance.public_key_openssh
  sensitive = true
}

output "deployer_private_key" {
  value = tls_private_key.deployer_instance.private_key_pem
  sensitive = true
  depends_on = [terraform_data.deployer_bootstrap]
}

output "deployer_public_key" {
  value = tls_private_key.deployer_instance.public_key_openssh
  sensitive = true
}

output "alfresco_activemq_admin_username" {
  value = local.mq.admin_username
}

output "alfresco_activemq_admin_password" {
  value = random_password.alfresco_mq_admin.result
  sensitive = true
  depends_on = [aws_mq_broker.alfresco]
}

output "alfresco_activemq_user_username" {
  value = local.mq.user_username
}

output "alfresco_activemq_user_password" {
  value = random_password.alfresco_mq_user.result
  sensitive = true
  depends_on = [aws_mq_broker.alfresco]
}

output "alfresco_database_admin_username" {
  value = aws_rds_cluster.alfresco.master_username
}

output "alfresco_database_admin_password" {
  value = random_password.alfresco_db_admin.result
  sensitive = true
  depends_on = [aws_rds_cluster_instance.alfresco]
}

output "alfresco_tomcat_admin_username" {
  value = local.tomcat.admin_username
}

output "alfresco_tomcat_admin_password" {
  value = random_password.alfresco_tomcat_admin.result
  sensitive = true
  depends_on = [terraform_data.deployer_bootstrap]
}
