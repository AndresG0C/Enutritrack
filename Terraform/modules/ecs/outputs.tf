output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "Dirección DNS pública asignada por AWS al Load Balancer"
}
