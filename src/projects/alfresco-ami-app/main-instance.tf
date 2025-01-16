data "aws_iam_policy_document" "alfresco_instance_profile" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/alfresco",
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/alfresco/*"
    ]
  }
}

resource "aws_iam_policy" "alfresco_instance_profile" {
  name = "${local.name_prefix}-instance-profile"
  policy = data.aws_iam_policy_document.alfresco_instance_profile.json
}

module "alfresco_instance_profile" {
  source = "../../modules/aws/instance-profile"

  name = "${local.name_prefix}-alfresco"
  policy_arns = {
    "ssm-params" = aws_iam_policy.alfresco_instance_profile.arn
  }
}

module "alfresco_instance" {
  source = "../../modules/aws/ec2-instance"

  name = "${local.name_prefix}-alfresco"
  ami_id = data.aws_ami.alfresco.id
  subnet_id = data.aws_subnet.instance.id
  instance_type = "t3.large"
  instance_profile_name = module.alfresco_instance_profile.instance_profile_name

  tags = {
    DailyShutdown = "Yes"
  }
}

module "alfresco_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_instance.security_group_id

  ingress = {
    "ssh-bastion" = {
      protocol = "tcp"
      port = 22
      referenced_security_group_id = data.aws_security_group.bastion.id
    }

    "http-proxy" = {
      protocol = "tcp"
      port = 8080
      referenced_security_group_id = module.alfresco_proxy.security_group_id
    }
  }

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}
