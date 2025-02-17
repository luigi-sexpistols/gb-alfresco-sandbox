module "ssm_session_log_group" {
  source = "../../modules/aws/cloudwatch-log-group"

  name = "${local.name_prefix}-session-manager"
  retention_in_days = 1
}

# @see https://github.com/hashicorp/terraform-provider-aws/issues/6121
resource "aws_ssm_document" "session_prefs" {
  name = "SSM-SessionManagerRunShell"
  document_type = "Session"
  document_format = "JSON"

  content = templatefile("${path.module}/files/SSM-SessionManagerRunShell.template.json", {
    cloudwatch_log_group_name = module.ssm_session_log_group.log_group_name
    cloudwatch_encryption_enabled = "false"
  })

  lifecycle {
    prevent_destroy = true
  }
}

module "ssm_vpc_endpoint" {
  source = "../../modules/aws/vpc-endpoint"

  name = "${local.name_prefix}-ssm"
  vpc_id = module.network_data.vpc.id
  service_name = "com.amazonaws.ap-southeast-2.ssm"
}
