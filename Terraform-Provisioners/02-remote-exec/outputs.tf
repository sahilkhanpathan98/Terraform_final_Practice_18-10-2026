output "ssh_command_hint" {
  value = "ssh -i <private-key-path> ec2-user@${aws_instance.demo.public_ip}"
}
