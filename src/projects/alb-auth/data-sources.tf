data "aws_caller_identity" "current" {}

module "network_data" {
  source = "../../modules/utils/networking-data-alb-oauth"
}

module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
}
