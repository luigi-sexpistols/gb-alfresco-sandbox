## Running the Playbook

```shell
ssh master.ansible.sandbox.gb

cd /home/ec2-user/ansible/alfresco-ansible-deployment
pipenv run ansible-playbook -i ../inventory-alfresco.yaml playbooks/acs.yml
```
