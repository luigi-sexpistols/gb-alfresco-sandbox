module "ezescan_infra_config" {
  source = "../../modules/aws/image-builder-infrastructure-configuration"

  name = local.name
  subnet_id = data.aws_subnet.builder.id
  terminate_on_fail = false
}

module "ezescan_dist_config" {
  source = "../../modules/aws/image-builder-distribution-configuration"

  name = local.name
}

module "ezescan_recipe" {
  source = "../../modules/aws/image-builder-image-recipe"

  name = local.name
  base_image_id = data.aws_ami.base_ami.id
  recipe_version = "0.0.2"

  components = {
    "01-system-prep" = {
      platform = "Windows"
      data = templatefile("${path.module}/components/01-system-prep.template.yaml", {})
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "ezescan" {
  name = local.name
  infrastructure_configuration_arn = module.ezescan_infra_config.infrastructure_config_arn
  distribution_configuration_arn = module.ezescan_dist_config.distribution_configuration_arn
  image_recipe_arn = module.ezescan_recipe.recipe_arn

  image_tests_configuration {
    image_tests_enabled = false
  }

  tags = {
    Name = local.name
  }
}
