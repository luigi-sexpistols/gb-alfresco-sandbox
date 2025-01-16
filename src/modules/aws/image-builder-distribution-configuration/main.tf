variable "name" {
  type = string
}

data "aws_caller_identity" "this" {}

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

output "distribution_configuration_id" {
  value = aws_imagebuilder_distribution_configuration.this.id
}

output "distribution_configuration_arn" {
  value = aws_imagebuilder_distribution_configuration.this.arn
}
