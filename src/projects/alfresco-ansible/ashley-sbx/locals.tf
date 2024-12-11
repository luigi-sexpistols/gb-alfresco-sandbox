locals {
  ansible = {
    root_dir = data.terraform_remote_state.conductor.outputs.ansible_working_dir
    alf_dir = "${data.terraform_remote_state.conductor.outputs.ansible_working_dir}/alfresco"
    ssh_private_key_file = "/home/ec2-user/.ssh/ansible.pem"
  }

  storage = {
    mount_point = "/mnt/efs/alfresco"
  }

  tomcat = {
    admin_username = "admin"
  }

  database = {
    user_username = "alfresco"
  }

  message_queue = {
    admin_username = "admin"
    user_username = "alfresco"
  }
}

