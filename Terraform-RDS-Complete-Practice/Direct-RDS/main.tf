data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "rds_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Direct-RDS-VPC"
  }
}

# Private Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "RDS-Private-Subnet-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "RDS-Private-Subnet-2"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "direct-rds-subnet-group"

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = {
    Name = "Direct-RDS-Subnet-Group"
  }
}

# Security Group
resource "aws_security_group" "rds_sg" {
  name   = "Direct-RDS-SG"
  vpc_id = aws_vpc.rds_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier = "direct-rds-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 3306

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible    = false
  storage_encrypted      = true
  multi_az               = false
  deletion_protection    = false
  skip_final_snapshot    = true
  apply_immediately      = true

  tags = {
    Name = "Direct-RDS"
  }
}