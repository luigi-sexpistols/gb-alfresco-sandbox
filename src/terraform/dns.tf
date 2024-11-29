data "aws_route53_zone" "public" {
  name = local.networking.public_dns_domain
}

resource "aws_route53_zone" "private" {
  name = "gb.aws"

  vpc {
    vpc_id = aws_vpc.alfresco.id
  }
}
