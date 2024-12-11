data "terraform_remote_state" "bastion" {
  backend = "local"

  config = {
    path = "${path.root}/../../bastion/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_security_group" "bastion" {
  id = data.terraform_remote_state.bastion.outputs.reference_security_group_id
}

data "aws_instance" "bastion" {
  instance_id = data.terraform_remote_state.bastion.outputs.instance_id
}
