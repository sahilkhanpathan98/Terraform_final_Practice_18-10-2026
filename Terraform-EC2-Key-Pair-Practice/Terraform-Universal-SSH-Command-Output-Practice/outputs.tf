output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i \"${var.private_key_path}\" ${var.ssh_user}@${aws_instance.my_ec2.public_ip}"
}
