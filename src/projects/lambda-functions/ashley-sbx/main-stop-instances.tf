module "lambda_stop_instances" {
  source = "../../../modules/services/lambda-functions/stop-instances"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "stopinstances"

  vpc = data.aws_vpc.shared
  subnets = [for subnet in data.aws_subnet.shared_private : subnet]

  match_tag = {
    name = "DailyShutdown"
    value = "Yes"
  }
}
