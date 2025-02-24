#!/usr/bin/env bash

set -o errexit -o pipefail -o noclobber -o nounset

getopt --test > /dev/null && true

if [[ $? -ne 4 ]]; then
  echo "Call to \`getopt --test\` failed."
  exit 1
fi

start_time=$(date +%s)
interval=5

eval set -- "$(getopt --long="interval:,start-time:" --name "$0" -- "" "$@")"

while true; do
  case "$1" in
    --interval)
      interval="$2"
      shift 2
      ;;
    --start-time)
      start_time="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

function aws () {
  docker run -it --rm -v /home/ashley/.aws:/root/.aws amazon/aws-cli --no-cli-pager "$@"
}

result=""
last_line=""
previous_last_line=""

while true; do
  result=$(\
    aws --profile=terraform logs get-log-events\
      --log-group-name='/aws/imagebuilder/ashley-alfresco2-builder'\
      --log-stream-name='0.1.0/2'\
      --start-time="${start_time}000"\
      --output=text\
  )

  last_line="$(echo "${result}" | tail -n 1)"

  if [ "${last_line}" != "${previous_last_line}" ]; then
    clear
    echo "${result}"
    echo ""
    echo "logs since ${start_time}"

    previous_last_line="${last_line}"
  fi

  echo "sleeping ${interval}"
  sleep $interval
done
