# Generate a new SSH key pair.
# The private key is sensitive and will also be stored in Terraform state.
resource "tls_private_key" "new_key" {
  algorithm = "ED25519"
}

# Register ONLY the public key with AWS.
# This does not install the key on an already-running EC2 instance.
resource "aws_key_pair" "new_key" {
  key_name   = var.key_name
  public_key = tls_private_key.new_key.public_key_openssh
}
