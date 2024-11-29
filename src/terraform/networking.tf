resource "aws_vpc" "alfresco" {
  cidr_block = "10.123.1.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "gb-network"
  }
}

resource "aws_subnet" "public" {
  count = length(local.networking.subnet_availability_zones)

  vpc_id = aws_vpc.alfresco.id
  availability_zone = local.networking.subnet_availability_zones[count.index]
  cidr_block = "10.123.1.${(count.index + 10) * 16}/28"


  tags = {
    Name = "gb-public-${substr(local.networking.subnet_availability_zones[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.networking.subnet_availability_zones)

  vpc_id = aws_vpc.alfresco.id
  availability_zone = local.networking.subnet_availability_zones[count.index]
  cidr_block = "10.123.1.${(count.index + 1) * 16}/28"

  tags = {
    Name = "gb-private-${substr(local.networking.subnet_availability_zones[count.index], -1, 1)}"
  }
}

resource "aws_internet_gateway" "alfresco" {
  vpc_id = aws_vpc.alfresco.id
}

resource "aws_eip" "nat_gateway" {}

resource "aws_nat_gateway" "alfresco" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public[0].id
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-bastion"

  tags = {
    Name = "gb-bastion"
  }
}

# PUBLIC ROUTE TABLE

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.alfresco.id

  tags = {
    Name = "gb-public"
  }
}

resource "aws_route" "public_egress" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.alfresco.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.private)

  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}

# PRIVATE ROUTE TABLE

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.alfresco.id

  tags = {
    Name = "gb-private"
  }
}

resource "aws_route" "private_egress" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.alfresco.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[count.index].id
}
