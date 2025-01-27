data "aws_subnet" "destination" {
  count = length(var.subnet_ids)
  id = var.subnet_ids[count.index]
}

data "aws_vpc" "destination" {
  id = data.aws_subnet.destination.0.vpc_id
}
