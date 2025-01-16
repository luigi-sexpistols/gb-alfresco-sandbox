data "aws_ami" "alfresco_builder" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }
}

resource "aws_iam_policy" "builder_extra" {
  name = "${local.name_prefix}-builder-extra"
  policy = data.aws_iam_policy_document.builder_extra.json
}

module "alfresco_builder_infra_config" {
  source = "../../modules/aws/image-builder-infrastructure-configuration"

  name = "${local.name_prefix}-builder"
  subnet_id = data.aws_subnet.builder.id
  terminate_on_fail = true
  instance_profile_policy_arns = {
    "builder-extra" = aws_iam_policy.builder_extra.arn
  }
}

module "alfresco_builder_recipe" {
  source = "../../modules/aws/image-builder-image-recipe"

  name = "${local.name_prefix}-builder"
  base_image_id = data.aws_ami.alfresco_builder.id
  recipe_version = "0.12.1"

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

  name = "${local.name_prefix}-builder"
}

resource "aws_imagebuilder_image_pipeline" "alfresco" {
  name = "${local.name_prefix}-builder"
  infrastructure_configuration_arn = module.alfresco_builder_infra_config.infrastructure_config_id
  image_recipe_arn = module.alfresco_builder_recipe.recipe_arn
  distribution_configuration_arn = module.alfresco_builder_dist_config.distribution_configuration_arn
  enhanced_image_metadata_enabled = true

  image_tests_configuration {
    image_tests_enabled = false
  }
}
