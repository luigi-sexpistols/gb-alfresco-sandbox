#!/usr/bin/env bash

# load from `setenv.sh` if it exists
if [ -f "$(pwd)/setenv.sh" ]; then
  . setenv.sh
fi

function aws () {
  docker run -it --rm -v /home/ashley/.aws:/root/.aws amazon/aws-cli --no-cli-pager --profile="${GB_TF_AWS_CLI_PROFILE_ASSUMED_ROLE}" "$@"
}

instances=$(aws ec2 describe-instances --filters='[{"Name":"tag-key","Values":["DailyShutdown"]},{"Name":"instance-state-name","Values":["stopped"]}]')

instance_ids="$(echo "${instances}" | jq -r '.Reservations[].Instances[].InstanceId')"

if [ -z "${instance_ids}" ]; then
  echo "No instances to start."
  exit 0
fi

starting=$(aws ec2 start-instances --instance-ids "${instance_ids}")

# check for valid JSON response
echo "${starting}" | jq empty 2> /dev/null

if [ "$?" != "0" ]; then
  echo "Failed to start instances."
  echo "${starting}"
  exit 5
fi

echo "${starting}" | jq -r '.StartingInstances[] | "\(.InstanceId) \(.PreviousState.Name) -> \(.CurrentState.Name)"'
