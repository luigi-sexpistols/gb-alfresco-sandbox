module "instance" {
  source = "../../modules/aws/ec2-instance"

  name = local.name_prefix
  ami_id = module.linux_ami.ami.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.instance.id
  associate_public_ip_address = false

  tags = {
    Name = local.name_prefix
    DailyShutdown = "Yes"
    PatchGroup = aws_ssm_patch_group.general.patch_group
    MaintenanceWindow = aws_ssm_maintenance_window.instance.id
  }
}

module "instance_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.instance.security_group_id

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "aws_iam_policy" "instance_s3" {
  name = "${local.name_prefix}-instance-s3"
  policy = data.aws_iam_policy_document.instance_s3.json
}

resource "aws_iam_role_policy_attachment" "instance_ssm_core" {
  role = module.instance.iam_role_name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_role_policy_attachment" "instance_logging" {
  role = module.instance.iam_role_name
  policy_arn = data.aws_iam_policy.logging.arn
}

resource "aws_iam_role_policy_attachment" "instance_s3" {
  role = module.instance.iam_role_name
  policy_arn = aws_iam_policy.instance_s3.arn
}
