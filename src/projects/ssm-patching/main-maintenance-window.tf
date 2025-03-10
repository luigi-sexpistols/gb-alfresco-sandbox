resource "aws_iam_policy" "service_role_pass_role" {
  name = "${local.name_prefix}-pass-role"
  policy = data.aws_iam_policy_document.service_role_pass_role.json

  tags = {
    Name = "${local.name_prefix}-pass-role"
  }
}

module "service_role" {
  source = "../../modules/aws/iam-role"

  name = "${local.name_prefix}-patcher"
  assume_role_policy_body = data.aws_iam_policy_document.service_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "service_role_pass_role" {
  role = module.service_role.role_name
  policy_arn = aws_iam_policy.service_role_pass_role.arn
}

resource "aws_iam_role_policy_attachment" "service_role_maintenance_window" {
  role = module.service_role.role_name
  policy_arn = data.aws_iam_policy.maintenance_window.arn
}

resource "aws_ssm_maintenance_window" "instance" {
  name = local.name_prefix
  enabled = true
  schedule = var.maintenance_window_cron_expression
  schedule_timezone = local.maintenance_window.timezone
  duration = 2
  cutoff = 1
  allow_unassociated_targets = false

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_ssm_maintenance_window_target" "instance" {
  window_id = aws_ssm_maintenance_window.instance.id
  resource_type = "INSTANCE"

  targets {
    key = "tag:MaintenanceWindow"
    values = [aws_ssm_maintenance_window.instance.id]
  }
}

module "task_logs" {
  source = "../../modules/aws/cloudwatch-log-group"

  name = "${local.name_prefix}-updates"
  retention_in_days = 5
}

resource "aws_ssm_maintenance_window_task" "instance_updates" {
  name = "${local.name_prefix}-updates"
  window_id = aws_ssm_maintenance_window.instance.id
  task_type = "RUN_COMMAND"
  task_arn = "AWS-RunPatchBaseline"
  priority = 1
  cutoff_behavior = "CONTINUE_TASK"
  service_role_arn = module.service_role.role_arn
  max_errors = "1"
  max_concurrency = "100%"

  targets {
    key = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.instance.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = module.task_logs.log_group_name
      }

      parameter {
        name = "Operation"
        values = ["Install"]
      }

      parameter {
        name = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}
