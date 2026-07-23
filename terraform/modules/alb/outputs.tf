output "alb_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route 53 zone ID for alias records."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the default target group."
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "Security group ID for the load balancer."
  value       = aws_security_group.alb.id
}
