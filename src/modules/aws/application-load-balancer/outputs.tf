output "target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "public_dns" {
  value = aws_lb.this.dns_name
}