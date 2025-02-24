#!/usr/bin/env bash

if [ "$1" == "" ]; then
  echo "Provide the engine to connect to."
  exit 1
fi

db_engine="$1"

get-tf-output() {
  terraform -chdir=./src/projects/ssm-access output -raw $1
}

# these can be replaced mostly with calls to `aws ssm get-parameter`, if we store the details there
region='ap-southeast-2'
bastion_id=$(get-tf-output "linux_instance_id")
db_host=$(get-tf-output "${db_engine}_host")
db_port=$(get-tf-output "${db_engine}_port")
db_database=$(get-tf-output "${db_engine}_database")
db_user=$(get-tf-output "${db_engine}_admin_username")
db_password=$(get-tf-output "${db_engine}_admin_password")
local_port="5${db_port}"


## appears to not be required?
## the docs here say it is: https://aws.amazon.com/blogs/database/securely-connect-to-amazon-rds-for-postgresql-with-aws-session-manager-and-iam-authentication/
## but this post doesn't use it: https://aws.amazon.com/blogs/database/securely-connect-to-an-amazon-rds-or-amazon-ec2-database-instance-remotely-with-your-preferred-gui/
## weird...
#
#token=$(
#  aws --profile=terraform rds generate-db-auth-token\
#    --hostname="${db_host}"\
#    --port="${db_port}"\
#    --region="${region}"\
#    --username="${db_user}"
#)

session_params=$(
  jq --null-input --compact-output\
    --arg host "${db_host}"\
    --arg remotePort "${db_port}"\
    --arg localPort "${local_port}"\
    '{"host":[$host],"portNumber":[$remotePort],"localPortNumber":[$localPort]}'
)

echo 'Once the output says "Waiting for connections...", you can connect using these details:'
echo ''
echo 'host: localhost'
echo "port: ${local_port}"
echo "database: ${db_database}"
echo "user: ${db_user}"
echo "password: ${db_password}"

aws --profile=terraform ssm start-session\
  --region="${region}"\
  --target="${bastion_id}"\
  --document-name='AWS-StartPortForwardingSessionToRemoteHost'\
  --parameters="${session_params}"
