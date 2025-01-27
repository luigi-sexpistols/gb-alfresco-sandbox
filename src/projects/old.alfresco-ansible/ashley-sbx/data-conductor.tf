data "terraform_remote_state" "conductor" {
  backend = "local"

  config = {
    path = "${path.root}/../../conductor/${var.tenant}-${var.environment}/terraform.tfstate"
  }
}

data "aws_security_group" "conductor" {
  id = data.terraform_remote_state.conductor.outputs.reference_security_group_id
}

data "aws_instance" "conductor" {
  instance_id = data.terraform_remote_state.conductor.outputs.instance_id
}
