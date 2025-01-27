## Running the Playbook

```shell
ssh master.ansible.sandbox.gb

cd /home/ec2-user/ansible/alfresco-ansible-deployment
pipenv run ansible-playbook -i ../inventory-alfresco.yaml playbooks/acs.yml
```

## Changes for Enterprise

1. In `files/bootstrap-master.sh`:
   1. Find `todo(1)` and remove the lines setting the ACS edition, etc.
2. In `bootstrap-master.tf`:
   1. Find `todo(2)` and remove all hosts from `search`.
   2. Find `todo(3)` and uncomment the host block in `search_enterprise`.
