output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "target_group_cms_arn" {
  value = aws_lb_target_group.cms.arn
}
