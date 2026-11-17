resource "aws_security_group" "dev_sg" {
  name        = "data-source-sg"
  description = "Security group for Data Source EC2"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "data-source-sg"
  }
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.existing.id
  vpc_security_group_ids      = [aws_security_group.dev_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Data-Source-EC2"
  }
}
