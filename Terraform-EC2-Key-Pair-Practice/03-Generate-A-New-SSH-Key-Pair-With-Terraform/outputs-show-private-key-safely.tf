output "private_key_openssh" {
  description = "Generated private key. Keep it secret and store it securely."
  value       = tls_private_key.ec2_key.private_key_openssh
  sensitive   = true
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.dev.public_ip
}
