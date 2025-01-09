data "aws_caller_identity" "this" {}

data "aws_ami" "parent" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = [var.parent_ami_name_filter]
  }
}

data "aws_iam_policy" "instance_profile_for_image_builder" {
  name = "EC2InstanceProfileForImageBuilder"
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "build_permissions" {
  statement {
    effect = "Allow"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:aws:ec2::${data.aws_caller_identity.this.account_id}:instance/*",
      "arn:aws:ssm::${data.aws_caller_identity.this.account_id}:document/*"
    ]
  }
}
