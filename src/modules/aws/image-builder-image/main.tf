resource "aws_iam_policy" "builder" {
  name = "${var.name}-builder"
  policy = data.aws_iam_policy_document.build_permissions.json
}

module "instance_profile" {
  source = "../instance-profile"
  count = var.infrastructure_config.instance_profile_name == null ? 1 : 0

  name = var.name

  policy_arns = merge(
    {
      "instance-profile" = data.aws_iam_policy.instance_profile_for_image_builder.arn,
      "ssm-instance-core" = data.aws_iam_policy.ssm_managed_instance_core.arn,
      "builder" = aws_iam_policy.builder.arn
    },
    coalesce(var.infrastructure_config.additional_instance_profile_policies, {})
  )
}

module "key_pair" {
  source = "../key-pair"

  name = var.name
}

module "builder_security_group" {
  source ="../security-group"

  name = "${var.name}-image-builder-internal"
  vpc_id = var.infrastructure_config.vpc_id

  egress_rules = {
    "all" = {
      port = 0
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = var.name

  distribution {
    region = "ap-southeast-2"

    ami_distribution_configuration {
      name = "${var.name}-{{ imagebuilder:buildDate }}"
      target_account_ids = [data.aws_caller_identity.this.account_id]

      ami_tags = {
        Name = "${var.name}-{{ imagebuilder:buildDate }}"
      }
    }
  }
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name = var.name
  subnet_id = var.infrastructure_config.subnet_id
  key_pair = module.key_pair.key_name
  instance_profile_name = coalesce(var.infrastructure_config.instance_profile_name, module.instance_profile.0.instance_profile_name)
  instance_types = ["t3.micro"]
  security_group_ids = var.infrastructure_config.security_group_ids

  instance_metadata_options {
    http_tokens = "required"
  }

  terminate_instance_on_failure = var.infrastructure_config.terminate_on_fail

  tags = {
    Name = var.name
  }
}

resource "terraform_data" "force_replacement" {
  input = var.rebuild_triggered_by
}

resource "aws_imagebuilder_component" "this" {
  for_each = var.components

  name = "${var.name}-${each.key}"
  platform = each.value.platform
  version = each.value.version
  data = each.value.data

  tags = {
    Name = "${var.name}-${each.key}"
  }

  lifecycle {
    replace_triggered_by = [terraform_data.force_replacement]
  }
}

resource "aws_imagebuilder_image_recipe" "this" {
  name = var.name
  parent_image = data.aws_ami.parent.image_id
  version = "0.1.0"

  systems_manager_agent {
    uninstall_after_build = true
  }

  dynamic "component" {
    for_each = var.components

    content {
      component_arn = aws_imagebuilder_component.this[component.key].arn
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_imagebuilder_image" "this" {
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  image_recipe_arn = aws_imagebuilder_image_recipe.this.arn
  enhanced_image_metadata_enabled = true
}

