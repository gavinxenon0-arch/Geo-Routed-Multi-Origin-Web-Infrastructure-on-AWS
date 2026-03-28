
output "instance1" {
  value = aws_instance.first_instance.associate_public_ip_address
}
output "instance2" {
  value = aws_instance.second_instance.associate_public_ip_address
}
output "cloudfront_url" {
  description = "CloudFront distribution domain name"
  value       = "https://${aws_cloudfront_distribution.geo_demo.domain_name}"
}
output "Cloudfront" {
  value = aws_cloudfront_distribution.geo_demo.domain_name
}