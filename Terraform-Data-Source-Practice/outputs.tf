output "vpc_id" {
  description = "ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "subnet_id" {
  description = "ID of the existing subnet"
  value       = data.aws_subnet.existing.id
}

output "ami_id" {
  description = "Selected Amazon Linux AMI ID"
  value       = data.aws_ami.amazon_linux.id
}

output "ec2_public_ip" {
  description = "Public IP of the new EC2 instance"
  value       = aws_instance.dev.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the new EC2 instance"
  value       = aws_instance.dev.private_ip
}
