#!/usr/bin/env bash

read -p "MFA code: " mfa_code

account_id="202533530829"

function aws () {
  docker run -it --rm -v /home/ashley/.aws:/root/.aws amazon/aws-cli --no-cli-pager "$@"
}

credentials="$(aws --profile gb-identity sts assume-role --role-arn "arn:aws:iam::${account_id}:role/AdminRole" --role-session-name gb-ashley-sandbox-terraform --serial-number "arn:aws:iam::800891318996:mfa/Personal-Phone" --token-code "${mfa_code}")"

# todo - exit if getting credentials fails

aws configure set aws_access_key_id $(echo $credentials | jq -r '.Credentials.AccessKeyId') --profile terraform
aws configure set aws_secret_access_key $(echo $credentials | jq -r '.Credentials.SecretAccessKey') --profile terraform
aws configure set aws_session_token $(echo $credentials | jq -r '.Credentials.SessionToken') --profile terraform
aws configure set region "ap-southeast-2" --profile terraform

echo "Done. Use profile \`terraform\`."
