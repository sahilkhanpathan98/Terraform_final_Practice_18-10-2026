resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = aws_key_pair.generated.key_name

  tags = {
    Name = "ec2-using-terraform-generated-key"
  }
}
