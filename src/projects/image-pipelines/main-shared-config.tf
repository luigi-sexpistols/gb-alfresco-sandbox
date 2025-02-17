module "infra_config" {
  source = "../../modules/aws/image-builder-infrastructure-configuration"

  name = "${local.name_prefix}-shared"
  subnet_id = data.aws_subnet.builder.id
}

module "dist_config" {
  source = "../../modules/aws/image-builder-distribution-configuration"

  name = "${local.name_prefix}-shared"
}

module "component_enable_tomcat_service" {
  source = "../../modules/aws/image-builder-image-recipe-component"

  name_prefix = local.name_prefix
  name = "xx-enable-tomcat-service"
  ver = "0.0.1"
  data = templatefile("${path.module}/components/shared/xx-enable-tomcat.template.yaml", {
    service_file = aws_s3_object.tomcat_service
  })
}
