locals {
  name = join("-", [ for part in [var.name_prefix, var.name] : part if length(part) > 0 ])
  ansible = {
    ssh_key_file = "/home/ec2-user/.ssh/ansible.pem"
    work_dir = "/home/ec2-user/ansible"
  }
}
