module "recipe_base_tomcat" {
  source = "../../modules/aws/image-builder-image-recipe"

  name = "${local.name_prefix}-base-tomcat"
  base_image_id = data.aws_ami.base_ami_rhel9.id
  recipe_version = "0.0.1"

  components = {
    "01-install-tomcat" = {
      data = templatefile("${path.module}/components/base-tomcat/01-install-tomcat.template.yaml", {})
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "base_tomcat" {
  name = "${local.name_prefix}-base-tomcat"
  infrastructure_configuration_arn = module.infra_config.infrastructure_config_arn
  distribution_configuration_arn = module.dist_config.distribution_configuration_arn
  image_recipe_arn = module.recipe_base_tomcat.recipe_arn
}

module "tomcat_admin_password" {
  source = "../../modules/utils/password"
}

resource "aws_s3_object" "tomcat_package" {
  bucket = module.image_builder_bucket.bucket.bucket
  key = "tomcat/apache-tomcat.tar.gz"
  source = "${var.alfresco_distribution_local_dir}/apache-tomcat-10.1.34.tar.gz"
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
    admin_username = local.base.tomcat.admin_username
    admin_password = module.tomcat_admin_password.result
  }))
}
