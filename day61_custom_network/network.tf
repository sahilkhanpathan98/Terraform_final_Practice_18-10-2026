# Step 1: Create a custom VPC
resource "aws_vpc" "cust_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cust-vpc"
  }
}

# Step 2: Create a public subnet inside the VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cust_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Step 3: Create and attach an Internet Gateway to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cust_vpc.id

  tags = {
    Name = "cust-igw"
  }
}

# Step 4: Create a route table with a default IPv4 route to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Step 5: Associate the public subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Step 6: Security Group - HTTP/HTTPS from anywhere, SSH only from your IP
resource "aws_security_group" "web" {
  name        = "cust-web-sg"
  description = "Allow web traffic and restricted SSH access"
  vpc_id      = aws_vpc.cust_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Set ssh_allowed_cidr in terraform.tfvars to your trusted public IP /32.
  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cust-web-sg"
  }
}
