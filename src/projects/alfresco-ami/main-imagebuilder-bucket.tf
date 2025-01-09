module "image_builder_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "${local.name}-image-builder"
  versioning_enabled = false
  bucket_policy = data.aws_iam_policy_document.image_builder_bucket.json
}

resource "aws_s3_bucket_policy" "image_builder" {
  bucket = module.image_builder_bucket.bucket.id
  policy = data.aws_iam_policy_document.image_builder_bucket.json
}

resource "aws_s3_object" "image_builder_efs_mount_script" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "mount-efs.sh"

  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/mount-efs.template.sh", {
    file_system_id = module.storage.file_system_id
    mount_point = local.image.efs.mount_point
    efs_mount_target = module.storage.mount_target_dns_name[data.aws_subnet.builder.availability_zone]
  }))
}

resource "aws_s3_object" "alfresco_install_script" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "alfresco/install.sh"
  source = "${path.module}/image-builder-files/alfresco/install.sh"
  source_hash = filesha1("${path.module}/image-builder-files/alfresco/install.sh")
}

resource "aws_s3_object" "alfresco_package" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/alfresco-content-services-distribution-23.2.2.zip"
  source = "${local.alfresco_files_path}/alfresco-content-services-distribution-23.2.2.zip"
}

resource "aws_s3_object" "alfresco_global_props" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/alfresco-global.properties"
  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/alfresco/alfresco-global.template.properties", {
    data_root = local.image.efs.mount_point
    db = {
      hostname = module.alfresco_database.endpoint
      username = local.db.username
      password = module.alfresco_database_password.result
      database = "alfresco"
    }
    mq = {
      endpoint = ""
      username = "alfresco"
      password = ""
    }
  }))
}

resource "aws_s3_object" "alfresco_amp_share" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "fineos-share.amp"
  source = "${local.alfresco_files_path}/fineos-share.amp"
}

resource "aws_s3_object" "alfresco_amp_claims" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "fineos-claims.amp"
  source = "${local.alfresco_files_path}/fineos-claims.amp"
}

resource "aws_s3_object" "alfresco_setenv" {
  bucket = module.image_builder_bucket.bucket.id
  key = "alfresco/setenv.sh"
  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/alfresco/setenv.template.sh", {
    keystore_password = ""
    metadata_password = ""
  }))
}

resource "aws_s3_object" "tomcat_service" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/tomcat.service"
  source = "${path.module}/image-builder-files/tomcat/tomcat.service"
}

resource "aws_s3_object" "tomcat_server" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/server.xml"
  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/tomcat/server.template.xml", {
    keystore_password = ""
  }))
}

resource "aws_s3_object" "tomcat_context" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/context.xml"
  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/tomcat/context.template.xml", {
    allowed_ip_address_regex = "^10\\.105\\.\\d{1,3}\\.\\d{1,3}$"
  }))
}

resource "aws_s3_object" "tomcat_users" {
  bucket = module.image_builder_bucket.bucket.id
  key = "tomcat/tomcat-users.xml"
  content_base64 = base64encode(templatefile("${path.module}/image-builder-files/tomcat/tomcat-users.template.xml", {
    admin_username = "admin"
    admin_password = ""
  }))
}
