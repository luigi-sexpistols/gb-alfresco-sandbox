output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "public_dns" {
  value = aws_lb.this.dns_name
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
