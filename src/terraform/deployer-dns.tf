resource "aws_route53_record" "public_deployer" {
  name = "deployer.gb.${data.aws_route53_zone.public.name}"
  zone_id = data.aws_route53_zone.public.id
  type = "A"
  ttl = 60
  records = [aws_instance.deployer.public_ip]
}

resource "aws_route53_record" "private_deployer" {
  name = "deployer.${aws_route53_zone.private.name}"
  zone_id = aws_route53_zone.private.id
  type = "A"
  ttl = 60
  records = [aws_instance.deployer.private_ip]
}
