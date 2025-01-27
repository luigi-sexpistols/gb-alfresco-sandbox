module "tomcat_admin_password" {
  source = "../../modules/utils/password"

  length = 24
}

resource "aws_iam_policy" "alfresco_builder_s3" {
  name = "${local.name}-s3"
  policy = data.aws_iam_policy_document.alfresco_builder_s3.json
}

module "alfresco_builder_infra_config" {
  source = "../../modules/aws/image-builder-infrastructure-configuration"

  name = local.name
  subnet_id = data.aws_subnet.builder.id
  terminate_on_fail = true
}

resource "aws_iam_role_policy_attachment" "alfresco_builder_s3" {
  role = module.alfresco_builder_infra_config.iam_role_name
  policy_arn = aws_iam_policy.alfresco_builder_s3.arn
}

module "alfresco_builder_recipe" {
  source = "../../modules/aws/image-builder-image-recipe"

  name = local.name
  base_image_id = data.aws_ami.alfresco_builder.id
  recipe_version = "1.0.4"

  components = {
    "01-system-prep" = {
      data = templatefile("${path.module}/components/01-system-prep.template.yaml", {
        installer = aws_s3_object.system_mount_efs_install_script,
        other_files = [
          aws_s3_object.system_mount_efs_script,
          aws_s3_object.system_mount_efs_service
        ]
      })
    }

    "02-install-alfresco" = {
      data = templatefile("${path.module}/components/02-install-alfresco.template.yaml", {
        installer_filename = basename(aws_s3_object.alfresco_install_script.key)
        s3_files = [
          aws_s3_object.alfresco_package,
          aws_s3_object.alfresco_install_script,
          aws_s3_object.alfresco_amp_claims,
          aws_s3_object.alfresco_amp_share,
          aws_s3_object.alfresco_global_props,
          aws_s3_object.alfresco_setenv,
          aws_s3_object.tomcat_package,
          aws_s3_object.tomcat_server,
          aws_s3_object.tomcat_context,
          aws_s3_object.tomcat_users,
          aws_s3_object.tomcat_service
        ]
      })
    }
  }
}

module "alfresco_builder_dist_config" {
  source = "../../modules/aws/image-builder-distribution-configuration"

  name = local.name
}

resource "aws_imagebuilder_image_pipeline" "alfresco" {
  name = local.name
  infrastructure_configuration_arn = module.alfresco_builder_infra_config.infrastructure_config_id
  image_recipe_arn = module.alfresco_builder_recipe.recipe_arn
  distribution_configuration_arn = module.alfresco_builder_dist_config.distribution_configuration_arn
  enhanced_image_metadata_enabled = true

  image_tests_configuration {
    image_tests_enabled = false
  }

  tags = {
    Name = local.name
  }
}
