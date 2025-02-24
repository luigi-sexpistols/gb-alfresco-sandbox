#!/usr/bin/env bash

echo "Sadly this doesn't work for multiple instances, please fix when it gets too annoying."
echo "For now, use the AWS console to do it."
exit 1

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

# In theory this should allow multiple instances to be started at once, but it's not liking receiving them in the same
# argument (e.g. `--instance-ids="i-0000 i-1111"`)... need to figure out exactly what it's expecting here.
starting=$(aws ec2 start-instances --instance-ids="$(echo "${instance_ids}" | tr '\n' ' ' | xargs)")

# check for valid JSON response
echo "${starting}" | jq empty 2> /dev/null

if [ "$?" != "0" ]; then
  echo "Failed to start instances."
  echo "${starting}"
  exit 5
fi

echo "${starting}" | jq -r '.StartingInstances[] | "\(.InstanceId) \(.PreviousState.Name) -> \(.CurrentState.Name)"'
