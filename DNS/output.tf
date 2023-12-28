output "route53_record_name" {
  description = "The name of the record"
  value       = aws_route53_zone.private_zone.name
}

output "route53_record_fqdn" {
  description = "FQDN built using the zone domain and name"
  value       = aws_route53_record.dns.fqdn
}