output "aws_key_pair_name" {
  description = "Name of the new public key registered in AWS"
  value       = aws_key_pair.new_key.key_name
}

output "new_private_key" {
  description = "New private key. Save it securely on your computer."
  value       = tls_private_key.new_key.private_key_openssh
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command template; replace the key path if needed"
  value       = "ssh -i \"${var.new_private_key_path}\" ${var.ssh_user}@${var.ec2_public_ip}"
}
