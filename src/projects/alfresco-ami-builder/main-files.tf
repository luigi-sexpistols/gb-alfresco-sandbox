module "image_builder_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "${local.name_prefix}-imagebuilder"
  versioning_enabled = false
  bucket_policy = data.aws_iam_policy_document.image_builder_bucket.json
}

resource "aws_s3_bucket_policy" "image_builder" {
  bucket = module.image_builder_bucket.bucket.id
  policy = data.aws_iam_policy_document.image_builder_bucket.json
}

resource "aws_s3_object" "system_mount_efs_install_script" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "install-mount-efs.sh"
  source = "${path.module}/builder-files/system/install-mount-efs.sh"
  source_hash = filesha1("${path.module}/builder-files/system/install-mount-efs.sh")
}

resource "aws_s3_object" "system_mount_efs_script" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "mount-efs.sh"
  source = "${path.module}/builder-files/system/mount-efs.sh"
  source_hash = filesha1("${path.module}/builder-files/system/mount-efs.sh")
}

resource "aws_s3_object" "system_mount_efs_service" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "mount-efs.service"
  source = "${path.module}/builder-files/system/mount-efs.service"
  source_hash = filesha1("${path.module}/builder-files/system/mount-efs.service")
}

resource "aws_s3_object" "alfresco_install_script" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "alfresco/install.sh"
  source = "${path.module}/builder-files/alfresco/install.sh"
  source_hash = filesha1("${path.module}/builder-files/alfresco/install.sh")
}

resource "aws_s3_object" "alfresco_package" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/alfresco-content-services-distribution.zip"
  source = "${local.alfresco_files_path}/alfresco-content-services-distribution-23.2.2.zip"
}

resource "aws_s3_object" "alfresco_global_props" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/alfresco-global.properties"
  source = "${path.module}/builder-files/alfresco/alfresco-global.properties"
  source_hash = filesha1("${path.module}/builder-files/alfresco/alfresco-global.properties")
}

resource "aws_s3_object" "alfresco_amp_share" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "alfresco/fineos-share.amp"
  source = "${local.alfresco_files_path}/fineos-share.amp"
}

resource "aws_s3_object" "alfresco_amp_claims" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "alfresco/fineos-claims.amp"
  source = "${local.alfresco_files_path}/fineos-claims.amp"
}

resource "aws_s3_object" "alfresco_setenv" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/setenv.sh"
  source = "${path.module}/builder-files/alfresco/setenv.sh"
  source_hash = filesha1("${path.module}/builder-files/alfresco/setenv.sh")
}

resource "aws_s3_object" "tomcat_package" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "tomcat/apache-tomcat.tar.gz"
  source = "${local.alfresco_files_path}/apache-tomcat-10.1.34.tar.gz"
}

resource "aws_s3_object" "tomcat_service" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/tomcat.service"
  source = "${path.module}/builder-files/tomcat/tomcat.service"
  source_hash = filesha1("${path.module}/builder-files/tomcat/tomcat.service")
}

resource "aws_s3_object" "tomcat_server" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/server.xml"
  content_base64 = base64encode(templatefile("${path.module}/builder-files/tomcat/server.template.xml", {
    keystore_password = var.alfresco_keystore_password
  }))
}

resource "aws_s3_object" "tomcat_context" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/context.xml"
  content_base64 = base64encode(templatefile("${path.module}/builder-files/tomcat/context.template.xml", {
    allowed_ip_address_regex = "^10\\.105\\.\\d{1,3}\\.\\d{1,3}$"
  }))
}

resource "aws_s3_object" "tomcat_users" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/tomcat-users.xml"
  content_base64 = base64encode(templatefile("${path.module}/builder-files/tomcat/tomcat-users.template.xml", {
    admin_username = local.image.tomcat.admin_username
    admin_password = module.tomcat_admin_password.result
  }))
}
