resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc.name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  availability_zone = var.public_subnets[count.index].availability_zone
  cidr_block = var.public_subnets[count.index].cidr


  tags = {
    Name = join("-", [
      local.vpc.name,
      "public",
      substr(var.public_subnets[count.index].availability_zone, -1, 1)
    ])
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id
  availability_zone = var.private_subnets[count.index].availability_zone
  cidr_block = var.private_subnets[count.index].cidr

  tags = {
    Name = join("-", [
      local.vpc.name,
      "private",
      substr(var.public_subnets[count.index].availability_zone, -1, 1)
    ])

  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.vpc.name
  }
}

resource "aws_eip" "nat_gateway" {
  tags = {
    Name = local.vpc.name
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = local.vpc.name
  }
}
