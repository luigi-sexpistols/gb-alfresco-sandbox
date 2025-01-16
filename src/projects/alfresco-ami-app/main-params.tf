resource "aws_ssm_parameter" "alfresco_system_mount_target" {
  name = "/alfresco/system/efs/mount-target"
  type = "String"
  value = module.alfresco_files.mount_target_dns_name[data.aws_subnet.instance.availability_zone]
}

resource "aws_ssm_parameter" "alfresco_java_dir_root" {
  name = "/alfresco/java/dir/root"
  type = "String"
  value = "${local.efs.mount_point}/root"
}

resource "aws_ssm_parameter" "alfresco_java_db_driver" {
  name = "/alfresco/java/db/driver"
  type = "String"
  value = "com.mysql.jdbc.Driver"
}

resource "aws_ssm_parameter" "alfresco_java_db_hostname" {
  name = "/alfresco/java/db/url"
  type = "String"
  value = "jdbc:mysql://${module.alfresco_database.endpoint}:3306/${module.alfresco_database.database_name}"
}

resource "aws_ssm_parameter" "alfresco_java_db_username" {
  name = "/alfresco/java/db/username"
  type = "String"
  value = local.db.username
}

resource "aws_ssm_parameter" "alfresco_java_db_password" {
  name = "/alfresco/java/db/password"
  type = "SecureString"
  value = module.alfresco_db_user_password.result
}

resource "aws_ssm_parameter" "alfresco_java_mq_endpoint" {
  name = "/alfresco/java/messaging/broker/url"
  type = "String"
  value = "failover:(${module.alfresco_mq.endpoint})?timeout=3000"
}

resource "aws_ssm_parameter" "alfresco_java_mq_broker_username" {
  name = "/alfresco/java/messaging/broker/username"
  type = "String"
  value = module.alfresco_mq.user_username
}

resource "aws_ssm_parameter" "alfresco_java_mq_broker_password" {
  name = "/alfresco/java/messaging/broker/password"
  type = "SecureString"
  value = module.alfresco_mq.user_password
}

resource "aws_ssm_parameter" "alfresco_java_mq_username" {
  name = "/alfresco/java/messaging/username"
  type = "String"
  value = module.alfresco_mq.user_username
}

resource "aws_ssm_parameter" "alfresco_java_mq_password" {
  name = "/alfresco/java/messaging/password"
  type = "SecureString"
  value = module.alfresco_mq.user_password
}

resource "aws_ssm_parameter" "alfresco_java_dir_keystore" {
  name = "/alfresco/java/dir/keystore"
  type = "String"
  value = "${local.efs.mount_point}/keystore"
}

resource "aws_ssm_parameter" "alfresco_java_encryption_keystore_location" {
  name = "/alfresco/java/encryption/keystore/location"
  type = "String"
  value = "${local.efs.mount_point}/keystore/metadata-keystore/keystore"
}

resource "aws_ssm_parameter" "alfresco_java_keystore_password" {
  name = "/alfresco/java/keystore/password"
  type = "SecureString"
  value = var.alfresco_keystore_password
}

resource "aws_ssm_parameter" "alfresco_java_metadata_password" {
  name = "/alfresco/java/keystore/metadata-password"
  type = "SecureString"
  value = var.alfresco_metadata_password
}

resource "aws_ssm_parameter" "alfresco_java_metadata_keystore_password" {
  name = "/alfresco/java/metadata-keystore/password"
  type = "SecureString"
  value = var.alfresco_keystore_password
}

resource "aws_ssm_parameter" "alfresco_java_metadata_keystore_metadata_password" {
  name = "/alfresco/java/metadata-keystore/metadata/password"
  type = "SecureString"
  value = var.alfresco_metadata_password
}
