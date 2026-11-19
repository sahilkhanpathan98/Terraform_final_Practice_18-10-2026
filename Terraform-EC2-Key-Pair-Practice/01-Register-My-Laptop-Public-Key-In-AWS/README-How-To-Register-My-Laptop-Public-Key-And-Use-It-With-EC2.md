# Scenario 1 – Register My Laptop's Existing Public Key in AWS

## Goal

Laptop par pehle se SSH key pair available hai. Hum uski **public key** AWS mein register karenge aur us Key Pair ko EC2 instance ke saath attach karenge.

## Key files

Example:

```text
~/.ssh/
├── id_ed25519       # Private key – laptop par hi rahegi
└── id_ed25519.pub   # Public key – AWS mein register hogi
```

## Flow diagram

```text
Laptop par existing SSH key pair
          |
          +---------------------------+
          |                           |
          v                           v
   Public key (.pub)            Private key
          |                           |
          v                           | laptop par safe
Terraform file() reads it             |
          |                           |
          v                           |
AWS aws_key_pair resource             |
          |                           |
          v                           |
AWS mein public key register          |
          |                           |
          v                           |
EC2 instance ko Key Pair attach       |
          |                           |
          +-------------+-------------+
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
  }
}

provider "aws" {
  region = var.aws_region
}
```

### `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region where EC2 will be created"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Valid AMI ID for the selected AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name to register for this AWS EC2 Key Pair"
  type        = string
  default     = "laptop-existing-public-key"
}

variable "public_key_path" {
  description = "Path to the existing public key on this laptop"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "subnet_id" {
  description = "Existing subnet ID in the selected VPC"
  type        = string
}

variable "security_group_ids" {
  description = "Existing security group IDs; allow SSH only from your trusted IP"
  type        = list(string)
}
```

### `key-pair-register-existing-public-key.tf`

```hcl
resource "aws_key_pair" "laptop_key" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))
}
```

### `ec2-use-registered-key-pair.tf`

```hcl
resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  key_name = aws_key_pair.laptop_key.key_name

  tags = {
    Name = "ec2-using-laptop-public-key"
  }
}
```

### `terraform.tfvars.example`

```hcl
ami_id             = "ami-xxxxxxxxxxxxxxxxx"
subnet_id          = "subnet-xxxxxxxxxxxxxxxxx"
security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]

# Change this if your public key has a different filename.
public_key_path = "~/.ssh/id_ed25519.pub"
```

## Run commands

`terraform.tfvars.example` ko copy karke `terraform.tfvars` naam dein, phir values update karein.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## SSH login

Amazon Linux AMI ke liye:

```bash
ssh -i ~/.ssh/id_ed25519 ec2-user@<EC2-PUBLIC-IP>
```

Windows par key ka path apne actual path ke hisaab se dein. `~` shell aur Terraform ke context mein alag tarah resolve ho sakta hai; Terraform configuration mein `pathexpand()` home directory expand karta hai.

## Yaad rakhein

- `file()` public key file ka content read karta hai.
- `pathexpand()` `~` ko home directory path mein expand karta hai.
- `aws_key_pair` AWS mein public key register karta hai.
- Private key AWS ko upload nahi hoti; woh laptop par hi rehti hai.
- AWS mein same region/account mein same Key Pair name pehle se maujood hua toh creation fail ho sakti hai.
- `aws_key_pair` resource ko delete karne se AWS mein registered Key Pair delete hota hai; local private key file delete nahi hoti.

## Cleanup

```bash
terraform destroy
```

Destroy karne se EC2 instance aur Terraform-managed AWS Key Pair delete honge. Local SSH key files delete nahi hongi.
