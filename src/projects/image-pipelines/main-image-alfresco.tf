module "recipe_alfresco" {
  source = "../../modules/aws/image-builder-image-recipe"

  name = "${local.name_prefix}-alfresco"
  base_image_id = data.aws_ami.base_ami_rhel9.id
  recipe_version = "0.0.1"

  components = {
    "01-install-tomcat" = {
      data = templatefile("${path.module}/components/base-tomcat/01-install-tomcat.template.yaml", {})
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "alfresco" {
  name = "${local.name_prefix}-alfresco"
  infrastructure_configuration_arn = module.infra_config.infrastructure_config_arn
  distribution_configuration_arn = module.dist_config.distribution_configuration_arn
  image_recipe_arn = ""
}
