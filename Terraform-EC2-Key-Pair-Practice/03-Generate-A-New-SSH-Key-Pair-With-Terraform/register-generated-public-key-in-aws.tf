resource "aws_key_pair" "generated" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}
