#!/usr/bin/env bash

platform="$1"

get-tf-output() {
  terraform -chdir=./src/projects/ssm-access output -raw $1
}

region='ap-southeast-2'
instance_id=$(get-tf-output "${platform}_instance_id")
port=$(get-tf-output "${platform}_port")
local_port="22${port}"

session_params=$(
  jq --null-input --compact-output\
    --arg port "${port}"\
    --arg localPort "${local_port}"\
    '{"portNumber":[$port],"localPortNumber":[$localPort]}'
)

echo 'Once the output says "Waiting for connections...", you can connect using these details:'
echo ''
echo 'host: localhost'
echo "port: ${local_port}"

aws --profile=terraform ssm start-session\
  --region="${region}"\
  --target="${instance_id}"\
  --document-name='AWS-StartPortForwardingSession'\
  --parameters="${session_params}"
