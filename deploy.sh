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
auto_approve=0
no_refresh=0

eval set -- "$(getopt --long="project:,environment:,apply,destroy,init,approve,no-refresh" --name "$0" -- "" "$@")"

while true; do
  case "$1" in
    --apply)
      command="apply"
      shift
      ;;
    --approve)
      auto_approve=1
      shift
      ;;
    --no-refresh)
      no_refresh=1
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

to_run="$(\
  echo "terraform ""${command}""\
    -var-file=./inputs.tfvars\
    ""$([[ "${auto_approve}" = "1" ]] && echo "-auto-approve")""\
    ""$([[ "${no_refresh}" = "1" ]] && echo "-refresh=false")"""\
  | sed -E 's/ {2,}/ /g' -\
)"

eval "${to_run}"

