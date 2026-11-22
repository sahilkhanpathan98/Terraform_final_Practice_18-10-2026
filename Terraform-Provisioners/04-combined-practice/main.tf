terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web" {
  name_prefix = "combined-provisioner-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH only from learner IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }
  ingress {
    description = "HTTP demo website"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "${path.module}/files/index.html"
    destination = "/home/ec2-user/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "5m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y nginx",
      "sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.private_key_path)
      timeout     = "5m"
    }
  }

  tags = {
    Name = "terraform-combined-provisioner-lab"
  }
}
output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}
