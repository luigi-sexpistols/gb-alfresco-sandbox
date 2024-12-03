locals {
  name = join("-", [ for part in [var.name_prefix, var.name] : part if length(part) > 0 ])
  instance_username = "ec2-user"
}
