# Terraform – Add a New SSH Key to an Existing EC2

## Goal

Add a **new SSH public key** to an already-running Linux EC2 instance without changing the EC2 instance's `key_name` and without replacing the instance.

This project assumes:
- The EC2 instance already exists.
- You know its public IP address (or reachable private IP).
- You still have the **old private key** that can log in to the instance.
- SSH (TCP 22) is allowed from your computer in the EC2 security group.
- The EC2 OS user is known (for example, `ec2-user` for Amazon Linux or `ubuntu` for Ubuntu).

## Important distinction

`aws_key_pair` registers the new public key in your AWS account. It does **not** automatically install that key on an already-running EC2.

The `terraform_data` resource runs a remote command over SSH using the old private key. That command appends the new public key to the target user's `~/.ssh/authorized_keys`.

We deliberately do **not** change the existing EC2 resource's `key_name`. Changing `aws_instance.key_name` generally forces replacement of the instance.

## Project files

```text
Terraform-Add-New-SSH-Key-To-Existing-EC2/
│
├── README.md
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars.example
├── key-pair.tf
├── connection.tf
├── outputs.tf
└── .gitignore
```

## Flow

```text
       Existing EC2 (already running)
                    |
                    | Old private key
                    v
          Terraform SSH connection
                    |
                    v
           terraform_data resource
                    |
                    | remote-exec
                    v
       Append NEW public key to
       ~/.ssh/authorized_keys
                    |
                    v
       Save NEW private key on laptop
                    |
                    v
       SSH login using the NEW key
```

## What each file does

| File | Purpose |
|---|---|
| `versions.tf` | Declares Terraform and provider versions |
| `provider.tf` | Configures AWS provider and region |
| `variables.tf` | Declares input variables |
| `terraform.tfvars.example` | Sample values; copy it to `terraform.tfvars` |
| `key-pair.tf` | Generates a new key pair and registers its public key in AWS |
| `connection.tf` | Connects using the old key and installs the new public key |
| `outputs.tf` | Shows the new key name and SSH command |
| `.gitignore` | Prevents local secret/config files from being committed |

## Step-by-step

### 1. Prepare the values

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:

```hcl
aws_region           = "ap-south-1"
key_name             = "my-new-terraform-key"
ec2_public_ip        = "YOUR_EC2_PUBLIC_IP"
ssh_user             = "ec2-user"
old_private_key_path = "D:/My-SSH-Keys/old-key.pem"
new_private_key_path = "D:/My-SSH-Keys/my-new-terraform-key"
```

Use the correct SSH username for your AMI:
- Amazon Linux: `ec2-user`
- Ubuntu: `ubuntu`
- Debian: commonly `admin`

Use a full path to the **old private key**. The new private key path is where you will save the generated key after apply.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the configuration

```bash
terraform fmt
terraform validate
```

### 4. Review the plan

```bash
terraform plan
```

Read the plan carefully. This project should create an AWS key-pair registration and a `terraform_data` resource. It should **not** create or replace your existing EC2 instance.

### 5. Apply

```bash
terraform apply
```

Confirm only after checking the plan.

### 6. Save the new private key (Windows PowerShell)

Open PowerShell in this project directory and run:

```powershell
terraform output -raw new_private_key | Set-Content -NoNewline "D:/My-SSH-Keys/my-new-terraform-key"
```

Replace the path with the exact `new_private_key_path` value you set in `terraform.tfvars`.

Keep this file private. Do not email it, upload it publicly, or commit it to Git.

### 7. Log in with the new key

```bash
ssh -i "D:/My-SSH-Keys/my-new-terraform-key" ec2-user@YOUR_EC2_PUBLIC_IP
```

Replace the username, key path, and IP with your actual values.

## Important security notes

1. **Old private key is required.** Terraform must already be able to connect to the instance. This method cannot recover access if every working login method is lost.
2. **Private key is sensitive.** `sensitive = true` hides it in normal CLI output, but the generated private key is still stored in Terraform state. Protect the state file and any remote backend; do not commit state to Git.
3. **Keep `terraform.tfvars` private.** It contains local paths and connection details. It is ignored by `.gitignore`.
4. **No EC2 replacement intended.** Do not add/change `key_name` on the existing `aws_instance` resource as part of this exercise.
5. **Linux only.** This example targets a Linux EC2 instance with OpenSSH and a `base64` command.
6. **Provisioner limitation.** `remote-exec` is useful for learning and controlled tasks, but provisioners are not the preferred mechanism for ongoing configuration management. For production environments, consider AWS Systems Manager (SSM) or a managed configuration approach.
7. **Key name must be unique.** If the AWS account already has a key pair with the same name, choose another `key_name` or deliberately manage the existing key instead.

## Cleanup

`terraform destroy` will remove the AWS key-pair registration and the Terraform-managed `terraform_data` object. It does **not** remove the public key line already appended to the EC2 user's `authorized_keys` file, because that file change is not automatically reversed.

If you want to revoke access, remove the exact new public-key line from the instance's `~/.ssh/authorized_keys` using another valid access method. Also securely delete the new private-key file when it is no longer needed.

## Interview-ready summary

Terraform generates a new SSH key pair and registers its public key in AWS. A `terraform_data` resource then uses the existing private key to connect to the running EC2 instance and append the new public key to the user's `authorized_keys` file. The EC2 instance's `key_name` is not changed, so this approach avoids replacing the instance. The generated private key and Terraform state must be protected.
