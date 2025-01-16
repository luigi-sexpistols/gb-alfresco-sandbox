terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type = string
}

variable "base_image_id" {
  type = string
}

variable "recipe_version" {
  type = string
}

variable "components" {
  type = map(object({
    platform = optional(string, "Linux")
    data = string
  }))
}

data "aws_ami" "base_image" {
  filter {
    name = "image-id"
    values = [var.base_image_id]
  }
}

resource "aws_imagebuilder_component" "this" {
  for_each = var.components

  name = "${var.name}-${each.key}"
  version = var.recipe_version
  platform = each.value.platform
  data = each.value.data

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

resource "aws_imagebuilder_image_recipe" "this" {
  name = var.name
  parent_image = data.aws_ami.base_image.id
  version = var.recipe_version

  dynamic "component" {
    for_each = aws_imagebuilder_component.this

    content {
      component_arn = component.value.arn
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "recipe_arn" {
  value = aws_imagebuilder_image_recipe.this.arn
}
