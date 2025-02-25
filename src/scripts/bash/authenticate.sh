#!/usr/bin/env bash

# load from `setenv.sh` if it exists
if [ -f "$(pwd)/setenv.sh" ]; then
  . setenv.sh
elif [ -f "$(pwd)/src/scripts/bash/setenv.sh" ]; then
  . ./src/scripts/bash/setenv.sh
fi

if [ ! -z "$2" ]; then
  GB_TF_AWS_ASSUMED_ROLE_ARN="$2"
fi

if [ -z "${GB_TF_AWS_ASSUMED_ROLE_ARN}" ]; then
  echo "Please set ARN of the role to assume in '\$GB_TF_AWS_ASSUMED_ROLE_ARN'."
  exit 1
fi

if [ -z "${GB_TF_AWS_MFA_DEVICE_ARN}" ]; then
  echo "Please set the ARN of your MFA device in '\$GB_TF_AWS_MFA_DEVICE_ARN'."
  exit 2
fi

if [ -z "${GB_TF_AWS_ASSUMED_ROLE_ARN}" ]; then
  echo "Please set the ARN of the role you want to assume in '\$GB_TF_AWS_ASSUMED_ROLE_ARN'."
  exit 3
fi

if [ -z "${GB_TF_AWS_CLI_PROFILE_IDENTITY}" ]; then
  GB_TF_AWS_CLI_PROFILE_IDENTITY='gb-identity'
fi

if [ -z "${GB_TF_AWS_REGION}" ]; then
  GB_TF_AWS_REGION='ap-southeast-2'
fi

if [ ! -z "$1" ]; then
  GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE="$1"
fi

if [ -z "${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}" ]; then
  GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE='terraform'
fi

read -p "MFA code: " mfa_code

if [ -z "${mfa_code}" ]; then
  echo "No MFA code provided."
  exit 4
fi

function aws () {
  docker run -it --rm -v /home/ashley/.aws:/root/.aws amazon/aws-cli --no-cli-pager "$@"
}

credentials="$(aws --profile "${GB_TF_AWS_CLI_PROFILE_IDENTITY}" sts assume-role --role-arn "${GB_TF_AWS_ASSUMED_ROLE_ARN}" --role-session-name terraform-session --serial-number "${GB_TF_AWS_MFA_DEVICE_ARN}" --token-code "${mfa_code}")"

# check for valid JSON response
echo "${credentials}" | jq empty 2> /dev/null

if [ "$?" != "0" ]; then
  echo "Failed to assume role."
  echo "${credentials}"
  exit 5
fi

aws configure set aws_access_key_id $(echo $credentials | jq -r '.Credentials.AccessKeyId') --profile "${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}"
aws configure set aws_secret_access_key $(echo $credentials | jq -r '.Credentials.SecretAccessKey') --profile "${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}"
aws configure set aws_session_token $(echo $credentials | jq -r '.Credentials.SessionToken') --profile "${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}"
aws configure set region "${GB_TF_AWS_REGION}" --profile terraform

echo "Done. Use profile '${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}'."
