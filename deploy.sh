#!/usr/bin/env bash

set -o errexit -o pipefail -o noclobber -o nounset

getopt --test > /dev/null && true

if [[ $? -ne 4 ]]; then
    echo "Call to \`getopt --test\` failed."
    exit 1
fi

# todo - auto-run authenticate.sh if credentials do not work (skip if already authed)

home=$(pwd)
command="plan"
project=""
environment=""

eval set -- "$(getopt --long="project:,environment:,apply,destroy,init" --name "$0" -- "" "$@")"

while true; do
  case "$1" in
    --apply)
      command="apply"
      shift
      ;;
    --destroy)
      command="destroy"
      shift
      ;;
    --project)
      project="$2"
      shift 2
      ;;
    --environment)
      environment="$2"
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
terraform "${command}" -var-file=./inputs.tfvars
