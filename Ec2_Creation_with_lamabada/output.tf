output "vpc_id" {
  value = aws_vpc.cust_vpc.id
}

output "subnet_id" {
  value = aws_subnet.sub1.id
}

output "lambda_function_name" {
  value = aws_lambda_function.ec2_launcher.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.ec2_launcher.arn
}