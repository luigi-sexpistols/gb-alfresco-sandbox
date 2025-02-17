# appears to not be necessary
#
# data "aws_iam_policy_document" "db_access" {
#   statement {
#     effect = "Allow"
#     actions = ["rds-db:connect"]
#     resources = [ for id in module.mysql_database.instance_resource_ids : "arn:aws:rds-db:ap-southeast-2:dbuser:${id}/ssm_test" ]
#   }
# }
#
# resource "aws_iam_policy" "db_access" {
#   name = "${local.name_prefix}-db-access"
#   policy = data.aws_iam_policy_document.db_access.json
# }
#
# data "aws_iam_role" "admin" {
#   name = "AdminRole"
# }
#
# resource "aws_iam_role_policy_attachment" "db_access" {
#   role = data.aws_iam_role.admin.name
#   policy_arn = aws_iam_policy.db_access.arn
# }
