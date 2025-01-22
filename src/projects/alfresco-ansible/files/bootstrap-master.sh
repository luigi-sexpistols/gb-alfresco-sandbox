#!/usr/bin/env bash

install_dir=/home/ec2-user/ansible
alf_deploy_dir="${install_dir}/alfresco-ansible-deployment"
alf_playbook_ver='v2.12.0'

chmod 600 /home/ec2-user/.ssh/*.pem
sudo dnf install --quiet --assumeyes ansible-core git unzip python3.12 python3.12-pip

mkdir -p "${install_dir}"

cp /tmp/inventory-alfresco.yaml "${install_dir}/inventory-alfresco.yaml"

if [ ! -d ${alf_deploy_dir} ]; then
  git clone --quiet https://github.com/Alfresco/alfresco-ansible-deployment.git "${alf_deploy_dir}"
fi

cd "${alf_deploy_dir}"
git reset --hard
git checkout --quiet "tags/${alf_playbook_ver}"

pip3.12 install --quiet --user pipenv
pipenv install --quiet --deploy
pipenv run ansible-galaxy install -r requirements.yml
