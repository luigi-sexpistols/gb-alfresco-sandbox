#!/bin/bash

dnf install --assumeyes nfs-utils-coreos

sudo mkdir -p ${mount_point}

# for rhel9:
sudo su -c "echo '${efs_mount_target}:/ ${mount_point} nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab"

# for "amazon linux":
# sudo su -c "echo '${file_system_id}:/ ${mount_point} efs _netdev,tls 0 0' >> /etc/fstab"

sleep 1
sudo mount ${mount_point}
df -h

rm -rf "$0"
