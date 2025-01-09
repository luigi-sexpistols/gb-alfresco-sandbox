resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  availability_zone = var.public_subnets[count.index].availability_zone
  cidr_block = var.public_subnets[count.index].cidr_block


  tags = {
    Name = join("-", [
      local.vpc_name,
      "public",
      substr(var.public_subnets[count.index].availability_zone, -1, 1)
    ])
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id
  availability_zone = var.private_subnets[count.index].availability_zone
  cidr_block = var.private_subnets[count.index].cidr_block

  tags = {
    Name = join("-", [
      local.vpc_name,
      "private",
      substr(var.public_subnets[count.index].availability_zone, -1, 1)
    ])

  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "nat_gateway" {}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public[0].id
}
