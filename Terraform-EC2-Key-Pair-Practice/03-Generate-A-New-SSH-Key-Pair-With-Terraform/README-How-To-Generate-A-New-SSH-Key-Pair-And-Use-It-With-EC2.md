# Scenario 3 – Generate a New SSH Key Pair with Terraform

## Goal

Is case mein laptop par pehle se SSH key pair hona zaroori nahi. Terraform `tls_private_key` resource se nayi public aur private key generate karega. Public key AWS mein register hogi aur EC2 ke saath attach hogi.

## Flow diagram

```text
             Terraform
                 |
                 v
          tls_private_key
                 |
          Generates two keys
                 |
          +------+------+
          |             |
          v             v
      Public key    Private key
          |             |
          v             v
   aws_key_pair     Sensitive output
          |             |
          v             v
     AWS registers   User saves it
     public key      securely
          |             |
          v             |
      EC2 instance      |
          |             |
          +------+------+
                 |
                 v
        SSH authentication
                 |
                 v
             EC2 login
```

## Terraform files

### `provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Valid AMI ID for the selected region"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  description = "Name for the new AWS Key Pair"
  type        = string
  default     = "terraform-generated-key"
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "Existing security group IDs; allow SSH only from your trusted IP"
  type        = list(string)
}
```

### `generate-new-ssh-key-pair.tf`

```hcl
resource "tls_private_key" "ec2_key" {
  algorithm = "ED25519"
}
```

### `register-generated-public-key-in-aws.tf`

```hcl
resource "aws_key_pair" "generated" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}
```

### `ec2-use-generated-key-pair.tf`

```hcl
resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  key_name = aws_key_pair.generated.key_name

  tags = {
    Name = "ec2-using-terraform-generated-key"
  }
}
```

### `outputs-show-private-key-safely.tf`

```hcl
output "private_key_openssh" {
  description = "Generated private key. Keep it secret and store it securely."
  value       = tls_private_key.ec2_key.private_key_openssh
  sensitive   = true
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.dev.public_ip
}
```

### `terraform.tfvars.example`

```hcl
ami_id             = "ami-xxxxxxxxxxxxxxxxx"
subnet_id          = "subnet-xxxxxxxxxxxxxxxxx"
security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]
```

## Run commands

`terraform.tfvars.example` ko copy karke `terraform.tfvars` banayein aur values update karein.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Private key ko secure tarike se save karna

Terraform sensitive output ko normal apply output mein hide karta hai. Private key ko terminal se retrieve karne ke liye:

```bash
terraform output -raw private_key_openssh
```

Is command ka output secret hai. Isse public terminal, screenshot, chat ya GitHub par share na karein. Output ko secure local file mein save karein, us file ki permissions restrict karein, aur backup securely rakhein.

Windows PowerShell mein private key ko file mein save karne ka example:

```powershell
terraform output -raw private_key_openssh | Set-Content -NoNewline .\terraform-generated-key
```

File ko Git mein commit na karein. `.gitignore` mein `*.key` aur `*.pem` ignore hain; is example ki extension nahi hai, isliye private key file ko manually ignore karein ya project folder ke bahar secure location mein save karein. Better: output ko project folder ke bahar save karein.

## SSH login

Generated private key file ke path ko use karein:

```bash
ssh -i /secure/path/terraform-generated-key ec2-user@<EC2-PUBLIC-IP>
```

## Very important security warning

- `sensitive = true` output ko screen par hide karta hai; ye secret ko Terraform state se remove nahi karta.
- `tls_private_key` ki private key Terraform state mein store hoti hai.
- State file ko secure rakhein, access restrict karein, aur remote backend use karte waqt encryption aur access control enable karein.
- State file, private key file aur `terraform.tfvars` ko GitHub par upload na karein.
- Agar private key lose ho gayi, AWS se original private key retrieve nahi kar sakte.

## Cleanup

```bash
terraform destroy
```

Isse EC2 instance aur AWS mein registered Key Pair delete honge. Terraform state mein generated private key bhi thi; state ko securely handle karein. Local mein manually save ki hui private key file ko alag se securely delete karein jab uski zaroorat na ho.
