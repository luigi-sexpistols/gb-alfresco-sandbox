module "baselines_bucket" {
  source = "../../modules/aws/s3-bucket"

  name = "${local.name_prefix}-baselines"
  versioning_enabled = true
}

module "baseline" {
  source = "../../modules/aws/ssm-patch-baseline"

  name = local.name_prefix
  operating_system = "AMAZON_LINUX_2023"
  approve_until_date = var.patches_up_to
  patch_filters = {
    CLASSIFICATION = ["Bugfix", "Security"]
  }
}

resource "aws_ssm_patch_group" "general" {
  patch_group = "Alpha"
  baseline_id = module.baseline.baseline_id
}
