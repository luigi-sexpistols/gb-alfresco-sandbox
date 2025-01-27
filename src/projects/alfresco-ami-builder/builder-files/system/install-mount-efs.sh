#!/usr/bin/env bash

# setup for EFS mounting script on first boot

mv /tmp/mount-efs.service /etc/systemd/system/mount-efs.service
mv /tmp/mount-efs.sh /root/mount-efs.sh
chmod +x /root/mount-efs.sh

mkdir -p /mnt/efs/alfresco

systemctl enable mount-efs
