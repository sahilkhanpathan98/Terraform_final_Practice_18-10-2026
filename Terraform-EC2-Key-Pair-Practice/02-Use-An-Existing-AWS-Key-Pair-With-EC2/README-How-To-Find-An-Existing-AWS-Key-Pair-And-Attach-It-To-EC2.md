# Scenario 2 – Use an Existing AWS Key Pair with EC2

## Goal

Is case mein Key Pair **AWS mein pehle se bana hua hai**. Terraform usko create nahi karega. Terraform Data Source se uski information read karega aur EC2 ke saath attach karega.

## Flow diagram

```text
AWS account / selected region
          |
          v
Already existing EC2 Key Pair
          |
          v
Terraform data "aws_key_pair"
          |
          v
Existing Key Pair ki details read
          |
          v
EC2 resource mein key_name reference
          |
          v
EC2 instance launch
          |
          v
Matching private key se SSH login
```

## Important difference

- `resource "aws_key_pair"` = AWS mein Key Pair create/manage karta hai.
- `data "aws_key_pair"` = AWS mein pehle se maujood Key Pair ki information read karta hai.
- Data Source existing Key Pair ki private key provide ya recover nahi karta.
- SSH login ke liye us Key Pair ki matching private key aapke paas honi chahiye.

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
  description = "Region where the existing AWS Key Pair is available"
  type        = string
  default     = "ap-south-1"
}

variable "existing_key_name" {
  description = "Exact name of the Key Pair already present in AWS"
  type        = string
}

variable "ami_id" {
  description = "Valid AMI ID for the selected region"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
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

### `data-find-existing-aws-key-pair.tf`

```hcl
data "aws_key_pair" "existing" {
  key_name = var.existing_key_name
}
```

### `ec2-attach-existing-aws-key-pair.tf`

```hcl
resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  key_name = data.aws_key_pair.existing.key_name

  tags = {
    Name = "ec2-using-existing-aws-key"
  }
}
```

### `terraform.tfvars.example`

```hcl
aws_region         = "ap-south-1"
existing_key_name  = "my-existing-aws-key"
ami_id             = "ami-xxxxxxxxxxxxxxxxx"
subnet_id          = "subnet-xxxxxxxxxxxxxxxxx"
security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]
```

## Run commands

AWS Console mein EC2 → Key Pairs par jaakar exact Key Pair name aur region verify karein. Phir `terraform.tfvars.example` ko copy karke `terraform.tfvars` banayein aur values update karein.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## SSH login

Us existing AWS Key Pair ki matching private key use karein. Example:

```bash
ssh -i /path/to/my-existing-private-key.pem ec2-user@<EC2-PUBLIC-IP>
```

## Yaad rakhein

- Data Source AWS mein Key Pair create nahi karta.
- Data Source sirf existing Key Pair ko lookup karta hai.
- Key Pair same AWS account aur same region mein hona chahiye jahan provider configured hai.
- Private key kho gayi ho toh AWS se dobara download nahi kar sakte. Naya Key Pair use karke access configure karna padega.

## Cleanup

```bash
terraform destroy
```

Isse Terraform-managed EC2 instance delete hoga. Data Source se read kiya gaya existing AWS Key Pair delete nahi hoga.
