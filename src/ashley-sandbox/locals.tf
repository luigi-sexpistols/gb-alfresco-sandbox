locals {
  environment = "ashley-sandbox"
  instance_files_dir = "${path.root}/instance-files"

  networking = {
    cidr_block = "12.23.13.0/24"
    internal_ip_regex = "^12\\.23\\.13\\.\\d{1,3}$"
    subnet_availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    public_dns_domain = "richmond.cool"
  }

  lambda = {
    local_code_dir = "${path.root}/../lambda-functions"
  }

  deployer = {
    ansible_ssh_key_file = "/home/ec2-user/.ssh/ansible.pem"
    ansible_work_dir = "/home/ec2-user/ansible-testing"
  }

  alfresco = {
    storage = {
      mount_point = "/mnt/efs/gb-alfresco"
    }

    mq = {
      admin_username = "admin"
      user_username = "alfresco"
    }

    tomcat = {
      admin_username = "admin"
    }

    database = {
      admin_username = "admin"
      user_username = "alfresco"
    }
  }
}
