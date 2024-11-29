resource "aws_route53_record" "public_alfresco" {
  name = "alfresco.gb.${data.aws_route53_zone.public.name}"
  zone_id = data.aws_route53_zone.public.id
  type = "CNAME"
  ttl = 60
  records = [aws_lb.alfresco.dns_name]
}

resource "aws_route53_record" "private_alfresco" {
  name = "alfresco.${aws_route53_zone.private.name}"
  zone_id = aws_route53_zone.private.id
  type = "A"
  ttl = 60
  records = [aws_instance.alfresco.private_ip]
}
