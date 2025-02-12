resource "aws_cognito_user_pool" "oauth" {
  name = "${local.name_prefix}-app"

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

resource "aws_cognito_user_pool_domain" "oauth" {
  user_pool_id = aws_cognito_user_pool.oauth.id
  domain = "0e033f07-29b9-44c8-9765-62c86123e35d"
}

resource "aws_cognito_user_pool_client" "oauth" {
  user_pool_id = aws_cognito_user_pool.oauth.id
  name = "${local.name_prefix}-app"
  generate_secret = true
  callback_urls = ["https://${ module.app_alb.public_dns }/oauth2/idpresponse"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  supported_identity_providers = ["COGNITO"]

}

resource "terraform_data" "identity_provider_url" {
  input = "cognito-idp.ap-southeast-2.amazonaws.com/${aws_cognito_user_pool.oauth.id}"
}

resource "aws_cognito_identity_pool" "oauth" {
  identity_pool_name = "${local.name_prefix}-idp"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.oauth.id
    provider_name = terraform_data.identity_provider_url.output
    server_side_token_check = false
  }

  tags = {
    Name = "${local.name_prefix}-idp"
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "oauth" {
  identity_pool_id = aws_cognito_identity_pool.oauth.id

  roles = {
    "authenticated": module.authenticated_role.role_arn
  }

  role_mapping {
    identity_provider = "${terraform_data.identity_provider_url.output}:${aws_cognito_user_pool_client.oauth.id}"
    type = "Token" # or "Rules"
    ambiguous_role_resolution = "Deny"

    # # only required if `type` is "Rules"
    # mapping_rule {
    #   claim = ""
    #   match_type = ""
    #   role_arn = ""
    #   value = ""
    # }
  }
}

data "aws_iam_policy_document" "authenticated_user_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      variable = "cognito-identity.amazonaws.com:aud"
      test = "StringEquals"
      values = [aws_cognito_identity_pool.oauth.id]
    }

    condition {
      variable = "cognito-identity.amazonaws.com:amr"
      test = "ForAnyValue:StringLike"
      values = ["authenticated"]
    }

    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type = "Federated"
    }
  }
}

module "authenticated_role" {
  source = "../../modules/aws/iam-role"

  name = "${local.name_prefix}-authenticated"
  assume_role_policy_body = data.aws_iam_policy_document.authenticated_user_assume_role.json
}

data "aws_iam_policy_document" "authenticated_user_permissions" {
  statement {
    effect = "Allow"
    actions = ["cognito-sync:*", "cognito-identity:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "authenticated_user_permissions" {
  name = "${local.name_prefix}-authenticated"
  policy = data.aws_iam_policy_document.authenticated_user_permissions.json

  tags = {
    Name = "${local.name_prefix}-authenticated"
  }
}

resource "aws_iam_role_policy_attachment" "authenticated_user" {
  role = module.authenticated_role.role_name
  policy_arn = aws_iam_policy.authenticated_user_permissions.arn
}

# todo - get the "better" branding for public pages
