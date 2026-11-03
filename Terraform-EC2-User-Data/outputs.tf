
output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "Apache Website URL"
  value       = "http://${aws_instance.web.public_ip}"
}

output "security_group_id" {
  description = "Created Security Group ID"
  value       = aws_security_group.web_sg.id
}
