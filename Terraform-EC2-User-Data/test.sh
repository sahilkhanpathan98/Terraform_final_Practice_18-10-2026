
#!/bin/bash

# Install Apache
dnf install -y httpd

# Start Apache and enable on boot
systemctl enable --now httpd

# Create website
echo "<h1>Welcome! AWS Infra created using Terraform</h1>" \
  > /var/www/html/index.html
