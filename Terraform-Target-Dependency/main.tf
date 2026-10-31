# 1. VPC
resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo-VPC"
  }
}

# 2. Subnet
resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Demo-Subnet"
  }
}

# 3. EC2 Instance
resource "aws_instance" "demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.demo.id

  tags = {
    Name = "Demo-EC2"
  }
}

# 4. S3 Bucket
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  # Explicit Dependency
  depends_on = [
    aws_instance.demo
  ]

  tags = {
    Name = "Demo-S3"
  }
}