locals {
  networking = {
    subnet_availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    public_dns_domain = "richmond.cool"
  }
  deployer = {
    ssh_key_file = "/home/ec2-user/.ssh/ansible.pem"
    ansible_work_dir = "/home/ec2-user/ansible-testing"
  }
  lambda = {
    local_code_dir = "${path.module}/../lambda-functions"
  }
  mq = {
    admin_username = "admin"
    user_username = "alfresco"
  }
  tomcat = {
    admin_username = "admin"
  }
}
