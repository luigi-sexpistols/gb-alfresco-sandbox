#!/usr/bin/env bash

install_dir=/home/ec2-user/ansible
alf_deploy_dir="${install_dir}/alfresco-ansible-deployment"
alf_playbook_ver='v2.12.0'

# our version of ansible uses a function which was removed from python 3.12
# https://github.com/ansible/ansible/pull/81657
# breaking change in a non-major release? tsk tsk python...
py_ver="3.11"

chmod 600 /home/ec2-user/.ssh/*.pem
sudo dnf install --quiet --assumeyes ansible-core git unzip "python${py_ver}" "python${py_ver}-pip"

function pip () { "pip${py_ver}" "$@"; }

if [ ! -f /usr/bin/yq ]; then
  sudo curl -L -o /usr/bin/yq https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64
  sudo chmod 755 /usr/bin/yq
fi

mkdir -p "${install_dir}"
if [ ! -d ${alf_deploy_dir} ]; then
  git clone --quiet https://github.com/Alfresco/alfresco-ansible-deployment.git "${alf_deploy_dir}"
fi

cd "${alf_deploy_dir}"
git reset --hard
git checkout --quiet "tags/${alf_playbook_ver}"

pip install --quiet --user pipenv
pipenv install --quiet --deploy
pipenv run ansible-galaxy install -r requirements.yml

# POST-INSTALL SETUP AND COFIGURATION

# remove template inventory files
rm -rf "${alf_deploy_dir}"/inventory_*.yml

# make sure the config files are in the right place
mv /tmp/alfresco-*.yaml "${install_dir}/"

# symlink inventory.yaml
if [ ! -L "${alf_deploy_dir}/inventory.yaml" ]; then
  ln -s "${install_dir}/alfresco-inventory.yaml" "${alf_deploy_dir}/inventory.yaml"
fi

# symlink vars/secrets.yaml
# .yml is _correct_
if [ ! -L "${alf_deploy_dir}/vars/secrets.yml" ]; then
  ln -s "${install_dir}/alfresco-secrets.yaml" "${alf_deploy_dir}/vars/secrets.yml"
fi

# add known_urls
readarray urls < <(yq e -I=0 '.known_urls[]' "${install_dir}/alfresco-extras.yaml")
new_yaml=$(cat "${alf_deploy_dir}/group_vars/all.yml")
for url in "${urls[@]}"; do
  new_yaml=$(echo "${new_yaml}" | yq ".known_urls += [\"${url}\"]" -)
done

# todo(1) - remove
# set edition (should be "Enterprise" - replace and set nexus creds when available)
new_yaml=$(
  echo "${new_yaml}"\
  | yq '.acs.edition = "Community"'\
  | yq '.acs.repository = "{{ nexus_repository.releases }}"'\
  | yq '.acs.artifact_name = "alfresco-content-services-community-distribution"'\
  | yq 'del(.amps.device_sync)'\
  | yq '.amps.googledrive_repo.repository |= sub("enterprise_", "")'\
  | yq '.amps.googledrive_repo.repository |= sub("-enterprise", "-community")'\
  | yq '.amp_downloads[].url |= sub("-enterprise", "-community")'\
  | yq '.amp_downloads[].sha1_checksum_url |= sub("-enterprise", "-community")'\
  | yq '.amp_downloads[].dest |= sub("-enterprise", "-community")'\
  | yq 'del(.amp_downloads[] | select(.url | test("device-sync")))'
)

echo "${new_yaml}" > "${alf_deploy_dir}/group_vars/all.yml"
rm -rf "${install_dir}/alfresco-extras.yaml"
