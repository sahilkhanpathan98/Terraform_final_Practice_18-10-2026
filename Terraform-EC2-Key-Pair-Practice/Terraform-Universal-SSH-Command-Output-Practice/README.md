# Terraform – Universal SSH Command Output

## Goal

Terraform automatically creates an SSH command using:
- Private Key file path
- EC2 SSH username
- EC2 Public IP

After `terraform apply`, Terraform displays the command. You copy it and run it in your terminal.

> This output does not perform SSH login automatically. It only builds the command.

## Folder structure

```text
Terraform-Universal-SSH-Command-Output-Practice/
├── README.md
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .gitignore
```

## 1. Variables

In `variables.tf`, we define values that can change between projects.

```hcl
variable "private_key_path" {
  description = "Full path of the private key on your local machine"
  type        = string
}

variable "ssh_user" {
  description = "Default SSH username for the EC2 AMI"
  type        = string
}
```

Examples:
- Amazon Linux: `ec2-user`
- Ubuntu: `ubuntu`
- CentOS: `centos`

## 2. SSH command output

In `outputs.tf`:

```hcl
output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i \"${var.private_key_path}\" ${var.ssh_user}@${aws_instance.my_ec2.public_ip}"
}
```

Important:
- `var.private_key_path` = where your private key is saved on your laptop.
- `var.ssh_user` = EC2 operating-system username.
- `aws_instance.my_ec2.public_ip` = Public IP of the EC2 resource.

`my_ec2` must match the actual Terraform resource label. For example, if your resource is `aws_instance.web_server`, use `aws_instance.web_server.public_ip`.

## 3. Set your values

Copy `terraform.tfvars.example` to `terraform.tfvars` and edit the values.

Example for Windows:

```hcl
private_key_path = "D:/My-SSH-Keys/terraform-key"
ssh_user         = "ec2-user"
```

Example for Ubuntu:

```hcl
private_key_path = "C:/Users/Sahil/.ssh/ubuntu-key.pem"
ssh_user         = "ubuntu"
```

The example file contains placeholder values. Use the real path and username for your environment.

## 4. Run Terraform

Run these commands from the Terraform project directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After apply, see the output again with:

```bash
terraform output ssh_command
```

Copy the displayed SSH command and run it in your terminal.

## 5. Example result

Suppose:
- Private key path: `D:/My-SSH-Keys/terraform-key`
- SSH username: `ec2-user`
- EC2 Public IP: `13.233.100.50`

Terraform displays:

```bash
ssh -i "D:/My-SSH-Keys/terraform-key" ec2-user@13.233.100.50
```

## 6. What changes between projects?

| Part | What it means | Example |
|---|---|---|
| Private key path | Location of your private key | `D:/My-SSH-Keys/terraform-key` |
| SSH username | User for the EC2 operating system | `ec2-user` or `ubuntu` |
| Terraform resource label | Name used in your EC2 resource block | `my_ec2` or `web_server` |
| Public IP | Assigned to the EC2 instance | Terraform reads it automatically |

## 7. Important requirements

1. The EC2 instance must have a reachable Public IP, or you must have another valid network path to it.
2. The EC2 security group must allow inbound SSH (TCP port 22) from your trusted IP/network.
3. The private key must match the public key registered with the EC2 Key Pair.
4. Use the correct SSH username for the AMI.
5. Keep the private key secure. Never commit it to GitHub.
6. Terraform output only creates the command; it does not connect to EC2.

## Interview answer

Terraform output can dynamically construct an SSH command by combining a configurable private-key path, the AMI-specific SSH username, and the EC2 instance's public IP. This avoids manually typing the full command each time, but the user still runs the generated command to establish the SSH connection.
