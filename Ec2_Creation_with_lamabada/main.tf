
# VPC
resource "aws_vpc" "cust_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cust-vpc"
  }
}

# Public subnet
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.cust_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cust_ig" {
  vpc_id = aws_vpc.cust_vpc.id

  tags = {
    Name = "cust-IG"
  }
}

# Route table
resource "aws_route_table" "cust_rt" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cust_ig.id
  }

  tags = {
    Name = "cust-RT"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "sub1_assoc" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.cust_rt.id
}

# Security group for the EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "lambda-launched-ec2-sg"
  description = "Security group for Lambda launched EC2"
  vpc_id      = aws_vpc.cust_vpc.id

  # SSH from your own public IP is safer.
  # Add an ingress rule for TCP 22 with your IP /32
  # if you need SSH access.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-ec2-sg"
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "terraform-lambda-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# CloudWatch logging permissions
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions needed to launch EC2 in this subnet and use its security group
resource "aws_iam_role_policy" "ec2_launch" {
  name = "lambda-ec2-launch-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:DescribeKeyPairs"
        ]
        Resource = "*"
      }
    ]
  })
}

# Package Python code into ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "ec2_launcher" {
  function_name = "terraform-ec2-launcher"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.13"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 128

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy.ec2_launch
  ]

  tags = {
    Name = "terraform-ec2-launcher"
  }
}
