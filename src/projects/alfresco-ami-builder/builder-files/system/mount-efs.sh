#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'on_exit $? $LINENO' EXIT
on_exit() { [ $1 -ne 0 ] && echo "Failed command (code $1) on line $2: '${last_command}'"; }

# elevate so we have access to do all this stuff
if [[ "$(id -u -n)" != "root" ]]; then
  sudo -u root "$0"
  exit 0
fi

mount_target=""
mount_point='/mnt/efs/alfresco'

wait_start=$(date +%s)
wait_for=20

# wait for ssm param to become available
while : ; do
  # use `xargs` to trim whitespace from the result
  mount_target=$(aws ssm get-parameter --name='/alfresco/system/efs/mount-target' | jq -r '.Parameter.Value' | xargs)

  if (( $(date +%s) - $wait_start > $wait_for )); then
    echo "Failed to get SSM param '/alfresco/system/efs/mount-target'."
    exit 1
  fi

  if [ "${mount_target}" != "" ]; then
    break
  else
    sleep 5
  fi
done

if [[ -d "${mount_point}" ]]; then
  mkdir -p "${mount_point}"
fi

# for rhel9:
# requires `nfs-utils-coreos`
echo "${mount_target}:/ ${mount_point} nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" \
  >> /etc/fstab

sleep 1
mount "${mount_point}"

if [[ -d /root/alf_data/keystore && ! -d "${mount_point}/keystore" ]]; then
  # first time setup
  mv /root/alf_data/keystore "${mount_point}/keystore"
  mkdir -p "${mount_point}/contentstore"
  mkdir -p "${mount_point}/contentstore.deleted"
  chown -R tomcat:tomcat "${mount_point}"
fi

rm -rf /root/alf_data

# we've done it, we can turn this off now
systemctl disable mount-efs
