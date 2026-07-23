output "zone_id" {
  description = "Route 53 private hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Route 53 private hosted zone name."
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Name servers for the private hosted zone."
  value       = aws_route53_zone.this.name_servers
}
