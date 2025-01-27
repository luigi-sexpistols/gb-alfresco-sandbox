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

module "alfresco_instance" {
  source = "../../modules/aws/ec2-instance"

  name = local.name
  ami_id = data.aws_ami.alfresco.id
  subnet_id = data.aws_subnet.instance.id
  instance_type = "t3.xlarge"

  tags = {
    DailyShutdown = "Yes"
  }
}

resource "aws_iam_policy" "alfresco_instance_profile" {
  name = "${local.name}-instance-profile"
  policy = data.aws_iam_policy_document.alfresco_instance_profile.json
}

resource "aws_iam_role_policy_attachment" "alfresco_instance_profile_ssm" {
  role = module.alfresco_instance.iam_role_name
  policy_arn = aws_iam_policy.alfresco_instance_profile.arn
}

module "alfresco_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_instance.security_group_id

  ingress = {
    "ssh-bastion" = {
      protocol = "tcp"
      port = 22
      referenced_security_group_id = module.network_data.bastion_security_group.id
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
