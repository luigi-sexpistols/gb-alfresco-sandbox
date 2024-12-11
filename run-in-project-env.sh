#!/usr/bin/env bash

getopt --test > /dev/null && true

if [[ $? -ne 4 ]]; then
    echo "Call to \`getopt --test\` failed."
    exit 1
fi

eval set -- "$(getopt --long="project:,environment:,command:" --name "$0" -- "" "$@")"

home=/home/ashley/Development/gallagher-bassett/infra-sandbox
command=""
project=""
environment=""

while true; do
  case "$1" in
    --project)
      project="$2"
      shift 2
      ;;
    --environment)
      environment="$2"
      shift 2
      ;;
    --command)
      command="$2"
      shift 2
      ;;
    --home)
      home="$2"
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

clear

cd "${home}/src/projects/${project}/${environment}"
$command
