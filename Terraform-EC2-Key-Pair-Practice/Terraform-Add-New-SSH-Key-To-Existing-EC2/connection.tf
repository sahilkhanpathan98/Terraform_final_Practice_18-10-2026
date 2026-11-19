# This resource connects to the EXISTING EC2 using the OLD private key,
# then appends the NEW public key to the target user's authorized_keys.
resource "terraform_data" "install_new_key" {
  # Re-run if the generated public key changes.
  triggers_replace = [
    tls_private_key.new_key.public_key_openssh
  ]

  connection {
    type        = "ssh"
    host        = var.ec2_public_ip
    user        = var.ssh_user
    private_key = file(var.old_private_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "touch ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
      "NEW_KEY=$(printf '%s' '${base64encode(tls_private_key.new_key.public_key_openssh)}' | base64 -d); grep -qxF \"$NEW_KEY\" ~/.ssh/authorized_keys || printf '%s\\n' \"$NEW_KEY\" >> ~/.ssh/authorized_keys"
    ]
  }
}
