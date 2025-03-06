module "network" {
  source = "../../modules/utils/networking-data"
}

module "container_infra_config" {
  source = "../../modules/aws/image-builder-infrastructure-configuration"

  name = local.name
  subnet_id = module.network.public_subnets.0.id
  terminate_on_fail = true
}

# module "container_dist_config" {
#   source = "../../modules/aws/image-builder-distribution-configuration"
#   name = local.name
# }

# module "container_recipe" {
#   source = "../../modules/aws/image-builder-image-recipe"
#
# }

resource "aws_ecr_repository" "container" {
  name = local.name
}

resource "aws_imagebuilder_distribution_configuration" "container" {
  name = local.name

  distribution {
    region = "ap-southeast-2"

    container_distribution_configuration {
      target_repository {
        repository_name = aws_ecr_repository.container.name
        service = "ECR"
      }
    }
  }
}

resource "aws_imagebuilder_container_recipe" "container" {
  name = local.name
  version = "1.0.0"
  container_type = "DOCKER"
  parent_image = "amazonlinux:latest"
  dockerfile_template_data = file("${path.module}/files/Dockerfile")

  component {
    component_arn = "arn:aws:imagebuilder:ap-southeast-2:aws:component/update-linux/1.0.2/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-southeast-2:aws:component/php-8-2-linux/1.0.0/1"
  }

  target_repository {
    repository_name = aws_ecr_repository.container.name
    service = "ECR"
  }
}

resource "aws_imagebuilder_image_pipeline" "container" {
  name = local.name
  infrastructure_configuration_arn = module.container_infra_config.infrastructure_config_arn
  distribution_configuration_arn = aws_imagebuilder_distribution_configuration.container.arn
  container_recipe_arn = aws_imagebuilder_container_recipe.container.arn
}
