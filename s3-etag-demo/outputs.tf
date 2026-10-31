output "vpc_id" {
  description = "Created VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Created public subnet ID"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "Created Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.web.id
}

output "ec2_instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  description = "Created S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.bucket
}

output "s3_object_key" {
  description = "Uploaded ZIP object key"
  value       = aws_s3_object.lambda_code.key
}